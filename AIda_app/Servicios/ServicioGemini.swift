import Foundation

// MARK: - ServicioGemini
// Este archivo se conecta con la API de Google Gemini.
//
// ¿Cómo funciona?
// 1. Tomamos las respuestas del usuario (PerfilEntrenamiento)
// 2. Construimos un "prompt" (instrucciones para la IA)
// 3. Enviamos una petición HTTP POST a Gemini
// 4. Recibimos la respuesta en JSON
// 5. Convertimos ese JSON a nuestra estructura RutinaGenerada
//
// Usamos "actor" en vez de "class" porque es más seguro para código
// que hace peticiones de red (evita problemas cuando varias cosas pasan al mismo tiempo).

actor ServicioGemini {
    
    // La API Key se lee del archivo Secrets.plist (que NO se sube a GitHub)
    private let apiKey: String
    
    // La URL base de la API — usamos Gemma 3 12B (gratuito y sin restricciones de quota)
    private let urlBase = "https://generativelanguage.googleapis.com/v1beta/models/gemma-3-12b-it:generateContent"
    
    // El "decodificador" que convierte JSON → estructuras de Swift
    private let decoder = JSONDecoder()
    
    // MARK: - Inicialización
    // Al crear el servicio, lee la API Key del archivo Secrets.plist
    init() {
        // Buscamos el archivo Secrets.plist dentro del bundle de la app
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["GEMINI_API_KEY"] as? String {
            self.apiKey = key
        } else {
            // Si no encuentra el archivo, usa una key vacía (fallará al llamar la API)
            print("⚠️ ERROR: No se encontró Secrets.plist con GEMINI_API_KEY")
            self.apiKey = ""
        }
    }
    
    // MARK: - Generar Rutina
    // Esta es la función principal: recibe el perfil del usuario y devuelve una rutina.
    // Incluye reintentos automáticos si Gemini devuelve error 429 (límite de peticiones).
    func generarRutina(perfil: PerfilEntrenamiento) async throws -> RutinaGenerada {
        
        // Número máximo de reintentos si Gemini dice "demasiadas peticiones"
        let maxReintentos = 3
        
        for intento in 0...maxReintentos {
            do {
                let rutina = try await enviarPeticion(perfil: perfil)
                return rutina
            } catch ErrorGemini.errorAPI(let codigo, let mensaje) where codigo == 429 {
                // Error 429 = "Too Many Requests" (límite de peticiones)
                // Esperamos un poco y reintentamos
                if intento < maxReintentos {
                    let segundosEspera = UInt64(pow(2.0, Double(intento + 1))) // 2, 4, 8 segundos
                    print("⏳ Rate limit (429). Reintentando en \(segundosEspera)s... (intento \(intento + 1)/\(maxReintentos))")
                    try await Task.sleep(nanoseconds: segundosEspera * 1_000_000_000)
                } else {
                    throw ErrorGemini.errorAPI(codigo: codigo, mensaje: mensaje)
                }
            }
        }
        
        // Nunca debería llegar aquí, pero por seguridad:
        throw ErrorGemini.respuestaVacia
    }
    
    // MARK: - Enviar Petición a Gemini
    // Función interna que hace UNA sola petición HTTP
    private func enviarPeticion(perfil: PerfilEntrenamiento) async throws -> RutinaGenerada {
        
        // 1. Construir el prompt (las instrucciones para Gemini)
        let prompt = construirPrompt(perfil: perfil)
        
        // 2. Crear la URL con la API Key
        guard let url = URL(string: "\(urlBase)?key=\(apiKey)") else {
            throw ErrorGemini.urlInvalida
        }
        
        // 3. Crear la petición HTTP
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // POST = enviar datos
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30  // Máximo 30 segundos de espera
        
        // 4. Crear el cuerpo de la petición (lo que le enviamos a Gemini)
        let cuerpo: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 1500
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: cuerpo)
        
        // 5. Enviar la petición y esperar la respuesta
        let (datos, respuesta) = try await URLSession.shared.data(for: request)
        
        // 6. Verificar que la respuesta sea exitosa (código 200)
        guard let httpRespuesta = respuesta as? HTTPURLResponse else {
            throw ErrorGemini.respuestaInvalida
        }
        
        guard httpRespuesta.statusCode == 200 else {
            let mensajeError = String(data: datos, encoding: .utf8) ?? "Error desconocido"
            print("❌ Error de Gemini (código \(httpRespuesta.statusCode)): \(mensajeError)")
            throw ErrorGemini.errorAPI(codigo: httpRespuesta.statusCode, mensaje: mensajeError)
        }
        
        // 7. Extraer el texto de la respuesta de Gemini
        let textoRespuesta = try extraerTextoDeRespuesta(datos: datos)
        
        // 8. Intentar convertir el texto JSON a nuestra estructura RutinaGenerada
        return try parsearRutina(texto: textoRespuesta)
    }
    
    // MARK: - Construir el Prompt
    // El "prompt" son las instrucciones que le damos a Gemini.
    // Entre más específico, mejor resultado.
    private func construirPrompt(perfil: PerfilEntrenamiento) -> String {
        return """
        Eres AIda, una entrenadora fitness profesional y empática que habla en español.
        
        Genera una rutina de ejercicio personalizada basada en este perfil del usuario:
        \(perfil.descripcionParaIA)
        
        IMPORTANTE: Responde ÚNICAMENTE con un JSON válido, sin texto adicional, sin markdown, sin ```json.
        El JSON debe tener exactamente esta estructura:
        {
            "nombre": "Nombre descriptivo de la rutina",
            "duracionEstimada": "X minutos",
            "mensajeMotivacional": "Un mensaje motivacional personalizado y cálido",
            "secciones": [
                {
                    "titulo": "🔥 Calentamiento",
                    "ejercicios": [
                        {
                            "nombre": "Nombre del ejercicio",
                            "detalle": "Duración o repeticiones"
                        }
                    ]
                },
                {
                    "titulo": "💪 Ejercicio Principal",
                    "ejercicios": [
                        {
                            "nombre": "Nombre del ejercicio",
                            "detalle": "Series × repeticiones o duración"
                        }
                    ]
                },
                {
                    "titulo": "🧘 Enfriamiento",
                    "ejercicios": [
                        {
                            "nombre": "Nombre del ejercicio",
                            "detalle": "Duración"
                        }
                    ]
                }
            ]
        }
        
        Reglas:
        - El calentamiento debe tener 3-4 ejercicios
        - El ejercicio principal debe tener 4-6 ejercicios adaptados al objetivo y nivel
        - El enfriamiento debe tener 2-3 ejercicios de estiramiento
        - Si el estado de ánimo es "Estresado" o "Cansado", reduce la intensidad y agrega ejercicios de respiración
        - Adapta los ejercicios al equipo disponible
        - El mensaje motivacional debe ser personalizado según el ánimo del usuario
        """
    }
    
    // MARK: - Extraer texto de la respuesta
    // La respuesta de Gemini viene envuelta en varias capas de JSON.
    // Esta función extrae el texto útil.
    private func extraerTextoDeRespuesta(datos: Data) throws -> String {
        // La estructura de respuesta de Gemini es:
        // { "candidates": [{ "content": { "parts": [{ "text": "..." }] } }] }
        
        guard let json = try JSONSerialization.jsonObject(with: datos) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let primerCandidato = candidates.first,
              let content = primerCandidato["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let primeraParte = parts.first,
              let texto = primeraParte["text"] as? String else {
            throw ErrorGemini.respuestaVacia
        }
        
        return texto
    }
    
    // MARK: - Parsear la Rutina
    // Convierte el texto JSON de Gemini a nuestra estructura RutinaGenerada.
    private func parsearRutina(texto: String) throws -> RutinaGenerada {
        // Limpiamos el texto por si Gemini agrega caracteres extra
        var textoLimpio = texto
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // A veces Gemini envuelve la respuesta en ```json ... ```
        if textoLimpio.hasPrefix("```json") {
            textoLimpio = String(textoLimpio.dropFirst(7))
        }
        if textoLimpio.hasPrefix("```") {
            textoLimpio = String(textoLimpio.dropFirst(3))
        }
        if textoLimpio.hasSuffix("```") {
            textoLimpio = String(textoLimpio.dropLast(3))
        }
        textoLimpio = textoLimpio.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Intentamos decodificar el JSON
        guard let datosJSON = textoLimpio.data(using: .utf8) else {
            throw ErrorGemini.jsonInvalido
        }
        
        do {
            let rutina = try decoder.decode(RutinaGenerada.self, from: datosJSON)
            return rutina
        } catch {
            // Si el JSON no se puede parsear, creamos una rutina con texto libre
            // (así la app no crashea, solo muestra el texto tal cual)
            print("⚠️ No se pudo parsear el JSON de Gemini: \(error)")
            print("📝 Texto recibido: \(textoLimpio)")
            return RutinaGenerada(
                nombre: "Tu Rutina Personalizada",
                secciones: [],
                mensajeMotivacional: "¡Vamos con todo! 💪",
                duracionEstimada: "---",
                textoLibre: textoLimpio
            )
        }
    }
}

// MARK: - Errores personalizados
// Definimos errores específicos para que sea fácil saber qué falló
enum ErrorGemini: LocalizedError {
    case urlInvalida
    case respuestaInvalida
    case respuestaVacia
    case jsonInvalido
    case errorAPI(codigo: Int, mensaje: String)
    
    // Mensajes legibles para el usuario
    var errorDescription: String? {
        switch self {
        case .urlInvalida:
            return "La URL de la API es inválida"
        case .respuestaInvalida:
            return "La respuesta del servidor no es válida"
        case .respuestaVacia:
            return "Gemini no devolvió ninguna respuesta"
        case .jsonInvalido:
            return "No se pudo leer la respuesta de Gemini"
        case .errorAPI(let codigo, _):
            return "Error del servidor (código \(codigo))"
        }
    }
}
