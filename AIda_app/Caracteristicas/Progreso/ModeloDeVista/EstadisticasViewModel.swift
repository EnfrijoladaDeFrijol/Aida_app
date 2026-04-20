import Foundation
import SwiftData
import SwiftUI

@MainActor
class EstadisticasViewModel: ObservableObject {
    // Métricas de Running
    @Published var kilometrosActuales: Double = 0
    @Published var kilometrosAnteriores: Double = 25.0
    @Published var elevacionActual: Double = 120.0 // metros
    
    // Métricas de Natación (Total = HealthKit + Manual)
    @Published var metrosNatacionHK: Double = 0.0
    @Published var metrosNatacionManual: Double = 0.0
    @Published var sesionesNatacion: Int = 0
    @Published var metrosAnterioresNatacion: Double = 0.0
    
    // Métricas de Gimnasio
    @Published var tonelajeTotal: Double = 12500.0 // kg
    @Published var ejercicioPR: String = "Sentadilla: 120kg"
    
    // Métricas de Lifestyle
    @Published var pasosActuales: Int = 0
    @Published var pasosAnteriores: Int = 50000
    @Published var caloriasActivas: Double = 0.0
    @Published var caloriasAnteriores: Double = 11000.0
    
    let healthManager = HealthDataManager.shared
    
    // Datos de prueba para la gráfica
    let historialKms: [HistorialMes] = [
        HistorialMes(mes: "Feb", valor: 35.5),
        HistorialMes(mes: "Mar", valor: 25.0),
        HistorialMes(mes: "Abr", valor: 0.0) // Este se actualiza en tiempo real
    ]
    
    func cargarDatosHealthKit() {
        healthManager.requestAuthorization { [weak self] success, _ in
            guard let self = self, success else { return }
            
            // Cargar Pasos del mes actual
            self.healthManager.fetchMonthlyData(for: .stepCount, unit: .count()) { pasos in
                self.pasosActuales = Int(pasos)
            }
            
            // Cargar Kilometros (Walking/Running) del mes actual
            self.healthManager.fetchMonthlyData(for: .distanceWalkingRunning, unit: .meter()) { metros in
                self.kilometrosActuales = metros / 1000.0
            }
            
            // Cargar Calorías Activas (Apple Watch)
            self.healthManager.fetchMonthlyData(for: .activeEnergyBurned, unit: .kilocalorie()) { calorias in
                self.caloriasActivas = calorias
            }
            
            // Cargar Natación automática (Apple Watch)
            self.healthManager.fetchMonthlyData(for: .distanceSwimming, unit: .meter()) { metros in
                self.metrosNatacionHK = metros
            }
        }
    }
    
    // Propiedad computada que suma lo del Apple Watch + Lo Manual
    var metrosNatacionTotal: Double {
        return metrosNatacionHK + metrosNatacionManual
    }
}

struct HistorialMes: Identifiable {
    let id = UUID()
    let mes: String
    var valor: Double
}
