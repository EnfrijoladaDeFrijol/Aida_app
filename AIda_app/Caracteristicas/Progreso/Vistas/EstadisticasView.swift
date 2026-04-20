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
                    
                    // --- SECCIÓN LIFESTYLE & RUNNING (Promedios Diarios) ---
                    HStack {
                        Text("🔥 Promedios Diarios")
                            .font(.aidaSubtitulo)
                        Spacer()
                    }
                    
                    // Gráficos Circulares
                    HStack(spacing: 15) {
                        // Meta Pasos: 6000/día
                        CirculoProgresoView(
                            titulo: "👟 Pasos",
                            valorMensual: Double(viewModel.pasosActuales),
                            metaDiaria: 6000.0,
                            unidad: "pasos"
                        )
                        
                        // Meta Calorías: 400/día
                        CirculoProgresoView(
                            titulo: "⚡️ Calorías",
                            valorMensual: viewModel.caloriasActivas,
                            metaDiaria: 400.0,
                            unidad: "kcal"
                        )
                        
                        // Meta Distancia: 3.0 km/día
                        CirculoProgresoView(
                            titulo: "📍 Distancia",
                            valorMensual: viewModel.kilometrosActuales,
                            metaDiaria: 3.0,
                            unidad: "km"
                        )
                    }
                    
                    Text("Automático vía Apple Health / Watch")
                        .font(.aidaNota)
                        .foregroundColor(.aidaTextoSecundario)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // --- SECCIÓN RUNNING (Historial) ---
                    VStack(alignment: .leading) {
                        HStack {
                            Text("🏃‍♂️ Historial de Running")
                                .font(.aidaSubtitulo)
                                .foregroundColor(.aidaTextoPrincipal)
                            Spacer()
                        }
                        
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
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    // --- SECCIÓN NATACIÓN ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("🏊‍♂️ Natación")
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
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("🏋️‍♂️ Gimnasio")
                                .font(.aidaSubtitulo)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.aidaNaranja)
                                Text("Récord Personal (PR)")
                                    .font(.aidaCuerpoDestacado)
                            }
                            
                            Text(viewModel.ejercicioPR)
                                .font(.aidaTitulo)
                                .foregroundColor(.aidaAcento)
                            
                            Divider()
                            
                            HStack {
                                Text("Tonelaje Acumulado:")
                                    .font(.aidaCuerpo)
                                Spacer()
                                Text("\(Int(viewModel.tonelajeTotal)) kg")
                                    .font(.aidaCuerpoDestacado)
                                    .foregroundColor(.aidaAcento)
                            }
                        }
                        .padding()
                        .background(Color.aidaSuperficie)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    
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
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct CirculoProgresoView: View {
    var titulo: String
    var valorMensual: Double
    var metaDiaria: Double
    var unidad: String
    
    var body: some View {
        // Calcular promedio diario basado en los días transcurridos del mes
        let diasTranscurridos = max(1, Calendar.current.component(.day, from: Date()))
        let promedioDiario = valorMensual / Double(diasTranscurridos)
        let progreso = min(1.0, promedioDiario / metaDiaria)
        let completado = progreso >= 1.0
        let colorActual = completado ? Color.aidaVerde : Color.aidaAcento
        
        VStack {
            ZStack {
                // Fondo del círculo
                Circle()
                    .stroke(colorActual.opacity(0.2), lineWidth: 10)
                
                // Progreso
                Circle()
                    .trim(from: 0.0, to: CGFloat(progreso))
                    .stroke(colorActual, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: progreso)
                
                // Texto en el centro
                VStack(spacing: 2) {
                    Text(String(format: promedioDiario > 100 ? "%.0f" : "%.1f", promedioDiario))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(colorActual)
                    Text(unidad)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.aidaTextoSecundario)
                }
            }
            .frame(width: 75, height: 75)
            
            Text(titulo)
                .font(.aidaEtiqueta)
                .foregroundColor(.aidaTextoPrincipal)
                .padding(.top, 4)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(Color.aidaSuperficie)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    EstadisticasView()
}
