import SwiftUI
import SwiftData
import Charts

struct ProgresoView: View {
    @StateObject private var viewModel = ProgresoViewModel()
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if let actual = viewModel.mesActual {
                        let anterior = viewModel.mesesAnteriores.first
                        
                        // Tarjeta: Pasos Totales
                        TarjetaMetrica(
                            titulo: "Pasos Totales",
                            valor: "\(actual.pasosTotales)",
                            unidad: "pasos",
                            icono: "shoeprints.fill",
                            valorAnterior: Double(anterior?.pasosTotales ?? 0),
                            valorActual: Double(actual.pasosTotales),
                            viewModel: viewModel
                        )
                        
                        // Tarjeta: Distancia Running
                        TarjetaMetrica(
                            titulo: "Distancia Recorrida",
                            valor: String(format: "%.1f", actual.kmTotales),
                            unidad: "km",
                            icono: "figure.run",
                            valorAnterior: anterior?.kmTotales ?? 0,
                            valorActual: actual.kmTotales,
                            viewModel: viewModel
                        )
                        
                        // Gráfica Comparativa (Últimos 3 Meses + Actual)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Comparativa de Distancia (Últimos Meses)")
                                .font(.aidaSubtitulo)
                                .foregroundColor(.aidaTextoPrincipal)
                            
                            Chart {
                                // Historial
                                let ultimos = Array(viewModel.mesesAnteriores.prefix(3).reversed())
                                ForEach(ultimos) { registro in
                                    BarMark(
                                        x: .value("Mes", formatearMes(registro.mes)),
                                        y: .value("Kilómetros", registro.kmTotales)
                                    )
                                    .foregroundStyle(Color.aidaAcento.opacity(0.6))
                                }
                                
                                // Mes Actual
                                BarMark(
                                    x: .value("Mes", "Actual"),
                                    y: .value("Kilómetros", actual.kmTotales)
                                )
                                .foregroundStyle(Color.aidaAcento)
                            }
                            .frame(height: 180)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.aidaSuperficie)
                                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                        )
                        
                        // Tarjeta: Gimnasio
                        TarjetaMetrica(
                            titulo: "Tonelaje Levantado",
                            valor: String(format: "%.0f", actual.tonelajeTotal),
                            unidad: "kg",
                            icono: "dumbbell.fill",
                            valorAnterior: anterior?.tonelajeTotal ?? 0,
                            valorActual: actual.tonelajeTotal,
                            viewModel: viewModel
                        )
                        
                    } else {
                        ProgressView("Cargando tu progreso...")
                            .padding(.top, 50)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .navigationTitle("Mi Progreso")
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

struct TarjetaMetrica: View {
    let titulo: String
    let valor: String
    let unidad: String
    let icono: String
    let valorAnterior: Double
    let valorActual: Double
    let viewModel: ProgresoViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icono)
                    .font(.title2)
                    .foregroundColor(.aidaAcento)
                
                Text(titulo)
                    .font(.aidaSubtitulo)
                    .foregroundColor(.aidaTextoPrincipal)
                
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(valor)
                    .font(.aidaMetricaGigante)
                    .foregroundColor(.aidaTextoPrincipal)
                
                Text(unidad)
                    .font(.aidaCuerpoDestacado)
                    .foregroundColor(.aidaTextoSecundario)
            }
            
            let variacion = viewModel.calcularVariacion(actual: valorActual, anterior: valorAnterior)
            
            if valorAnterior > 0 {
                HStack(spacing: 4) {
                    Image(systemName: variacion.esMejora ? "arrow.up.right" : "arrow.down.right")
                    Text(String(format: "%.1f%%", variacion.porcentaje) + " vs mes pasado")
                        .font(.aidaCuerpo)
                }
                .foregroundColor(viewModel.colorParaVariacion(variacion.esMejora))
            } else {
                Text("Primer mes de registro 🚀")
                    .font(.aidaCuerpo)
                    .foregroundColor(.aidaTextoSecundario)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.aidaSuperficie)
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        )
    }
}
