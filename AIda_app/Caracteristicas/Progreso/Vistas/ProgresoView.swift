import SwiftUI
import SwiftData
import Charts

struct ProgresoView: View {
    @StateObject private var viewModel = ProgresoViewModel()
    @Environment(\.modelContext) private var context
    
    let columnas = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if let actual = viewModel.mesActual {
                        let historial = Array(viewModel.mesesAnteriores.prefix(3).reversed()) + [actual]
                        
                        // --- 1. Deporte Favorito ---
                        SeccionDeporteFavorito(viewModel: viewModel)
                        
                        // --- 2. Natación (2 Gráficas) ---
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🏊‍♂️ Natación")
                                .font(.aidaSubtitulo)
                                .foregroundColor(.aidaTextoPrincipal)
                            
                            LazyVGrid(columns: columnas, spacing: 16) {
                                MiniGraficaView(
                                    titulo: "Metros",
                                    color: .aidaAzul,
                                    data: historial.map { (formatearMes($0.mes), $0.metrosTotales) }
                                )
                                MiniGraficaView(
                                    titulo: "Sesiones",
                                    color: .cyan,
                                    data: historial.map { (formatearMes($0.mes), Double($0.sesionesNado)) }
                                )
                            }
                        }
                        
                        // --- 3. Running (2 Gráficas) ---
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🏃‍♂️ Running & Lifestyle")
                                .font(.aidaSubtitulo)
                                .foregroundColor(.aidaTextoPrincipal)
                            
                            LazyVGrid(columns: columnas, spacing: 16) {
                                MiniGraficaView(
                                    titulo: "Kilómetros",
                                    color: .greenMint,
                                    data: historial.map { (formatearMes($0.mes), $0.kmTotales) }
                                )
                                MiniGraficaView(
                                    titulo: "Pasos",
                                    color: .aidaVerde,
                                    data: historial.map { (formatearMes($0.mes), Double($0.pasosTotales)) }
                                )
                            }
                        }
                        
                        // --- 4. Gimnasio (2 Gráficas) ---
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🏋️‍♂️ Gimnasio")
                                .font(.aidaSubtitulo)
                                .foregroundColor(.aidaTextoPrincipal)
                            
                            LazyVGrid(columns: columnas, spacing: 16) {
                                MiniGraficaView(
                                    titulo: "Tonelaje (kg)",
                                    color: .magentaProfundo,
                                    data: historial.map { (formatearMes($0.mes), $0.tonelajeTotal) }
                                )
                                MiniGraficaView(
                                    titulo: "Calorías Activas",
                                    color: .aidaNaranja,
                                    data: historial.map { (formatearMes($0.mes), $0.caloriasActivas) }
                                )
                            }
                        }
                        
                    } else {
                        ProgressView("Cargando tu progreso...")
                            .padding(.top, 50)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .navigationTitle("Mi Progreso")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.mostrarRegistroManual = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.aidaAcento)
                    }
                }
            }
            .sheet(isPresented: $viewModel.mostrarRegistroManual) {
                RegistroMetricasManualView(viewModel: viewModel)
            }
            .background(Color.aidaFondo.ignoresSafeArea())
            .onAppear {
                viewModel.inicializarDatos(context: context)
            }
        }
    }
    
    private func formatearMes(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: fecha).capitalized
    }
}

// MARK: - Componentes de UI

struct SeccionDeporteFavorito: View {
    @ObservedObject var viewModel: ProgresoViewModel
    
    var body: some View {
        let fav = viewModel.deporteFavorito
        
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(fav.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: fav.icono)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(fav.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Deporte Favorito")
                    .font(.aidaCuerpoDestacado)
                    .foregroundColor(.aidaTextoSecundario)
                
                Text(fav.nombre)
                    .font(.aidaMetricaGigante)
                    .foregroundColor(.aidaTextoPrincipal)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Text(fav.mensaje)
                    .font(.aidaCuerpo)
                    .foregroundColor(fav.color)
            }
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.aidaSuperficie)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(fav.color.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: fav.color.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

struct MiniGraficaView: View {
    let titulo: String
    let color: Color
    let data: [(String, Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titulo)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.aidaTextoPrincipal)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            let maximo = data.map { $0.1 }.max() ?? 1
            let limiteY = maximo == 0 ? 1 : maximo
            
            Chart {
                ForEach(data, id: \.0) { item in
                    BarMark(
                        x: .value("Mes", item.0),
                        y: .value("Valor", item.1)
                    )
                    .foregroundStyle(color.gradient)
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .semibold))
                }
            }
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...limiteY * 1.1)
            .frame(height: 100)
            
            // Valor actual abajo
            if let valorActual = data.last?.1 {
                let formateado = valorActual > 1000 && titulo != "Metros" && titulo != "Pasos" && titulo != "Calorías Activas" 
                    ? String(format: "%.1fk", valorActual / 1000) 
                    : (titulo == "Sesiones" ? String(format: "%.0f", valorActual) : String(format: "%.1f", valorActual))
                
                Text(formateado)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(color)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.aidaSuperficie)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}
