import SwiftUI

// MARK: - RegistroAnimoViewModel
// Maneja la lógica de selección y guardado del estado de ánimo.

@Observable
class RegistroAnimoViewModel {
    
    // MARK: - Estado
    var animoSeleccionado: TipoAnimo? = nil
    
    // MARK: - Propiedades Calculadas
    
    var saludo: String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 6..<12: return "¡Buenos días!"
        case 12..<19: return "¡Buenas tardes!"
        default: return "¡Buenas noches!"
        }
    }
    
    var textoBoton: String {
        animoSeleccionado == nil ? "Selecciona tu estado" : "Guardar mi ánimo"
    }
    
    var puedeGuardar: Bool {
        animoSeleccionado != nil
    }
    
    var colorBoton: Color {
        animoSeleccionado?.colorAsociado ?? Color.gray.opacity(0.3)
    }
    
    var colorSombraBoton: Color {
        animoSeleccionado?.colorAsociado.opacity(0.4) ?? .clear
    }
    
    var colorFondoDinamico: Color {
        if let seleccionado = animoSeleccionado {
            return seleccionado.colorAsociado.opacity(0.12)
        }
        return Color.rosaBruma.opacity(0.6)
    }
    
    // MARK: - Acciones
    
    func seleccionarAnimo(_ animo: TipoAnimo) {
        animoSeleccionado = animo
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func cargarAnimoGuardado() {
        let guardado = UserDefaults.standard.string(forKey: "animoDelDia") ?? ""
        if let tipo = TipoAnimo(rawValue: guardado) {
            animoSeleccionado = tipo
        }
    }
    
    /// Guarda el ánimo seleccionado y retorna true si se guardó exitosamente
    func guardarAnimo() -> Bool {
        guard let animo = animoSeleccionado else { return false }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        UserDefaults.standard.set(animo.rawValue, forKey: "animoDelDia")
        return true
    }
}
