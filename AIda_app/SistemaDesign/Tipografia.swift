import SwiftUI

// SistemaDeDiseno/Tipografia.swift

extension Font {
    // --- TÍTULOS Y MÉTRICAS ---
    // Ideal para mostrar "2.5 L" o "10,000 pasos" combinándolo con tu Color.aidaAcento
    static let aidaMetricaGigante = Font.system(size: 48, weight: .heavy, design: .rounded)
    
    // Para los saludos y encabezados principales de cada pantalla
    static let aidaTituloGrande = Font.system(size: 34, weight: .bold, design: .rounded)
    
    // Para títulos de secciones o tarjetas
    static let aidaTitulo = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let aidaSubtitulo = Font.system(size: 20, weight: .medium, design: .rounded)
    
    // --- CUERPOS DE TEXTO ---
    // Para las rutinas de ejercicio generadas por el LLM (facilita la lectura)
    static let aidaCuerpoDestacado = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let aidaCuerpo = Font.system(size: 16, weight: .regular, design: .rounded)
    
    // --- ELEMENTOS DE UI (Interacción) ---
    static let aidaBoton = Font.system(size: 18, weight: .bold, design: .rounded)
    
    // Para las descripciones cortas debajo de los íconos o tags (ej. "Total" en el ánimo)
    static let aidaEtiqueta = Font.system(size: 14, weight: .medium, design: .rounded)
    
    // Para notas al pie, como "Datos obtenidos de Apple Health" combinados con Color.aidaTextoSecundario
    static let aidaNota = Font.system(size: 12, weight: .regular, design: .rounded)
}
