import SwiftUI

enum TipoAnimo: String, CaseIterable, Identifiable, Codable {
    case increible = "Increíble"
    case bien = "Bien"
    case normal = "Normal"
    case cansado = "Cansado"
    case estresado = "Estresado"
    
    var id: String { self.rawValue }
    
    var icono: String {
        switch self {
        case .increible: return "star.fill"
        case .bien: return "sun.max.fill"
        case .normal: return "cloud.sun.fill"
        case .cansado: return "moon.zzz.fill"
        case .estresado: return "cloud.bolt.rain.fill"
        }
    }
    
    var colorAsociado: Color {
        switch self {
        case .increible: return .yellow
        case .bien: return .greenMint
        case .normal: return .cyan
        case .cansado: return .purple
        case .estresado: return .coralEnergetico
        }
    }
}
