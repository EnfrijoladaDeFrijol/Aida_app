import Foundation
import SwiftData
import SwiftUI

@MainActor
class ProgresoViewModel: ObservableObject {
    @Published var mesActual: RegistroMensual?
    @Published var mesesAnteriores: [RegistroMensual] = []
    
    // UI State
    @Published var isAuthorized = false
    
    let healthManager = HealthDataManager.shared
    
    func inicializarDatos(context: ModelContext) {
        let ahora = Date()
        let calendar = Calendar.current
        let inicioMes = calendar.date(from: calendar.dateComponents([.year, .month], from: ahora))!
        
        let descriptor = FetchDescriptor<RegistroMensual>(sortBy: [SortDescriptor(\.mes, order: .reverse)])
        let todos = (try? context.fetch(descriptor)) ?? []
        
        // Obtener historial (excluyendo el actual)
        mesesAnteriores = todos.filter { !calendar.isDate($0.mes, equalTo: inicioMes, toGranularity: .month) }
        
        // Obtener o crear el actual
        if let actual = todos.first(where: { calendar.isDate($0.mes, equalTo: inicioMes, toGranularity: .month) }) {
            self.mesActual = actual
        } else {
            let nuevo = RegistroMensual(mes: inicioMes)
            context.insert(nuevo)
            try? context.save()
            self.mesActual = nuevo
        }
        
        cargarHealthKit(context: context)
    }
    
    func cargarHealthKit(context: ModelContext) {
        healthManager.requestAuthorization { [weak self] success, _ in
            guard let self = self, success else { return }
            self.isAuthorized = true
            
            self.healthManager.fetchMonthlyData(for: .stepCount, unit: .count()) { pasos in
                self.mesActual?.pasosTotales = Int(pasos)
                try? context.save()
            }
            
            self.healthManager.fetchMonthlyData(for: .distanceWalkingRunning, unit: .meter()) { metros in
                self.mesActual?.kmTotales = metros / 1000.0
                try? context.save()
            }
            
            self.healthManager.fetchMonthlyData(for: .distanceSwimming, unit: .meter()) { metros in
                self.mesActual?.metrosTotales = metros
                try? context.save()
            }
            
            self.healthManager.fetchMonthlyData(for: .activeEnergyBurned, unit: .kilocalorie()) { calorias in
                self.mesActual?.caloriasActivas = calorias
                try? context.save()
            }
        }
    }
    
    // Funciones de ayuda para UI
    func calcularVariacion(actual: Double, anterior: Double) -> (porcentaje: Double, esMejora: Bool) {
        guard anterior > 0 else { return (actual > 0 ? 100.0 : 0.0, true) }
        let diferencia = actual - anterior
        let porcentaje = (abs(diferencia) / anterior) * 100
        return (porcentaje, diferencia >= 0)
    }
    
    func colorParaVariacion(_ esMejora: Bool) -> Color {
        return esMejora ? .aidaVerde : .aidaRojo
    }
}
