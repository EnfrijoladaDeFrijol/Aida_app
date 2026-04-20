import Foundation

// MARK: - RutinaGenerada
// Esta estructura representa la rutina que Gemini nos devuelve.
//
// ¿Por qué usamos Codable?
// Porque le pedimos a Gemini que responda en formato JSON,
// y Swift puede convertir ese JSON automáticamente a estas estructuras.
// Es como un traductor: JSON de Gemini → objetos de Swift.

struct RutinaGenerada: Codable, Identifiable {
    // Un ID único para identificar cada rutina
    var id: String = UUID().uuidString
    
    // El nombre de la rutina (ej: "Rutina de Fuerza para Principiantes")
    var nombre: String
    
    // Las secciones de la rutina (calentamiento, ejercicio, enfriamiento)
    var secciones: [SeccionRutina]
    
    // Un mensaje motivacional de AIda
    var mensajeMotivacional: String
    
    // Duración estimada total
    var duracionEstimada: String
    
    // Cuando no podemos decodificar el JSON, creamos una rutina de texto libre
    var textoLibre: String?
    
    // Propiedad para no incluir "id" al decodificar desde JSON
    // (Gemini no envía un "id", lo generamos nosotros)
    enum CodingKeys: String, CodingKey {
        case nombre, secciones, mensajeMotivacional, duracionEstimada, textoLibre
    }
}

// MARK: - SeccionRutina
// Cada sección de la rutina (ej: "Calentamiento", "Circuito Principal")
struct SeccionRutina: Codable, Identifiable {
    var id: String = UUID().uuidString
    var titulo: String        // "🔥 Calentamiento"
    var ejercicios: [Ejercicio]
    
    enum CodingKeys: String, CodingKey {
        case titulo, ejercicios
    }
}

// MARK: - Ejercicio
// Un ejercicio individual dentro de una sección
struct Ejercicio: Codable, Identifiable {
    var id: String = UUID().uuidString
    var nombre: String         // "Sentadillas"
    var detalle: String        // "3 series × 12 repeticiones"
    var icono: String?         // SF Symbol opcional (lo asignamos nosotros)
    
    enum CodingKeys: String, CodingKey {
        case nombre, detalle, icono
    }
}

// MARK: - Ejemplo de uso
// Así se vería una rutina completa como datos:
//
// RutinaGenerada(
//     nombre: "Rutina de Fuerza - Principiante",
//     secciones: [
//         SeccionRutina(titulo: "🔥 Calentamiento", ejercicios: [
//             Ejercicio(nombre: "Jumping Jacks", detalle: "2 minutos"),
//             Ejercicio(nombre: "Rotación de hombros", detalle: "20 repeticiones")
//         ]),
//         SeccionRutina(titulo: "💪 Ejercicio Principal", ejercicios: [
//             Ejercicio(nombre: "Sentadillas", detalle: "3 × 12 repeticiones"),
//             Ejercicio(nombre: "Lagartijas", detalle: "3 × 10 repeticiones")
//         ]),
//         SeccionRutina(titulo: "🧘 Enfriamiento", ejercicios: [
//             Ejercicio(nombre: "Estiramiento de piernas", detalle: "30 segundos c/lado")
//         ])
//     ],
//     mensajeMotivacional: "¡Tú puedes! Cada repetición cuenta 💪",
//     duracionEstimada: "30 minutos"
// )
