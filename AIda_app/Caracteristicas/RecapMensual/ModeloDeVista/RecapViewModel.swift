import SwiftUI
import SwiftData

// MARK: - RecapViewModel
// Prepara datos del mes para las 3 slides del Recap.
// Si no hay datos reales, inyecta datos de ejemplo para demo.

@MainActor
class RecapViewModel: ObservableObject {
    
    // MARK: - Datos
    @Published var registro: RegistroMensual?
    @Published var nombreUsuario: String = ""
    @Published var rachaActual: Int = 0
    @Published var rutinasCompletadas: Int = 0
    @Published var isReady: Bool = false
    
    // MARK: - Cargar datos
    
    func cargarDatos(context: ModelContext) {
        let perfil = PerfilUsuario()
        nombreUsuario = perfil.nombre
        rachaActual = perfil.diasDeRacha
        rutinasCompletadas = perfil.rutinasCompletadas
        
        let calendar = Calendar.current
        let ahora = Date()
        let inicioMes = calendar.date(from: calendar.dateComponents([.year, .month], from: ahora))!
        
        let descriptor = FetchDescriptor<RegistroMensual>(sortBy: [SortDescriptor(\.mes, order: .reverse)])
        let todos = (try? context.fetch(descriptor)) ?? []
        
        // Buscar mes actual
        registro = todos.first(where: { calendar.isDate($0.mes, equalTo: inicioMes, toGranularity: .month) })
        
        // Si no hay registro real, usar datos de ejemplo
        if registro == nil || registroEstaVacio(registro!) {
            registro = crearDatosEjemplo(mes: inicioMes)
        }
        
        isReady = true
    }
    
    private func registroEstaVacio(_ reg: RegistroMensual) -> Bool {
        return reg.pasosTotales == 0
            && reg.metrosTotales == 0
            && reg.kmTotales == 0
            && reg.tonelajeTotal == 0
            && reg.caloriasActivas == 0
    }
    
    private func crearDatosEjemplo(mes: Date) -> RegistroMensual {
        return RegistroMensual(
            mes: mes,
            metrosTotales: 4800,
            sesionesNado: 12,
            kmTotales: 47.3,
            elevacionGanada: 320,
            tonelajeTotal: 18500,
            ejercicioPR: "Sentadilla:120",
            pasosTotales: 186420,
            caloriasActivas: 12340,
            conteoEstadosAnimo: [
                "Increíble": 8,
                "Bien": 12,
                "Normal": 5,
                "Cansado": 3,
                "Estresado": 2
            ]
        )
    }
    
    // MARK: - Slide 1: Resumen General
    
    var nombreMes: String {
        guard let reg = registro else { return "MES" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: reg.mes).capitalized
    }
    
    var mesCorto: String {
        guard let reg = registro else { return "MES" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "MMMM"
        return f.string(from: reg.mes).uppercased()
    }
    
    var pasosTotales: Int { registro?.pasosTotales ?? 0 }
    
    var pasosFormateados: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        return f.string(from: NSNumber(value: pasosTotales)) ?? "0"
    }
    
    var caloriasActivas: Double { registro?.caloriasActivas ?? 0 }
    
    var caloriasFormateadas: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.groupingSeparator = ","
        return f.string(from: NSNumber(value: caloriasActivas)) ?? "0"
    }
    
    var kmTotales: Double { registro?.kmTotales ?? 0 }
    
    var kmFormateados: String {
        String(format: "%.1f", kmTotales)
    }
    
    // MARK: - Slide 2: Deporte Estrella
    
    var deporteEstrella: DeporteEstrella {
        guard let reg = registro else {
            return DeporteEstrella(nombre: "Empezando", icono: "figure.walk", color: .orange,
                                   metricaPrincipal: "0", unidadPrincipal: "",
                                   metricaSecundaria: "", unidadSecundaria: "",
                                   emoji: "🚶", mensaje: "¡A movernos!")
        }
        
        var puntajes: [(String, Double)] = []
        puntajes.append(("Natación", reg.metrosTotales > 0 ? (reg.metrosTotales / 1000.0) * 10 : 0))
        puntajes.append(("Running", reg.kmTotales > 0 ? reg.kmTotales * 5 : 0))
        puntajes.append(("Gimnasio", reg.tonelajeTotal > 0 ? (reg.tonelajeTotal / 1000.0) * 5 : 0))
        
        let favorito = puntajes.max(by: { $0.1 < $1.1 })
        
        guard let fav = favorito, fav.1 > 0 else {
            return DeporteEstrella(nombre: "Empezando", icono: "figure.walk", color: .orange,
                                   metricaPrincipal: "0", unidadPrincipal: "",
                                   metricaSecundaria: "", unidadSecundaria: "",
                                   emoji: "🚶", mensaje: "¡Registra actividad!")
        }
        
        switch fav.0 {
        case "Natación":
            return DeporteEstrella(
                nombre: "Natación",
                icono: "figure.pool.swim",
                color: .cyan,
                metricaPrincipal: String(format: "%.0f", reg.metrosTotales),
                unidadPrincipal: "metros",
                metricaSecundaria: "\(reg.sesionesNado)",
                unidadSecundaria: "sesiones",
                emoji: "🏊",
                mensaje: "Pez en el agua"
            )
        case "Running":
            return DeporteEstrella(
                nombre: "Running",
                icono: "figure.run",
                color: .greenMint,
                metricaPrincipal: String(format: "%.1f", reg.kmTotales),
                unidadPrincipal: "km",
                metricaSecundaria: String(format: "%.0f", reg.elevacionGanada),
                unidadSecundaria: "m elevación",
                emoji: "🏃",
                mensaje: "Imparable"
            )
        case "Gimnasio":
            let prParts = reg.ejercicioPR.components(separatedBy: ":")
            let prTexto = prParts.count >= 2 ? "\(prParts[0]) \(prParts[1])kg" : ""
            return DeporteEstrella(
                nombre: "Gimnasio",
                icono: "dumbbell.fill",
                color: .magentaProfundo,
                metricaPrincipal: String(format: "%.0f", reg.tonelajeTotal / 1000),
                unidadPrincipal: "toneladas",
                metricaSecundaria: prTexto,
                unidadSecundaria: "PR del mes",
                emoji: "🏋️",
                mensaje: "Beast mode"
            )
        default:
            return DeporteEstrella(nombre: "Activo", icono: "flame.fill", color: .orange,
                                   metricaPrincipal: "0", unidadPrincipal: "",
                                   metricaSecundaria: "", unidadSecundaria: "",
                                   emoji: "🔥", mensaje: "¡Sigue así!")
        }
    }
    
    // Datos extra natación y running para slide 2
    var metrosNatacion: Double { registro?.metrosTotales ?? 0 }
    var sesionesNado: Int { registro?.sesionesNado ?? 0 }
    var elevacion: Double { registro?.elevacionGanada ?? 0 }
    
    // MARK: - Slide 3: Ánimo
    
    var animoDominante: (tipo: String, conteo: Int, icono: String, color: Color)? {
        guard let reg = registro, !reg.conteoEstadosAnimo.isEmpty else { return nil }
        let dominante = reg.conteoEstadosAnimo.max(by: { $0.value < $1.value })
        guard let dom = dominante else { return nil }
        let tipoAnimo = TipoAnimo(rawValue: dom.key)
        return (
            tipo: dom.key,
            conteo: dom.value,
            icono: tipoAnimo?.icono ?? "face.smiling",
            color: tipoAnimo?.colorAsociado ?? .yellow
        )
    }
    
    var datosAnimoOrdenados: [(nombre: String, conteo: Int, color: Color, icono: String)] {
        guard let reg = registro else { return [] }
        return TipoAnimo.allCases.compactMap { tipo in
            let conteo = reg.conteoEstadosAnimo[tipo.rawValue] ?? 0
            return conteo > 0 ? (nombre: tipo.rawValue, conteo: conteo, color: tipo.colorAsociado, icono: tipo.icono) : nil
        }.sorted(by: { $0.conteo > $1.conteo })
    }
    
    var totalAnimosRegistrados: Int {
        registro?.conteoEstadosAnimo.values.reduce(0, +) ?? 0
    }
    
    var mensajeCierre: String {
        "Hecho con ❤️ por AIda"
    }
}

// MARK: - Modelos de apoyo

struct DeporteEstrella {
    let nombre: String
    let icono: String
    let color: Color
    let metricaPrincipal: String
    let unidadPrincipal: String
    let metricaSecundaria: String
    let unidadSecundaria: String
    let emoji: String
    let mensaje: String
}
