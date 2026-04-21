import SwiftUI

struct InicioView: View {
    @State private var vm = InicioViewModel()
    @State private var animarEntrada = false
    @State private var carruselIndex = 0
    
    private let timerCarrusel = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // ── 1. MASCOTA + FRASE (arriba) ──
                        heroSection
                        
                        // ── 2. BOTONES (ánimo grande + rutinas/dieta) ──
                        botonesAccion
                        
                        // ── 3. RACHA EN GRANDE ──
                        rachaGrande
                        
                        // ── 4. NOTICIAS (abajo, más altas) ──
                        carruselNoticias
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $vm.mostrarRegistroAnimo, onDismiss: {
                vm.cargarAnimoGuardado()
            }) {
                RegistroAnimoView()
            }
            .onAppear {
                vm.cargarAnimoGuardado()
                GestorRacha.compartido.verificarRacha()
                withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
                    animarEntrada = true
                }
            }
            .onReceive(timerCarrusel) { _ in
                withAnimation(.easeInOut(duration: 0.4)) {
                    carruselIndex = (carruselIndex + 1) % noticiasYTips.count
                }
            }
        }
    }
    
    // MARK: - 1. Hero: GIF + Frase
    private var heroSection: some View {
        ZStack {
            // Orbes de color
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.coralEnergetico.opacity(0.06), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: -30, y: 0)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.magentaProfundo.opacity(0.04), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .offset(x: 40, y: 20)
            }
            .blur(radius: 20)
            .scaleEffect(animarEntrada ? 1.0 : 0.8)
            .opacity(animarEntrada ? 1.0 : 0)
            
            HStack(spacing: 20) {
                GIFImageView(gifName: "jaida_se_corre")
                    .frame(width: 110, height: 110)
                    .scaleEffect(0.4)
                    .opacity(animarEntrada ? 1.0 : 0)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(fraseDelDia)
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(.grisPizarra)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.coralEnergetico.opacity(0.35))
                            .frame(width: 18, height: 1.5)
                        Image(systemName: "sparkle")
                            .font(.system(size: 7))
                        Text("AIda")
                            .font(.system(size: 10, weight: .medium, design: .serif))
                    }
                    .foregroundColor(.coralEnergetico.opacity(0.6))
                }
                .opacity(animarEntrada ? 1.0 : 0)
                .offset(y: animarEntrada ? 0 : 10)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - 2. Botones de Acción
    private var botonesAccion: some View {
        VStack(spacing: 12) {
            // Botón de ánimo — GRANDE, ancho completo
            Button(action: { vm.mostrarRegistroAnimo = true }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: animoColoresGradiente,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: animoIcono)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(animoTitulo)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(animoSubtitulo)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: animoFondoGradiente,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: animoSombra.opacity(0.25), radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(.plain)
            
            // Rutinas + Dieta — fila de 2
            HStack(spacing: 12) {
                NavigationLink(destination: MisRutinasView()) {
                    BotonAccesoColor(
                        icono: "dumbbell.fill",
                        titulo: "Mis Rutinas",
                        subtitulo: "Guardadas",
                        coloresGradiente: [.coralEnergetico, .magentaProfundo]
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: MiDietaView()) {
                    BotonAccesoColor(
                        icono: "leaf.fill",
                        titulo: "Mi Dieta",
                        subtitulo: "Plan actual",
                        coloresGradiente: [Color.greenMint, Color.green.opacity(0.7)]
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - 3. Racha GRANDE
    private var rachaGrande: some View {
        VStack(spacing: 8) {
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
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: animarEntrada)
            
            Text("días de racha")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
                .tracking(3)
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
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.975))
                .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.gray.opacity(0.06), lineWidth: 1)
        )
    }
    
    // MARK: - 4. Carrusel Noticias (más alto)
    private var carruselNoticias: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.coralEnergetico.opacity(0.6))
                Text("Tips & Datos")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                    .tracking(1)
                    .textCase(.uppercase)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<noticiasYTips.count, id: \.self) { i in
                        Circle()
                            .fill(carruselIndex == i ? Color.coralEnergetico.opacity(0.6) : Color.gray.opacity(0.15))
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            TabView(selection: $carruselIndex) {
                ForEach(Array(noticiasYTips.enumerated()), id: \.offset) { index, noticia in
                    tarjetaNoticia(noticia)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 160)
        }
    }
    
    // MARK: - Tarjeta de noticia (más grande)
    private func tarjetaNoticia(_ noticia: NoticiaFitness) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: noticia.colores,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: noticia.icono)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(noticia.categoria)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(noticia.colores.first?.opacity(0.7) ?? .gray)
                        .tracking(1.5)
                        .textCase(.uppercase)
                    
                    Text(noticia.titulo)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.grisPizarra)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            Spacer().frame(height: 12)
            
            Text(noticia.descripcion)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(white: 0.975))
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.gray.opacity(0.06), lineWidth: 1)
        )
    }
    
    // MARK: - Helpers Ánimo
    private var animoIcono: String {
        vm.animoDelDia?.icono ?? "face.smiling"
    }
    private var animoTitulo: String {
        vm.animoDelDia != nil ? "Te sientes \(vm.animoDelDia!.rawValue)" : "¿Cómo te sientes hoy?"
    }
    private var animoSubtitulo: String {
        vm.animoDelDia != nil ? "Toca para cambiar" : "Registra tu ánimo"
    }
    private var animoColoresGradiente: [Color] {
        if let animo = vm.animoDelDia {
            return [animo.colorAsociado.opacity(0.9), animo.colorAsociado]
        }
        return [.orange, .coralEnergetico]
    }
    private var animoFondoGradiente: [Color] {
        if let animo = vm.animoDelDia {
            return [animo.colorAsociado.opacity(0.85), animo.colorAsociado]
        }
        return [.coralEnergetico.opacity(0.9), .magentaProfundo.opacity(0.85)]
    }
    private var animoSombra: Color {
        vm.animoDelDia?.colorAsociado ?? .coralEnergetico
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
    
    // MARK: - Noticias
    private var noticiasYTips: [NoticiaFitness] {
        [
            NoticiaFitness(
                icono: "drop.fill",
                categoria: "Hidratación",
                titulo: "¿Sabías que el 75% de la gente está deshidratada?",
                descripcion: "Beber 2.5L al día mejora tu rendimiento un 20% en el gym. Intenta llevar una botella contigo todo el día.",
                colores: [.cyan, .blue.opacity(0.7)]
            ),
            NoticiaFitness(
                icono: "bed.double.fill",
                categoria: "Descanso",
                titulo: "Dormir bien = más músculo",
                descripcion: "El 80% de la hormona del crecimiento se libera durante el sueño profundo. Apunta a 7-8 horas cada noche.",
                colores: [.purple.opacity(0.7), .indigo]
            ),
            NoticiaFitness(
                icono: "flame.fill",
                categoria: "Nutrición",
                titulo: "La proteína no es solo para el gym",
                descripcion: "Tu cuerpo necesita 1.6-2.2g/kg de peso para mantener y construir masa muscular de forma efectiva.",
                colores: [.coralEnergetico, .magentaProfundo]
            ),
            NoticiaFitness(
                icono: "figure.run",
                categoria: "Cardio",
                titulo: "10,000 pasos = un gran cambio",
                descripcion: "Caminar 10k pasos diarios reduce el riesgo cardiovascular un 35%. Empieza con 2k y ve subiendo poco a poco.",
                colores: [.greenMint, .green.opacity(0.7)]
            ),
            NoticiaFitness(
                icono: "brain.head.profile",
                categoria: "Bienestar",
                titulo: "El ejercicio es el mejor antidepresivo",
                descripcion: "30 min de actividad física liberan endorfinas equivalentes a una dosis natural de serotonina. ¡Muévete!",
                colores: [.orange, .yellow.opacity(0.8)]
            ),
        ]
    }
}

// MARK: - Modelo de Noticia
struct NoticiaFitness {
    let icono: String
    let categoria: String
    let titulo: String
    let descripcion: String
    let colores: [Color]
}

// MARK: - BotonAccesoColor (con gradiente de fondo, texto blanco, resalta del fondo)
struct BotonAccesoColor: View {
    let icono: String
    let titulo: String
    let subtitulo: String
    let coloresGradiente: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icono)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 2) {
                Text(titulo)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(subtitulo)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: coloresGradiente,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: coloresGradiente.first?.opacity(0.25) ?? .clear, radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - BotonAcceso legacy (por si se referencia en otro lado)
struct BotonAcceso: View {
    let icono: String
    let titulo: String
    let subtitulo: String
    let coloresGradiente: [Color]
    
    var body: some View {
        BotonAccesoColor(icono: icono, titulo: titulo, subtitulo: subtitulo, coloresGradiente: coloresGradiente)
    }
}

#Preview {
    InicioView()
}
