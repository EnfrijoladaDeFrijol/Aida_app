import SwiftUI

struct InicioView: View {
    @State private var vm = InicioViewModel()
    @State private var animarEntrada = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo limpio
                Color.white.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        
                        // ── 1. FRASE CENTRADA CON EFECTO ──
                        fraseHero
                        
                        // ── 2. RACHA EN GRANDE ──
                        rachaGigante
                        
                        // ── 3. ÁNIMO MINIMALISTA ──
                        seccionAnimo
                        
                        // ── 4. ACCESOS RÁPIDOS ──
                        accesosRapidos
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle(vm.tituloNavegacion)
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
    
    // MARK: - 1. Frase Hero
    private var fraseHero: some View {
        ZStack {
            // Efecto de fondo: círculos difuminados
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.coralEnergetico.opacity(0.08), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .offset(x: -30, y: -10)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.magentaProfundo.opacity(0.06), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 220)
                    .offset(x: 50, y: 30)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .offset(x: -60, y: 50)
            }
            .blur(radius: 20)
            .scaleEffect(animarEntrada ? 1.0 : 0.8)
            .opacity(animarEntrada ? 1.0 : 0)
            
            // Frase
            VStack(spacing: 16) {
                Text(fraseDelDia)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundColor(.grisPizarra)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Línea decorativa
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .coralEnergetico.opacity(0.4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60, height: 2)
                
                HStack(spacing: 5) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                    Text("AIda")
                        .font(.system(size: 13, weight: .medium, design: .serif))
                }
                .foregroundColor(.coralEnergetico.opacity(0.7))
            }
            .padding(.vertical, 32)
            .opacity(animarEntrada ? 1.0 : 0)
            .offset(y: animarEntrada ? 0 : 16)
        }
        .padding(.top, 10)
    }
    
    // MARK: - 2. Racha Gigante
    private var rachaGigante: some View {
        VStack(spacing: 8) {
            // Número gigante
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(GestorRacha.compartido.rachaActual)")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundColor(.grisPizarra)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
                    .offset(y: -8)
            }
            .scaleEffect(animarEntrada ? 1.0 : 0.5)
            .opacity(animarEntrada ? 1.0 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3), value: animarEntrada)
            
            Text("días de racha")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .tracking(2)
                .textCase(.uppercase)
            
            // Botón compartir sutil
            ShareLink(
                item: "¡Llevo \(GestorRacha.compartido.rachaActual) días seguidos entrenando con AIda! 💪🔥 ¿Te unes al reto?",
                subject: Text("Mi Racha en AIda")
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12, weight: .medium))
                    Text("Compartir")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }
            .padding(.top, 8)
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
                        .stroke(Color.coralEnergetico.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "face.smiling")
                                .font(.system(size: 20))
                                .foregroundColor(.coralEnergetico.opacity(0.6))
                        )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.gray.opacity(0.04))
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
                        .fill(Color.gray.opacity(0.04))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 4. Accesos Rápidos
    private var accesosRapidos: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: MisRutinasView()) {
                FilaMinimalista(icono: "square.stack.fill", titulo: "Mis Rutinas", color: .grisPizarra)
            }
            .buttonStyle(.plain)
            
            NavigationLink(destination: MiDietaView()) {
                FilaMinimalista(icono: "leaf.fill", titulo: "Mi Dieta", color: .grisPizarra)
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

// MARK: - Componentes Minimalistas

struct FilaMinimalista: View {
    let icono: String
    let titulo: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icono)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color.opacity(0.6))
                .frame(width: 20)
            
            Text(titulo)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(color)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.gray.opacity(0.04))
        )
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
