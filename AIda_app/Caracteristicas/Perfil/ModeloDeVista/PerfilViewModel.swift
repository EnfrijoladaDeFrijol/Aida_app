import SwiftUI

// MARK: - PerfilViewModel
// Controla toda la lógica de la pantalla de perfil:
// datos del usuario, estadísticas, edición de perfil, y el historial de ánimos.

@Observable
class PerfilViewModel {
    
    // MARK: - Estado
    var perfil = PerfilUsuario()
    var mostrarEditorPerfil = false
    var mostrarAlertaReset = false
    
    // Campos temporales para edición (no se guardan hasta confirmar)
    var nombreEditando: String = ""
    var edadEditando: String = ""
    var pesoEditando: String = ""
    var alturaEditando: String = ""
    
    // MARK: - Propiedades Calculadas
    
    var saludo: String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 6..<12: return "Buenos días"
        case 12..<19: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }
    
    var fraseMotivacional: String {
        guard let animo = perfil.animoActual else {
            return "¿Cómo te sientes hoy? Registra tu ánimo 💫"
        }
        switch animo {
        case .increible: return "¡Estás imparable hoy! 🌟"
        case .bien: return "Buen día para superarse 💪"
        case .normal: return "Cada paso cuenta, sigue así 🚶"
        case .cansado: return "Descansa bien, mañana será mejor 🌙"
        case .estresado: return "Respira profundo, tú puedes 🧘"
        }
    }
    
    var porcentajeSemanaCubierta: Double {
        let diasConAnimo = perfil.historialAnimosSemana.filter { $0.animo != nil }.count
        return Double(diasConAnimo) / 7.0
    }
    
    // MARK: - Acciones
    
    func prepararEdicion() {
        nombreEditando = perfil.nombre
        edadEditando = "\(perfil.edad)"
        pesoEditando = String(format: "%.1f", perfil.pesoKg)
        alturaEditando = "\(perfil.alturaCm)"
        mostrarEditorPerfil = true
    }
    
    func guardarEdicion() {
        perfil.nombre = nombreEditando.isEmpty ? perfil.nombre : nombreEditando
        if let edad = Int(edadEditando), edad > 0 { perfil.edad = edad }
        if let peso = Double(pesoEditando), peso > 0 { perfil.pesoKg = peso }
        if let altura = Int(alturaEditando), altura > 0 { perfil.alturaCm = altura }
        mostrarEditorPerfil = false
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func cancelarEdicion() {
        mostrarEditorPerfil = false
    }
}
