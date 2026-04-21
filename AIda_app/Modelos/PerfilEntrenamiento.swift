import SwiftUI

// MARK: - PerfilEntrenamiento
// Este archivo define TODAS las opciones que el usuario puede elegir
// en el cuestionario antes de que Gemini genere su rutina.
//
// Cada "enum" es una pregunta con opciones fijas.
// Usamos enums porque Swift los hace seguros: no puedes tener un valor inválido.

// MARK: - Pregunta 0: ¿Qué tipo de ejercicio harás hoy?
enum TipoEjercicio: String, CaseIterable, Identifiable, Codable {
    case natacion = "Natación"
    case running = "Running"
    case normal = "Ejercicio normal"
    
    var id: String { self.rawValue }
    
    var icono: String {
        switch self {
        case .natacion: return "figure.pool.swim"
        case .running: return "figure.run"
        case .normal: return "figure.cross.training"
        }
    }
    
    var color: Color {
        switch self {
        case .natacion: return .cyan
        case .running: return .greenMint
        case .normal: return .coralEnergetico
        }
    }
}

// MARK: - Pregunta 1: ¿Cuál es tu objetivo?
enum ObjetivoFitness: String, CaseIterable, Identifiable, Codable {
    // Normal
    case ganarMusculo = "Ganar músculo"
    case bajarPeso = "Bajar de peso"
    case mantenerse = "Mantenerse en forma"
    case flexibilidad = "Mejorar flexibilidad"
    
    // Natacion / Running
    case mejorarTecnica = "Mejorar técnica"
    case resistenciaCardio = "Resistencia cardio"
    case ganarVelocidad = "Ganar velocidad"
    case relajacion = "Relajación activa"
    case prepararseCarrera = "Preparar carrera (5k/10k)"
    case mejorarRitmo = "Mejorar ritmo"
    
    // "id" es necesario para que SwiftUI pueda usar este enum en listas/ForEach
    var id: String { self.rawValue }
    
    // Icono SF Symbol para cada opción (se verá en la UI)
    var icono: String {
        switch self {
        case .ganarMusculo: return "dumbbell.fill"
        case .bajarPeso: return "flame.fill"
        case .mantenerse: return "heart.fill"
        case .flexibilidad: return "figure.flexibility"
        case .mejorarTecnica: return "figure.pool.swim"
        case .resistenciaCardio: return "heart.text.square.fill"
        case .ganarVelocidad: return "bolt.fill"
        case .relajacion: return "water.waves"
        case .prepararseCarrera: return "medal.fill"
        case .mejorarRitmo: return "timer"
        }
    }
    
    // Color asociado para hacer la UI más visual
    var color: Color {
        switch self {
        case .ganarMusculo, .ganarVelocidad: return .coralEnergetico
        case .bajarPeso, .mejorarRitmo: return .orange
        case .mantenerse, .resistenciaCardio: return .greenMint
        case .flexibilidad, .mejorarTecnica, .relajacion: return .cyan
        case .prepararseCarrera: return .magentaProfundo
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
    // Normal
    case sinEquipo = "Sin equipo"
    case mancuernas = "Mancuernas"
    case gymCompleto = "Gym completo"
    // Natacion
    case soloGoggles = "Solo goggles"
    case tablaPullBuoy = "Tabla y Pull Buoy"
    case aletasPaletas = "Aletas y Paletas"
    // Running
    case asfalto = "Asfalto / Calle"
    case cintaCorrer = "Cinta de correr"
    case pistaTrail = "Pista / Naturaleza"
    
    var id: String { self.rawValue }
    
    var icono: String {
        switch self {
        case .sinEquipo, .soloGoggles: return "figure.stand"
        case .mancuernas: return "dumbbell.fill"
        case .gymCompleto: return "building.2.fill"
        case .tablaPullBuoy: return "rectangle.roundedbottom.fill"
        case .aletasPaletas: return "water.waves.and.arrow.up"
        case .asfalto: return "road.lanes"
        case .cintaCorrer: return "figure.run.treadmill"
        case .pistaTrail: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .sinEquipo, .soloGoggles, .pistaTrail: return .greenMint
        case .mancuernas, .tablaPullBuoy, .asfalto: return .orange
        case .gymCompleto, .aletasPaletas, .cintaCorrer: return .coralEnergetico
        }
    }
}

// MARK: - PerfilEntrenamiento (agrupa todas las respuestas)
// Esta estructura junta TODAS las respuestas del cuestionario.
// Cuando el usuario termine de contestar, empaquetamos todo aquí
// y se lo enviamos a Gemini para que genere la rutina.
struct PerfilEntrenamiento {
    var tipoEjercicio: TipoEjercicio?
    var objetivo: ObjetivoFitness?
    var nivel: NivelExperiencia?
    var duracion: DuracionRutina?
    var equipo: EquipoDisponible?
    var animo: TipoAnimo?  // Se toma del ánimo ya registrado del día
    
    // Verifica que el usuario haya contestado TODO antes de generar
    var estaCompleto: Bool {
        tipoEjercicio != nil && objetivo != nil && nivel != nil && duracion != nil && equipo != nil
    }
    
    // Convierte las respuestas en texto para enviar a Gemini
    var descripcionParaIA: String {
        """
        Tipo de Ejercicio: \(tipoEjercicio?.rawValue ?? "No especificado")
        Objetivo: \(objetivo?.rawValue ?? "No especificado")
        Nivel de experiencia: \(nivel?.rawValue ?? "No especificado")
        Duración disponible: \(duracion?.rawValue ?? "No especificado")
        Equipo disponible: \(equipo?.rawValue ?? "No especificado")
        Estado de ánimo actual: \(animo?.rawValue ?? "No especificado")
        """
    }
}
