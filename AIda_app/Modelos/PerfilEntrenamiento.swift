import SwiftUI

// MARK: - PerfilEntrenamiento
// Este archivo define TODAS las opciones que el usuario puede elegir
// en el cuestionario antes de que Gemini genere su rutina.
//
// Cada "enum" es una pregunta con opciones fijas.
// Usamos enums porque Swift los hace seguros: no puedes tener un valor inválido.

// MARK: - Pregunta 1: ¿Cuál es tu objetivo?
enum ObjetivoFitness: String, CaseIterable, Identifiable, Codable {
    case ganarMusculo = "Ganar músculo"
    case bajarPeso = "Bajar de peso"
    case mantenerse = "Mantenerse en forma"
    case flexibilidad = "Mejorar flexibilidad"
    
    // "id" es necesario para que SwiftUI pueda usar este enum en listas/ForEach
    var id: String { self.rawValue }
    
    // Icono SF Symbol para cada opción (se verá en la UI)
    var icono: String {
        switch self {
        case .ganarMusculo: return "dumbbell.fill"
        case .bajarPeso: return "flame.fill"
        case .mantenerse: return "heart.fill"
        case .flexibilidad: return "figure.flexibility"
        }
    }
    
    // Color asociado para hacer la UI más visual
    var color: Color {
        switch self {
        case .ganarMusculo: return .coralEnergetico
        case .bajarPeso: return .orange
        case .mantenerse: return .greenMint
        case .flexibilidad: return .cyan
        }
    }
}

// MARK: - Pregunta 2: ¿Cuál es tu nivel?
enum NivelExperiencia: String, CaseIterable, Identifiable, Codable {
    case principiante = "Principiante"
    case intermedio = "Intermedio"
    case avanzado = "Avanzado"
    
    var id: String { self.rawValue }
    
    var icono: String {
        switch self {
        case .principiante: return "figure.walk"
        case .intermedio: return "figure.run"
        case .avanzado: return "figure.highintensity.intervaltraining"
        }
    }
    
    var color: Color {
        switch self {
        case .principiante: return .greenMint
        case .intermedio: return .orange
        case .avanzado: return .coralEnergetico
        }
    }
}

// MARK: - Pregunta 3: ¿Cuánto tiempo tienes?
enum DuracionRutina: String, CaseIterable, Identifiable, Codable {
    case quince = "15 min"
    case treinta = "30 min"
    case cuarentaCinco = "45 min"
    case sesenta = "60 min"
    
    var id: String { self.rawValue }
    
    var icono: String { "clock.fill" }
    
    var color: Color {
        switch self {
        case .quince: return .cyan
        case .treinta: return .greenMint
        case .cuarentaCinco: return .orange
        case .sesenta: return .coralEnergetico
        }
    }
}

// MARK: - Pregunta 4: ¿Qué equipo tienes disponible?
enum EquipoDisponible: String, CaseIterable, Identifiable, Codable {
    case sinEquipo = "Sin equipo"
    case mancuernas = "Mancuernas"
    case gymCompleto = "Gym completo"
    
    var id: String { self.rawValue }
    
    var icono: String {
        switch self {
        case .sinEquipo: return "figure.stand"
        case .mancuernas: return "dumbbell.fill"
        case .gymCompleto: return "building.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .sinEquipo: return .greenMint
        case .mancuernas: return .orange
        case .gymCompleto: return .coralEnergetico
        }
    }
}

// MARK: - PerfilEntrenamiento (agrupa todas las respuestas)
// Esta estructura junta TODAS las respuestas del cuestionario.
// Cuando el usuario termine de contestar, empaquetamos todo aquí
// y se lo enviamos a Gemini para que genere la rutina.
struct PerfilEntrenamiento {
    var objetivo: ObjetivoFitness?
    var nivel: NivelExperiencia?
    var duracion: DuracionRutina?
    var equipo: EquipoDisponible?
    var animo: TipoAnimo?  // Se toma del ánimo ya registrado del día
    
    // Verifica que el usuario haya contestado TODO antes de generar
    var estaCompleto: Bool {
        objetivo != nil && nivel != nil && duracion != nil && equipo != nil
    }
    
    // Convierte las respuestas en texto para enviar a Gemini
    var descripcionParaIA: String {
        """
        Objetivo: \(objetivo?.rawValue ?? "No especificado")
        Nivel de experiencia: \(nivel?.rawValue ?? "No especificado")
        Duración disponible: \(duracion?.rawValue ?? "No especificado")
        Equipo disponible: \(equipo?.rawValue ?? "No especificado")
        Estado de ánimo actual: \(animo?.rawValue ?? "No especificado")
        """
    }
}
