import SwiftUI

// MARK: - PerfilUsuario
// Guarda la información personal del usuario y sus preferencias.
// Usa @AppStorage para persistir en UserDefaults (simple y efectivo para un MVP).

@Observable
class PerfilUsuario {
    
    // MARK: - Datos Personales
    var nombre: String {
        get { UserDefaults.standard.string(forKey: "perfil_nombre") ?? "Arturo" }
        set { UserDefaults.standard.set(newValue, forKey: "perfil_nombre") }
    }
    
    var edad: Int {
        get { UserDefaults.standard.integer(forKey: "perfil_edad").nonZero ?? 22 }
        set { UserDefaults.standard.set(newValue, forKey: "perfil_edad") }
    }
    
    var pesoKg: Double {
        get {
            let val = UserDefaults.standard.double(forKey: "perfil_peso")
            return val > 0 ? val : 70.0
        }
        set { UserDefaults.standard.set(newValue, forKey: "perfil_peso") }
    }
    
    var alturaCm: Int {
        get { UserDefaults.standard.integer(forKey: "perfil_altura").nonZero ?? 170 }
        set { UserDefaults.standard.set(newValue, forKey: "perfil_altura") }
    }
    
    // MARK: - Estadísticas de Uso
    var diasDeRacha: Int {
        get { UserDefaults.standard.integer(forKey: "perfil_racha") }
        set { UserDefaults.standard.set(newValue, forKey: "perfil_racha") }
    }
    
    var rutinasCompletadas: Int {
        get { UserDefaults.standard.integer(forKey: "perfil_rutinas_completadas") }
        set { UserDefaults.standard.set(newValue, forKey: "perfil_rutinas_completadas") }
    }
    
    var animosRegistrados: Int {
        get { UserDefaults.standard.integer(forKey: "perfil_animos_registrados") }
        set { UserDefaults.standard.set(newValue, forKey: "perfil_animos_registrados") }
    }
    
    // MARK: - Historial de Ánimos (últimos 7 días)
    // Guardamos como un array de strings con formato "fecha:animo"
    var historialAnimosSemana: [(dia: String, animo: TipoAnimo?)] {
        let calendario = Calendar.current
        let hoy = Date()
        
        return (0..<7).reversed().map { diasAtras in
            let fecha = calendario.date(byAdding: .day, value: -diasAtras, to: hoy)!
            let clave = Self.claveParaFecha(fecha)
            let diaAbreviado = Self.diaAbreviado(fecha)
            
            if let guardado = UserDefaults.standard.string(forKey: clave),
               let tipo = TipoAnimo(rawValue: guardado) {
                return (dia: diaAbreviado, animo: tipo)
            }
            return (dia: diaAbreviado, animo: nil)
        }
    }
    
    // MARK: - Ánimo Actual
    var animoActual: TipoAnimo? {
        let guardado = UserDefaults.standard.string(forKey: "animoDelDia") ?? ""
        return TipoAnimo(rawValue: guardado)
    }
    
    // MARK: - Propiedades Calculadas
    
    var imc: Double {
        let alturaM = Double(alturaCm) / 100.0
        guard alturaM > 0 else { return 0 }
        return pesoKg / (alturaM * alturaM)
    }
    
    var categoriaIMC: String {
        switch imc {
        case ..<18.5: return "Bajo peso"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Sobrepeso"
        default: return "Obesidad"
        }
    }
    
    var colorIMC: Color {
        switch imc {
        case ..<18.5: return .cyan
        case 18.5..<25: return .greenMint
        case 25..<30: return .orange
        default: return .coralEnergetico
        }
    }
    
    var iniciales: String {
        let partes = nombre.split(separator: " ")
        if partes.count >= 2 {
            return "\(partes[0].prefix(1))\(partes[1].prefix(1))".uppercased()
        }
        return String(nombre.prefix(2)).uppercased()
    }
    
    var gradienteAnimo: [Color] {
        if let animo = animoActual {
            return [animo.colorAsociado, animo.colorAsociado.opacity(0.6)]
        }
        return [.coralEnergetico, .magentaProfundo]
    }
    
    // MARK: - Helpers
    
    static func claveParaFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "animo_\(formatter.string(from: fecha))"
    }
    
    static func diaAbreviado(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "EEE"
        let dia = formatter.string(from: fecha)
        return dia.prefix(1).uppercased() + dia.dropFirst().prefix(1)
    }
}

// MARK: - Extension Helper
extension Int {
    var nonZero: Int? {
        self != 0 ? self : nil
    }
}
