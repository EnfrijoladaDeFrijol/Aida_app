import SwiftUI

// MARK: - RutinaViewModel
// Este es el "cerebro" de toda la feature de Rutinas.
//
// Controla:
// 1. El flujo del cuestionario (qué paso va el usuario)
// 2. Las respuestas del usuario (PerfilEntrenamiento)
// 3. La comunicación con Gemini (pedir rutina)
// 4. El estado de la UI (cargando, error, éxito)
//
// La vista simplemente OBSERVA este ViewModel y reacciona a sus cambios.

@Observable
class RutinaViewModel {
    
    // MARK: - Estado del Flujo
    // Controla en qué pantalla estamos
    enum EstadoFlujo {
        case cuestionario   // Respondiendo preguntas
        case generando      // Esperando a Gemini
        case rutinaLista    // Mostrando la rutina
        case error          // Algo salió mal
    }
    
    var estado: EstadoFlujo = .cuestionario
    
    // MARK: - Cuestionario
    // El paso actual del cuestionario (0 = objetivo, 1 = nivel, etc.)
    var pasoActual: Int = 0
    
    // Las respuestas del usuario se guardan aquí
    var perfil = PerfilEntrenamiento()
    
    // Total de pasos en el cuestionario
    let totalPasos = 4
    
    // MARK: - Resultado
    // La rutina generada por Gemini
    var rutinaGenerada: RutinaGenerada? = nil
    
    // Mensaje de error si algo falla
    var mensajeError: String = ""
    
    // MARK: - Servicio de IA
    private let servicioGemini = ServicioGemini()
    
    // MARK: - Propiedades Calculadas
    
    var progresoCuestionario: Double {
        Double(pasoActual + 1) / Double(totalPasos)
    }
    
    var tituloPasoActual: String {
        switch pasoActual {
        case 0: return "¿Cuál es tu objetivo?"
        case 1: return "¿Cuál es tu nivel?"
        case 2: return "¿Cuánto tiempo tienes?"
        case 3: return "¿Qué equipo tienes?"
        default: return ""
        }
    }
    
    var subtituloPasoActual: String {
        switch pasoActual {
        case 0: return "Elige lo que mejor describe tu meta"
        case 1: return "Sé honesto, ¡no hay respuesta incorrecta!"
        case 2: return "Adaptaremos la rutina a tu tiempo"
        case 3: return "Usaremos lo que tengas disponible"
        default: return ""
        }
    }
    
    // ¿Puede avanzar al siguiente paso? (ya seleccionó algo)
    var puedeAvanzar: Bool {
        switch pasoActual {
        case 0: return perfil.objetivo != nil
        case 1: return perfil.nivel != nil
        case 2: return perfil.duracion != nil
        case 3: return perfil.equipo != nil
        default: return false
        }
    }
    
    var esUltimoPaso: Bool {
        pasoActual == totalPasos - 1
    }
    
    // MARK: - Acciones
    
    func avanzarPaso() {
        if esUltimoPaso {
            // Si es el último paso, generamos la rutina
            generarRutina()
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                pasoActual += 1
            }
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func retrocederPaso() {
        if pasoActual > 0 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                pasoActual -= 1
            }
        }
    }
    
    func generarRutina() {
        // Cargamos el ánimo guardado del día (si existe)
        let animoGuardado = UserDefaults.standard.string(forKey: "animoDelDia") ?? ""
        if let animo = TipoAnimo(rawValue: animoGuardado) {
            perfil.animo = animo
        }
        
        estado = .generando
        
        // Llamamos a Gemini en un Task asíncrono (no bloquea la UI)
        Task { @MainActor in
            do {
                let rutina = try await servicioGemini.generarRutina(perfil: perfil)
                self.rutinaGenerada = rutina
                self.estado = .rutinaLista
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                self.mensajeError = error.localizedDescription
                self.estado = .error
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                print("❌ Error generando rutina: \(error)")
            }
        }
    }
    
    func regenerarRutina() {
        rutinaGenerada = nil
        rutinaCompletada = false
        generarRutina()
    }
    
    func reiniciarCuestionario() {
        withAnimation {
            pasoActual = 0
            perfil = PerfilEntrenamiento()
            rutinaGenerada = nil
            rutinaCompletada = false
            mensajeError = ""
            estado = .cuestionario
        }
    }
    
    // MARK: - Completar Rutina (Racha)
    
    /// Indica si la rutina actual ya fue completada
    var rutinaCompletada: Bool = false
    
    /// Marca la rutina como completada y actualiza la racha
    func completarRutina() {
        guard !rutinaCompletada else { return }
        
        rutinaCompletada = true
        GestorRacha.compartido.registrarEjercicioHoy()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
