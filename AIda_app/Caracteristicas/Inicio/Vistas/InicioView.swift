import SwiftUI

// MARK: - Paleta de Colores
extension Color {
    static let rosaBruma = Color(red: 1.0, green: 0.96, blue: 0.96)
    static let coralEnergetico = Color(red: 1.0, green: 0.42, blue: 0.42)
    static let magentaProfundo = Color(red: 0.79, green: 0.09, blue: 0.29)
    static let greenMint = Color(red: 0.45, green: 0.92, blue: 0.76)
    static let grisPizarra = Color(red: 0.18, green: 0.2, blue: 0.21)
}

struct InicioView: View {
    // Variable persistente para guardar el ánimo del día
    @AppStorage("animoDelDia") private var animoDelDia: String = ""
    // Estado para controlar cuándo mostrar la pantalla de registro
    @State private var mostrarRegistroAnimo = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.rosaBruma, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // 1. Tarjeta de Insight de AIda
                        aidaInsightCard
                        
                        // 2. NUEVO: Sección de Estado de Ánimo Dinámica
                        seccionAnimo
                        
                        // 3. Métricas Rápidas
                        HStack(spacing: 16) {
                            MetricRingCard(title: "Agua", value: "1.2 L", subtitle: "de 2.5 L", icon: "drop.fill", progress: 0.48, tintColor: .cyan)
                            MetricRingCard(title: "Pasos", value: "3,200", subtitle: "Meta: 10k", icon: "figure.run", progress: 0.32, tintColor: .coralEnergetico)
                        }
                        
                        // 4. Botón de Acción Principal
                        actionButton
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Hola, Arturo 👋")
            // Presentamos la vista de registro como un modal
            .sheet(isPresented: $mostrarRegistroAnimo) {
                RegistroAnimoView()
            }
        }
    }
    
    // MARK: - Sección de Ánimo (Dinámica)
    @ViewBuilder
    private var seccionAnimo: some View {
        if animoDelDia.isEmpty {
            // ESTADO: Aún no responde
            Button(action: {
                mostrarRegistroAnimo = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
            // Buscamos el objeto TipoAnimo basado en el String guardado
            let animoGuardado = TipoAnimo(rawValue: animoDelDia) ?? .bien
            
            Button(action: {
                // Permite cambiarlo si se equivocó
                mostrarRegistroAnimo = true
            }) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(animoGuardado.colorAsociado.opacity(0.2))
                            .frame(width: 60, height: 60)
                        Image(systemName: animoGuardado.icono)
                            .font(.system(size: 30))
                            .foregroundColor(animoGuardado.colorAsociado)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hoy te sientes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(animoGuardado.rawValue)
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
                .shadow(color: animoGuardado.colorAsociado.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Subvistas Originales (Minimizadas para lectura)
    private var aidaInsightCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle().fill(LinearGradient(colors: [.coralEnergetico, .magentaProfundo], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50).overlay(Image(systemName: "sparkles").foregroundColor(.white))
            VStack(alignment: .leading, spacing: 6) {
                Text("AIda dice:").font(.subheadline).fontWeight(.bold).foregroundColor(.magentaProfundo)
                Text("Pareces un poco estresado hoy. Solo llevas el 30% de tu meta de agua, ¡vamos a hidratarnos!").font(.body).foregroundColor(.grisPizarra).lineSpacing(4)
            }
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading).background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.ultraThinMaterial)).overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.6), lineWidth: 1)).shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
    }
    
    private var actionButton: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill").font(.title2)
                Text("Iniciar Pausa Activa").font(.headline).fontWeight(.bold)
            }
            .foregroundColor(.white).padding(.vertical, 18).frame(maxWidth: .infinity).background(LinearGradient(colors: [.coralEnergetico, .magentaProfundo], startPoint: .leading, endPoint: .trailing)).clipShape(Capsule()).shadow(color: .magentaProfundo.opacity(0.3), radius: 10, x: 0, y: 5)
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
