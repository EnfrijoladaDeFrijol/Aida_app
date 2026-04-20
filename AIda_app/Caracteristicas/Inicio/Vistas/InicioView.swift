import SwiftUI

struct InicioView: View {
    @State private var vm = InicioViewModel()
    @State private var animarEntrada = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // ── 1. ACCESOS RÁPIDOS (ARRIBA) ──
                        accesosRapidos
                        
                        // ── 2. GIF DE AIDA + FRASE (EN MEDIO) ──
                        heroSection
                        
                        // ── 3. RACHA EN GRANDE ──
                        rachaGigante
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
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
                VStack(alignment: .leading, spacing: 5) {
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
            .padding(.vertical, 5)
        }
    }
    
    // MARK: - 1. Racha Gigante
    private var rachaGigante: some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(GestorRacha.compartido.rachaActual)")
                    .font(.system(size: 60, weight: .heavy, design: .rounded))
                    .foregroundColor(.grisPizarra)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.orange)
                    .offset(y: -6)
            }
            .scaleEffect(animarEntrada ? 1.0 : 0.5)
            .opacity(animarEntrada ? 1.0 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: animarEntrada)
            
            Text("días de racha")
                .font(.system(size: 13, weight: .medium, design: .rounded))
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
                .foregroundColor(.gray.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.98)) // Blanco ligeramente grisáceo
                .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.gray.opacity(0.06), lineWidth: 1)
        )
    }
    
    // MARK: - 4. Accesos Rápidos (Rutinas, Dieta, Ánimo)
    private var accesosRapidos: some View {
        HStack(spacing: 8) {
            // 1. MIS RUTINAS
            NavigationLink(destination: MisRutinasView()) {
                BotonAcceso(
                    icono: "dumbbell.fill",
                    titulo: "Mis Rutinas",
                    subtitulo: "Guardadas",
                    coloresGradiente: [.coralEnergetico, .magentaProfundo]
                )
            }
            .buttonStyle(.plain)
            
            // 2. MI DIETA
            NavigationLink(destination: MiDietaView()) {
                BotonAcceso(
                    icono: "leaf.fill",
                    titulo: "Mi Dieta",
                    subtitulo: "Plan actual",
                    coloresGradiente: [.greenMint, .green.opacity(0.7)]
                )
            }
            .buttonStyle(.plain)
            
            // 3. ÁNIMO
            Button(action: { vm.mostrarRegistroAnimo = true }) {
                if let animo = vm.animoDelDia {
                    BotonAcceso(
                        icono: animo.icono,
                        titulo: "Ánimo",
                        subtitulo: animo.rawValue,
                        coloresGradiente: [animo.colorAsociado.opacity(0.8), animo.colorAsociado]
                    )
                } else {
                    BotonAcceso(
                        icono: "face.smiling",
                        titulo: "Ánimo",
                        subtitulo: "Regístralo",
                        coloresGradiente: [.orange.opacity(0.6), .orange]
                    )
                }
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

struct BotonAcceso: View {
    let icono: String
    let titulo: String
    let subtitulo: String
    let coloresGradiente: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: coloresGradiente,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: icono)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 2) {
                Text(titulo)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.grisPizarra)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(subtitulo)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.gray.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    InicioView()
}
