import SwiftUI
import SwiftData

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
    
    /// Guarda el ánimo seleccionado y retorna true si se guardó exitosamente.
    /// También actualiza el conteo de estados de ánimo en el RegistroMensual para el Recap.
    func guardarAnimo(context: ModelContext? = nil) -> Bool {
        guard let animo = animoSeleccionado else { return false }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        // Guardar en UserDefaults (comportamiento original)
        let claveHoy = PerfilUsuario.claveParaFecha(Date())
        let yaRegistradoHoy = UserDefaults.standard.string(forKey: claveHoy) != nil
        
        UserDefaults.standard.set(animo.rawValue, forKey: "animoDelDia")
        UserDefaults.standard.set(animo.rawValue, forKey: claveHoy)
        
        // Actualizar conteo mensual en RegistroMensual (para el Recap)
        if let context = context, !yaRegistradoHoy {
            actualizarConteoMensual(animo: animo, context: context)
        }
        
        return true
    }
    
    /// Actualiza el conteoEstadosAnimo del RegistroMensual del mes actual
    private func actualizarConteoMensual(animo: TipoAnimo, context: ModelContext) {
        let calendar = Calendar.current
        let inicioMes = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        
        let descriptor = FetchDescriptor<RegistroMensual>(sortBy: [SortDescriptor(\.mes, order: .reverse)])
        guard let todos = try? context.fetch(descriptor) else { return }
        
        let registroActual = todos.first(where: { calendar.isDate($0.mes, equalTo: inicioMes, toGranularity: .month) })
        
        if let registro = registroActual {
            let clave = animo.rawValue
            registro.conteoEstadosAnimo[clave, default: 0] += 1
            try? context.save()
        }
    }
}
