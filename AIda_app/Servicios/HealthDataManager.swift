import Foundation
import HealthKit

class HealthDataManager: ObservableObject {
    static let shared = HealthDataManager()
    let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let distanceSwimming = HKObjectType.quantityType(forIdentifier: .distanceSwimming),
              let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
              let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [stepCount, distanceSwimming, distanceWalkingRunning, activeEnergy]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                completion(success, error)
            }
        }
    }
    
    func fetchMonthlyData(for quantityTypeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            completion(0)
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        guard let startOfMonth = calendar.date(from: components) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: now, options: .strictStartDate)
        
        var interval = DateComponents()
        interval.month = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startOfMonth,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { _, results, _ in
            var total = 0.0
            if let results = results {
                results.enumerateStatistics(from: startOfMonth, to: now) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        total += sum.doubleValue(for: unit)
                    }
                }
            }
            DispatchQueue.main.async {
                completion(total)
            }
        }
        
        healthStore.execute(query)
    }
}
