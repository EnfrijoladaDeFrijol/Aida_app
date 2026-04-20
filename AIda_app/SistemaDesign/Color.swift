import SwiftUI

// SistemaDeDiseno/Colores.swift
// ÚNICO archivo donde se definen TODOS los colores de AIda.

extension Color {
    
    // MARK: - Base del Sistema
    static let aidaFondo = Color(UIColor.systemBackground)
    static let aidaSuperficie = Color(UIColor.secondarySystemBackground)
    static let aidaTextoPrincipal = Color.primary
    static let aidaTextoSecundario = Color.secondary
    
    // MARK: - Paleta Principal de AIda
    static let rosaBruma = Color(red: 1.0, green: 0.96, blue: 0.96)
    static let coralEnergetico = Color(red: 1.0, green: 0.42, blue: 0.42)
    static let magentaProfundo = Color(red: 0.79, green: 0.09, blue: 0.29)
    static let greenMint = Color(red: 0.45, green: 0.92, blue: 0.76)
    static let grisPizarra = Color(red: 0.18, green: 0.2, blue: 0.21)
    
    // MARK: - Colores Semánticos
    static let aidaNaranja = Color.orange
    static let aidaVerde = Color.green
    static let aidaRojo = Color.red
    static let aidaGris = Color.gray
    static let aidaAzul = Color.blue
    static let aidaAcento = Color.purple // Color principal de botones/acciones
}
