import SwiftUI
import SwiftData
import Charts

struct EstadisticasView: View {
    @StateObject private var viewModel = EstadisticasViewModel()
    
    @Environment(\.modelContext) private var context
    @Query(sort: \RegistroMensual.mes, order: .reverse) private var registros: [RegistroMensual]
    @State private var mostrarRegistro = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- SECCIÓN LIFESTYLE ---
                    HStack {
                        Text("Actividad Diaria")
                            .font(.aidaSubtitulo)
                        Spacer()
                    }
                    
                    TarjetaProgreso(
                        titulo: "Pasos (Mensual)",
                        valor: "\(viewModel.pasosActuales)",
                        unidad: "pasos",
                        valorAnterior: Double(viewModel.pasosAnteriores),
                        valorActual: Double(viewModel.pasosActuales)
                    )
                    
                    VStack(alignment: .leading, spacing: 5) {
                        TarjetaProgreso(
                            titulo: "Calorías Activas",
                            valor: String(format: "%.0f", viewModel.caloriasActivas),
                            unidad: "kcal",
                            valorAnterior: viewModel.caloriasAnteriores,
                            valorActual: viewModel.caloriasActivas
                        )
                        Text("Automático vía Apple Watch")
                            .font(.aidaNota)
                            .foregroundColor(.aidaTextoSecundario)
                            .padding(.leading, 10)
                    }
                    
                    // --- SECCIÓN RUNNING ---
                    HStack {
                        Text("Running")
                            .font(.aidaSubtitulo)
                        Spacer()
                    }
                    
                    TarjetaProgreso(
                        titulo: "Distancia",
                        valor: String(format: "%.1f", viewModel.kilometrosActuales),
                        unidad: "km",
                        valorAnterior: viewModel.kilometrosAnteriores,
                        valorActual: viewModel.kilometrosActuales
                    )
                    
                    // Gráfica de los últimos 3 meses
                    VStack(alignment: .leading) {
                        Text("Historial de Running")
                            .font(.aidaEtiqueta)
                            .foregroundColor(.aidaTextoSecundario)
                        
                        Chart {
                            ForEach(viewModel.historialKms) { dato in
                                let valorFinal = dato.mes == "Abr" ? viewModel.kilometrosActuales : dato.valor
                                BarMark(
                                    x: .value("Mes", dato.mes),
                                    y: .value("Kilómetros", valorFinal)
                                )
                                .foregroundStyle(Color.aidaAcento)
                            }
                        }
                        .frame(height: 150)
                    }
                    .padding()
                    .background(Color.aidaSuperficie)
                    .cornerRadius(16)
                    
                    // --- SECCIÓN NATACIÓN ---
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Natación")
                                .font(.aidaSubtitulo)
                            Spacer()
                        }
                        
                        HStack(spacing: 15) {
                            TarjetaMini(titulo: "Sesiones (Manual)", valor: "\(viewModel.sesionesNatacion)", icon: "figure.pool.swim")
                            TarjetaMini(titulo: "Total (Auto+Manual)", valor: "\(Int(viewModel.metrosNatacionTotal))m", icon: "water.waves")
                        }
                        
                        Text("Métricas requieren Apple Watch o ingreso manual (+)")
                            .font(.aidaNota)
                            .foregroundColor(.aidaTextoSecundario)
                    }
                    
                    // --- SECCIÓN GIMNASIO ---
                    HStack {
                        Text("Gimnasio")
                            .font(.aidaSubtitulo)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "dumbbell.fill")
                                .foregroundColor(.aidaAcento)
                            Text("PR del Mes")
                                .font(.aidaCuerpoDestacado)
                        }
                        
                        Text(viewModel.ejercicioPR)
                            .font(.aidaTitulo)
                            .foregroundColor(.aidaAcento)
                        
                        Divider()
                        
                        HStack {
                            Text("Tonelaje Total:")
                                .font(.aidaCuerpo)
                            Text("\(Int(viewModel.tonelajeTotal)) kg")
                                .font(.aidaCuerpoDestacado)
                                .foregroundColor(.aidaAcento)
                        }
                    }
                    .padding()
                    .background(Color.aidaSuperficie)
                    .cornerRadius(16)
                    
                }
                .padding()
            }
            .background(Color.aidaFondo.ignoresSafeArea())
            .navigationTitle("Progreso")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { mostrarRegistro = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.aidaAcento)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $mostrarRegistro) {
                RegistroMetricasManualView()
            }
            .onChange(of: registros) { _, _ in
                sincronizarSwiftData()
            }
            .onAppear {
                viewModel.cargarDatosHealthKit()
                sincronizarSwiftData()
            }
        }
    }
    
    private func sincronizarSwiftData() {
        let mesActual = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        if let registroActual = registros.first(where: { $0.mes == mesActual }) {
            viewModel.metrosNatacionManual = registroActual.metrosTotales
            viewModel.sesionesNatacion = registroActual.sesionesNado
            viewModel.tonelajeTotal = registroActual.tonelajeTotal
            viewModel.ejercicioPR = registroActual.ejercicioPR.isEmpty ? "Sin registro" : registroActual.ejercicioPR
        } else {
            // Si no hay registro este mes, mostrar en cero
            viewModel.metrosNatacionManual = 0
            viewModel.sesionesNatacion = 0
            viewModel.tonelajeTotal = 0
            viewModel.ejercicioPR = "Sin registro"
        }
    }
}

struct TarjetaProgreso: View {
    var titulo: String
    var valor: String
    var unidad: String
    var valorAnterior: Double
    var valorActual: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titulo)
                .font(.aidaSubtitulo)
                .foregroundColor(.aidaTextoPrincipal)
            
            HStack(alignment: .firstTextBaseline) {
                Text(valor)
                    .font(.aidaMetricaGigante)
                    .foregroundColor(.aidaAcento)
                
                Text(unidad)
                    .font(.aidaCuerpoDestacado)
                    .foregroundColor(.aidaTextoSecundario)
                
                Spacer()
                
                // Indicador de cambio
                let diferencia = valorActual - valorAnterior
                let porcentaje = valorAnterior > 0 ? (diferencia / valorAnterior) * 100 : 0
                let esPositivo = diferencia >= 0
                
                HStack(spacing: 4) {
                    Image(systemName: esPositivo ? "arrow.up.right" : "arrow.down.right")
                    Text(String(format: "%.1f%%", abs(porcentaje)))
                }
                .font(.aidaCuerpoDestacado)
                .foregroundColor(esPositivo ? .aidaVerde : .aidaRojo)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((esPositivo ? Color.aidaVerde : Color.aidaRojo).opacity(0.15))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.aidaSuperficie)
        .cornerRadius(16)
    }
}

struct TarjetaMini: View {
    var titulo: String
    var valor: String
    var icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.aidaAcento)
                Text(titulo)
                    .font(.aidaEtiqueta)
            }
            Text(valor)
                .font(.aidaTitulo)
                .foregroundColor(.aidaTextoPrincipal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.aidaSuperficie)
        .cornerRadius(16)
    }
}

#Preview {
    EstadisticasView()
}
