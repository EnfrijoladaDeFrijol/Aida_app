import Foundation
import SwiftData
import SwiftUI

@MainActor
class ProgresoViewModel: ObservableObject {
    @Published var mesActual: RegistroMensual?
    @Published var mesesAnteriores: [RegistroMensual] = []
    
    // UI State
    @Published var isAuthorized = false
    @Published var mostrarRegistroManual = false
    
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
        
        // Inyectar datos de ejemplo si el mes actual está vacío
        if let actual = mesActual, registroEstaVacio(actual) {
            inyectarDatosEjemplo(registro: actual, context: context)
        }
        
        // Crear meses históricos de ejemplo si no hay historial
        if mesesAnteriores.isEmpty {
            crearHistorialEjemplo(context: context, mesActual: inicioMes)
            // Re-fetch para poblar mesesAnteriores
            let todosActualizados = (try? context.fetch(descriptor)) ?? []
            mesesAnteriores = todosActualizados.filter { !calendar.isDate($0.mes, equalTo: inicioMes, toGranularity: .month) }
        }
        
        cargarHealthKit(context: context)
    }
    
    private func registroEstaVacio(_ reg: RegistroMensual) -> Bool {
        return reg.pasosTotales == 0
            && reg.metrosTotales == 0
            && reg.kmTotales == 0
            && reg.tonelajeTotal == 0
            && reg.caloriasActivas == 0
    }
    
    private func inyectarDatosEjemplo(registro: RegistroMensual, context: ModelContext) {
        registro.metrosTotales = 4800
        registro.sesionesNado = 12
        registro.kmTotales = 47.3
        registro.elevacionGanada = 320
        registro.tonelajeTotal = 18500
        registro.ejercicioPR = "Sentadilla:120"
        registro.pasosTotales = 186420
        registro.caloriasActivas = 12340
        registro.conteoEstadosAnimo = [
            "Increíble": 8, "Bien": 12, "Normal": 5, "Cansado": 3, "Estresado": 2
        ]
        try? context.save()
    }
    
    private func crearHistorialEjemplo(context: ModelContext, mesActual: Date) {
        let calendar = Calendar.current
        let datosHistoricos: [(mesesAtras: Int, metros: Double, sesiones: Int, km: Double, elev: Double, ton: Double, pasos: Int, cal: Double)] = [
            (3, 2200, 6, 22.5, 140, 9800, 95000, 6200),
            (2, 3400, 9, 35.0, 210, 14200, 142000, 9100),
            (1, 4100, 11, 41.8, 280, 16800, 168000, 11000)
        ]
        
        for dato in datosHistoricos {
            if let fecha = calendar.date(byAdding: .month, value: -dato.mesesAtras, to: mesActual) {
                let reg = RegistroMensual(
                    mes: fecha,
                    metrosTotales: dato.metros,
                    sesionesNado: dato.sesiones,
                    kmTotales: dato.km,
                    elevacionGanada: dato.elev,
                    tonelajeTotal: dato.ton,
                    ejercicioPR: "Sentadilla:100",
                    pasosTotales: dato.pasos,
                    caloriasActivas: dato.cal
                )
                context.insert(reg)
            }
        }
        try? context.save()
    }
    
    func cargarHealthKit(context: ModelContext) {
        healthManager.requestAuthorization { [weak self] success, _ in
            guard let self = self, success else { return }
            self.isAuthorized = true
            
            self.healthManager.fetchMonthlyData(for: .stepCount, unit: .count()) { pasos in
                if pasos > 0 {
                    self.mesActual?.pasosTotales = Int(pasos)
                    try? context.save()
                }
            }
            
            self.healthManager.fetchMonthlyData(for: .distanceWalkingRunning, unit: .meter()) { metros in
                if metros > 0 {
                    self.mesActual?.kmTotales = metros / 1000.0
                    try? context.save()
                }
            }
            
            self.healthManager.fetchMonthlyData(for: .distanceSwimming, unit: .meter()) { metros in
                if metros > 0 {
                    self.mesActual?.metrosTotales = metros
                    try? context.save()
                }
            }
            
            self.healthManager.fetchMonthlyData(for: .activeEnergyBurned, unit: .kilocalorie()) { calorias in
                if calorias > 0 {
                    self.mesActual?.caloriasActivas = calorias
                    try? context.save()
                }
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
    
    var deporteFavorito: (nombre: String, icono: String, color: Color, mensaje: String) {
        guard let actual = mesActual else { return ("Ninguno", "questionmark", .gray, "Registra actividad para ver tu favorito") }
        
        var puntajes: [String: Double] = [:]
        puntajes["Natación"] = actual.metrosTotales > 0 ? (actual.metrosTotales / 1000.0) * 10 : 0
        puntajes["Running"] = actual.kmTotales > 0 ? actual.kmTotales * 5 : 0
        puntajes["Gimnasio"] = actual.tonelajeTotal > 0 ? (actual.tonelajeTotal / 1000.0) * 5 : 0
        
        let favorito = puntajes.max(by: { $0.value < $1.value })
        
        if favorito?.value == 0 || favorito == nil {
            return ("Empezando...", "figure.walk", .aidaNaranja, "¡A movernos este mes!")
        }
        
        switch favorito?.key {
        case "Natación": return ("Natación", "figure.pool.swim", .aidaAzul, "¡Eres como un pez en el agua!")
        case "Running": return ("Running", "figure.run", .greenMint, "¡Imparable en la pista!")
        case "Gimnasio": return ("Gimnasio", "dumbbell.fill", .magentaProfundo, "¡Levantando pesado este mes!")
        default: return ("Activo", "flame.fill", .aidaAcento, "¡Sigue así!")
        }
    }
}
