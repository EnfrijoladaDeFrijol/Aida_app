import SwiftUI

// MARK: - InicioViewModel
// Centraliza toda la lógica de la pantalla de Inicio.
// Las vistas solo se encargan de mostrar datos, este ViewModel los gestiona.

@Observable
class InicioViewModel {
    
    // MARK: - Estado de la UI
    var animoDelDia: TipoAnimo? = nil
    var mostrarRegistroAnimo: Bool = false
    
    // MARK: - Métricas del Día (por ahora estáticas, luego vendrán de HealthKit)
    var litrosAgua: Double = 1.2
    var metaAgua: Double = 2.5
    var pasos: Int = 3200
    var metaPasos: Int = 10000
    
    // MARK: - IA
    var insightIA: String = "Pareces un poco estresado hoy. Solo llevas el 30% de tu meta de agua, ¡vamos a hidratarnos!"
    var estaCargandoInsight: Bool = false
    
    // MARK: - Propiedades Calculadas
    
    var saludo: String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 6..<12: return "Buenos días"
        case 12..<19: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }
    
    var nombreUsuario: String {
        // TODO: Obtener del perfil del usuario cuando se implemente
        return "Arturo"
    }
    
    var tituloNavegacion: String {
        "Hola, \(nombreUsuario) 👋"
    }
    
    var progresoAgua: Double {
        min(litrosAgua / metaAgua, 1.0)
    }
    
    var textoAgua: String {
        String(format: "%.1f L", litrosAgua)
    }
    
    var subtituloAgua: String {
        String(format: "de %.1f L", metaAgua)
    }
    
    var progresoPasos: Double {
        min(Double(pasos) / Double(metaPasos), 1.0)
    }
    
    var textoPasos: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: pasos)) ?? "\(pasos)"
    }
    
    var subtituloPasos: String {
        "Meta: \(metaPasos / 1000)k"
    }
    
    // MARK: - Acciones
    
    func cargarAnimoGuardado() {
        // Lee de UserDefaults (AppStorage) para sincronizar
        let guardado = UserDefaults.standard.string(forKey: "animoDelDia") ?? ""
        if let tipo = TipoAnimo(rawValue: guardado) {
            animoDelDia = tipo
        }
    }
    
    func abrirRegistroAnimo() {
        mostrarRegistroAnimo = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - IA (se conectará a la API en la Fase 2)
    
    func solicitarInsight() async {
        estaCargandoInsight = true
        
        // TODO: Fase 2 - Conectar con ServicioIA
        // let contexto = ContextoUsuario(animo: animoDelDia, agua: litrosAgua, pasos: pasos)
        // insightIA = try await servicioIA.generarInsightDiario(contexto: contexto)
        
        // Por ahora simulamos un delay
        try? await Task.sleep(for: .seconds(1))
        estaCargandoInsight = false
    }
}
