import Foundation

enum CategoriaProgreso: String, Codable, CaseIterable {
    case semanal = "Semanal"
    case mensual = "Mensual"
    case anual = "Anual"
}

struct FotoProgreso: Identifiable, Codable {
    var id: String = UUID().uuidString
    var fecha: Date
    var categoria: CategoriaProgreso
    var nombreArchivo: String
    var nota: String?
}
