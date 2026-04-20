import Foundation
import SwiftData

@Model
final class RegistroMensual {
    var id: UUID
    var mes: Date // (inicio del mes)
    
    // Natación
    var metrosTotales: Double
    var sesionesNado: Int
    
    // Running
    var kmTotales: Double
    var elevacionGanada: Double
    
    // Gimnasio
    var tonelajeTotal: Double
    var ejercicioPR: String // "Ejercicio:Peso"
    
    // Lifestyle
    var pasosTotales: Int
    var caloriasActivas: Double
    
    // Mood
    var conteoEstadosAnimo: [String: Int]
    
    init(mes: Date = Date(), 
         metrosTotales: Double = 0, 
         sesionesNado: Int = 0, 
         kmTotales: Double = 0, 
         elevacionGanada: Double = 0, 
         tonelajeTotal: Double = 0, 
         ejercicioPR: String = "", 
         pasosTotales: Int = 0, 
         caloriasActivas: Double = 0, 
         conteoEstadosAnimo: [String: Int] = [:]) {
        self.id = UUID()
        self.mes = mes
        self.metrosTotales = metrosTotales
        self.sesionesNado = sesionesNado
        self.kmTotales = kmTotales
        self.elevacionGanada = elevacionGanada
        self.tonelajeTotal = tonelajeTotal
        self.ejercicioPR = ejercicioPR
        self.pasosTotales = pasosTotales
        self.caloriasActivas = caloriasActivas
        self.conteoEstadosAnimo = conteoEstadosAnimo
    }
}
