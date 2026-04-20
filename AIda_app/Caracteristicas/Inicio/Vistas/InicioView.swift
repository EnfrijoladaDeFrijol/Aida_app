import SwiftUI

struct InicioView: View {
    // El ViewModel maneja toda la lógica; la vista solo presenta datos
    @State private var vm = InicioViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.rosaBruma, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // 1. Tarjeta de Insight de AIda
                        aidaInsightCard
                        
                        // 2. Sección de Estado de Ánimo Dinámica
                        seccionAnimo
                        
                        // 3. Métricas Rápidas (ahora vienen del ViewModel)
                        HStack(spacing: 16) {
                            MetricRingCard(
                                title: "Agua",
                                value: vm.textoAgua,
                                subtitle: vm.subtituloAgua,
                                icon: "drop.fill",
                                progress: vm.progresoAgua,
                                tintColor: .cyan
                            )
                            MetricRingCard(
                                title: "Pasos",
                                value: vm.textoPasos,
                                subtitle: vm.subtituloPasos,
                                icon: "figure.run",
                                progress: vm.progresoPasos,
                                tintColor: .coralEnergetico
                            )
                        }
                        
                        // 4. Botón de Acción Principal
                        actionButton
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationTitle(vm.tituloNavegacion)
            // Presentamos la vista de registro como un modal
            .sheet(isPresented: $vm.mostrarRegistroAnimo) {
                RegistroAnimoView()
            }
            .onAppear {
                vm.cargarAnimoGuardado()
            }
        }
    }
    
    // MARK: - Sección de Ánimo (Dinámica)
    @ViewBuilder
    private var seccionAnimo: some View {
        if vm.animoDelDia == nil {
            // ESTADO: Aún no responde
            Button(action: {
                vm.abrirRegistroAnimo()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("¿Cómo te sientes hoy?")
                            .font(.headline)
                            .foregroundColor(.grisPizarra)
                        Text("Tómate un segundo para registrarlo.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "face.smiling.inverse")
                        .font(.system(size: 32))
                        .foregroundColor(.coralEnergetico)
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.coralEnergetico.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                )
            }
            .buttonStyle(.plain)
        } else {
            // ESTADO: Ya respondió
            let animoActual = vm.animoDelDia!
            
            Button(action: {
                // Permite cambiarlo si se equivocó
                vm.mostrarRegistroAnimo = true
            }) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(animoActual.colorAsociado.opacity(0.2))
                            .frame(width: 60, height: 60)
                        Image(systemName: animoActual.icono)
                            .font(.system(size: 30))
                            .foregroundColor(animoActual.colorAsociado)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hoy te sientes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(animoActual.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.grisPizarra)
                    }
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.6), lineWidth: 1))
                .shadow(color: animoActual.colorAsociado.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Tarjeta de Insight de AIda
    private var aidaInsightCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle().fill(LinearGradient(colors: [.coralEnergetico, .magentaProfundo], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50).overlay(Image(systemName: "sparkles").foregroundColor(.white))
            VStack(alignment: .leading, spacing: 6) {
                Text("AIda dice:").font(.subheadline).fontWeight(.bold).foregroundColor(.magentaProfundo)
                
                // Ahora el texto viene del ViewModel (futuro: de la API de IA)
                if vm.estaCargandoInsight {
                    ProgressView()
                        .padding(.top, 4)
                } else {
                    Text(vm.insightIA)
                        .font(.body)
                        .foregroundColor(.grisPizarra)
                        .lineSpacing(4)
                }
            }
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading).background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.ultraThinMaterial)).overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.6), lineWidth: 1)).shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
    }
    
    private var actionButton: some View {
        VStack(spacing: 14) {
            Button(action: {}) {
                HStack(spacing: 12) {
                    Image(systemName: "play.circle.fill").font(.title2)
                    Text("Iniciar Pausa Activa").font(.headline).fontWeight(.bold)
                }
                .foregroundColor(.white).padding(.vertical, 18).frame(maxWidth: .infinity).background(LinearGradient(colors: [.coralEnergetico, .magentaProfundo], startPoint: .leading, endPoint: .trailing)).clipShape(Capsule()).shadow(color: .magentaProfundo.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            NavigationLink(destination: MisRutinasView()) {
                HStack(spacing: 12) {
                    Image(systemName: "folder.fill").font(.title2)
                    Text("Mis Rutinas Guardadas").font(.headline).fontWeight(.bold)
                }
                .foregroundColor(.magentaProfundo)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(Color.magentaProfundo.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.magentaProfundo.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

struct MetricRingCard: View {
    var title: String; var value: String; var subtitle: String; var icon: String; var progress: Double; var tintColor: Color
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().stroke(tintColor.opacity(0.15), lineWidth: 8)
                Circle().trim(from: 0, to: progress).stroke(tintColor, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90)).animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
                Image(systemName: icon).font(.title2).foregroundColor(tintColor)
            }.frame(width: 65, height: 65)
            VStack(spacing: 4) {
                Text(value).font(.title3).fontWeight(.bold).foregroundColor(.grisPizarra)
                Text(subtitle).font(.caption).foregroundColor(.gray)
            }
        }
        .padding(.vertical, 20).frame(maxWidth: .infinity).background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.ultraThinMaterial)).overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.6), lineWidth: 1)).shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    InicioView()
}
