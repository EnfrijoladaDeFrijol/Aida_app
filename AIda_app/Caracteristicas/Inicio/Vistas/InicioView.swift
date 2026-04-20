import SwiftUI

struct InicioView: View {
    @State private var vm = InicioViewModel()
    @State private var animarEntrada = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 36) {
                        
                        // ── 1. GIF DE AIDA + FRASE ──
                        heroSection
                        
                        // ── 2. RACHA EN GRANDE ──
                        rachaGigante
                        
                        // ── 3. ÁNIMO MINIMALISTA ──
                        seccionAnimo
                        
                        // ── 4. ACCESOS RÁPIDOS MEJORADOS ──
                        accesosRapidos
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $vm.mostrarRegistroAnimo) {
                RegistroAnimoView()
            }
            .onAppear {
                vm.cargarAnimoGuardado()
                GestorRacha.compartido.verificarRacha()
                withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
                    animarEntrada = true
                }
            }
        }
    }
    
    // MARK: - 1. Hero: GIF + Frase
    private var heroSection: some View {
        ZStack {
            // Efecto de fondo difuminado
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.coralEnergetico.opacity(0.07), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .offset(x: -20, y: 0)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.magentaProfundo.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                    .offset(x: 40, y: 30)
            }
            .blur(radius: 25)
            .scaleEffect(animarEntrada ? 1.0 : 0.8)
            .opacity(animarEntrada ? 1.0 : 0)
            
            HStack(spacing: 56) {
                // GIF de AIda corriendo
                GIFImageView(gifName: "jaida_se_corre")
                    .frame(width: 130, height: 130)
                    .scaleEffect(animarEntrada ? 0.4 : 0.4)
                    .opacity(animarEntrada ? 1.0 : 0)
                
                // Frase motivacional
                VStack(alignment: .leading, spacing: 10) {
                    Text(fraseDelDia)
                        .font(.system(size:20, weight: .medium, design: .serif))
                        .foregroundColor(.grisPizarra)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.coralEnergetico.opacity(0.35))
                            .frame(width: 20, height: 1.5)
                        
                        Image(systemName: "sparkle")
                            .font(.system(size: 8))
                        Text("AIda")
                            .font(.system(size: 11, weight: .medium, design: .serif))
                    }
                    .foregroundColor(.coralEnergetico.opacity(0.6))
                }
                .opacity(animarEntrada ? 1.0 : 0)
                .offset(y: animarEntrada ? 0 : 12)
            }
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - 2. Racha Gigante
    private var rachaGigante: some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(GestorRacha.compartido.rachaActual)")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundColor(.grisPizarra)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.orange)
                    .offset(y: -8)
            }
            .scaleEffect(animarEntrada ? 1.0 : 0.5)
            .opacity(animarEntrada ? 1.0 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3), value: animarEntrada)
            
            Text("días de racha")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .tracking(2.5)
                .textCase(.uppercase)
            
            ShareLink(
                item: "¡Llevo \(GestorRacha.compartido.rachaActual) días seguidos entrenando con AIda! 💪🔥 ¿Te unes al reto?",
                subject: Text("Mi Racha en AIda")
            ) {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 11, weight: .medium))
                    Text("Compartir")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(.gray.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().stroke(Color.gray.opacity(0.15), lineWidth: 1))
            }
            .padding(.top, 6)
        }
    }
    
    // MARK: - 3. Estado de Ánimo
    @ViewBuilder
    private var seccionAnimo: some View {
        if vm.animoDelDia == nil {
            Button(action: { vm.abrirRegistroAnimo() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("¿Cómo te sientes?")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.grisPizarra)
                        Text("Toca para registrar tu ánimo")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Circle()
                        .stroke(Color.coralEnergetico.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "face.smiling")
                                .font(.system(size: 20))
                                .foregroundColor(.coralEnergetico.opacity(0.5))
                        )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.gray.opacity(0.035))
                )
            }
            .buttonStyle(.plain)
        } else {
            let animo = vm.animoDelDia!
            Button(action: { vm.mostrarRegistroAnimo = true }) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(animo.colorAsociado.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: animo.icono)
                                .font(.system(size: 20))
                                .foregroundColor(animo.colorAsociado)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hoy te sientes")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                        Text(animo.rawValue)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.grisPizarra)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.gray.opacity(0.035))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 4. Accesos Rápidos Mejorados
    private var accesosRapidos: some View {
        HStack(spacing: 14) {
            NavigationLink(destination: MisRutinasView()) {
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.coralEnergetico, .magentaProfundo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Mis Rutinas")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.grisPizarra)
                    
                    Text("Guardadas")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.gray.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            NavigationLink(destination: MiDietaView()) {
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.greenMint, .green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Mi Dieta")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.grisPizarra)
                    
                    Text("Plan alimenticio")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.gray.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Frase del Día
    private var fraseDelDia: String {
        let frases = [
            "Cada paso que das\nte acerca a la mejor\nversión de ti.",
            "No se trata de ser\nperfecto, se trata\nde ser constante.",
            "Tu cuerpo puede\ncon todo. Convence\na tu mente.",
            "El único mal\nentrenamiento es\nel que no hiciste.",
            "Hoy es un buen día\npara superar\nal de ayer.",
            "La disciplina es\nel puente entre\nmetas y logros.",
            "Pequeños pasos,\ngrandes cambios.",
        ]
        let diaDelAno = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return frases[diaDelAno % frases.count]
    }
}

// MARK: - Componente legado preservado para compatibilidad
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
