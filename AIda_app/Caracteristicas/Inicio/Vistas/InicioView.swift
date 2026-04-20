import SwiftUI

struct InicioView: View {
    @State private var vm = InicioViewModel()
    @State private var animarEntrada = false
    @StateObject private var statsVM = EstadisticasViewModel()
    
    private let perfil = PerfilUsuario()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con gradiente suave
                LinearGradient(
                    colors: [.rosaBruma, Color.white.opacity(0.95), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // ── 1. FRASE MOTIVACIONAL GRANDE ──
                        fraseMotivacional
                        
                        // ── 2. TARJETA DE RACHA ──
                        tarjetaRacha
                        
                        // ── 3. ESTADO DE ÁNIMO ──
                        seccionAnimo
                        
                        // ── 4. RESUMEN DE ESTADÍSTICAS ──
                        resumenEstadisticas
                        
                        // ── 5. DATOS CORPORALES COMPACTOS ──
                        datosCorporalesCompactos
                        
                        // ── 6. ACCESOS RÁPIDOS ──
                        accesosRapidos
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(vm.tituloNavegacion)
            .sheet(isPresented: $vm.mostrarRegistroAnimo) {
                RegistroAnimoView()
            }
            .onAppear {
                vm.cargarAnimoGuardado()
                GestorRacha.compartido.verificarRacha()
                statsVM.cargarDatosHealthKit()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.15)) {
                    animarEntrada = true
                }
            }
        }
    }
    
    // MARK: - 1. Frase Motivacional
    private var fraseMotivacional: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(fraseDelDia)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.grisPizarra)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(animarEntrada ? 1.0 : 0)
                .offset(y: animarEntrada ? 0 : 12)
            
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(.coralEnergetico)
                Text("— AIda")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(.coralEnergetico)
            }
            .opacity(animarEntrada ? 1.0 : 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    // MARK: - 2. Tarjeta de Racha
    private var tarjetaRacha: some View {
        HStack(spacing: 16) {
            // Icono de flama con fondo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.8), .coralEnergetico],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            .scaleEffect(animarEntrada ? 1.0 : 0.3)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: animarEntrada)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(GestorRacha.compartido.rachaActual)")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.grisPizarra)
                +
                Text(" días")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text("de racha activa")
                    .font(.aidaEtiqueta)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Botón compartir
            ShareLink(
                item: "¡Llevo \(GestorRacha.compartido.rachaActual) días seguidos entrenando con AIda! 💪🔥 ¿Te unes al reto?",
                subject: Text("Mi Racha en AIda")
            ) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(10)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Circle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.orange.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.orange.opacity(0.08), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - 3. Estado de Ánimo
    @ViewBuilder
    private var seccionAnimo: some View {
        if vm.animoDelDia == nil {
            Button(action: { vm.abrirRegistroAnimo() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("¿Cómo te sientes hoy?")
                            .font(.aidaCuerpoDestacado)
                            .foregroundColor(.grisPizarra)
                        Text("Registra tu ánimo para personalizar tu experiencia.")
                            .font(.aidaEtiqueta)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "face.smiling.inverse")
                        .font(.system(size: 34))
                        .foregroundColor(.coralEnergetico)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.coralEnergetico.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [8, 5]))
                )
            }
            .buttonStyle(.plain)
        } else {
            let animo = vm.animoDelDia!
            Button(action: { vm.mostrarRegistroAnimo = true }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(animo.colorAsociado.opacity(0.15))
                            .frame(width: 52, height: 52)
                        Image(systemName: animo.icono)
                            .font(.system(size: 26))
                            .foregroundColor(animo.colorAsociado)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Hoy te sientes")
                            .font(.aidaEtiqueta)
                            .foregroundColor(.gray)
                        Text(animo.rawValue)
                            .font(.aidaTitulo)
                            .foregroundColor(.grisPizarra)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.4))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: animo.colorAsociado.opacity(0.12), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 4. Resumen de Estadísticas
    private var resumenEstadisticas: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tu actividad")
                .font(.aidaSubtitulo)
                .foregroundColor(.grisPizarra)
            
            // Fila 1: Pasos y Calorías
            HStack(spacing: 12) {
                MiniStatCard(
                    icono: "figure.walk",
                    titulo: "Pasos",
                    valor: formatearNumero(statsVM.pasosActuales),
                    meta: "hoy",
                    color: .coralEnergetico,
                    animado: animarEntrada,
                    delay: 0.1
                )
                
                MiniStatCard(
                    icono: "bolt.fill",
                    titulo: "Calorías",
                    valor: "\(Int(statsVM.caloriasActivas))",
                    meta: "kcal",
                    color: .orange,
                    animado: animarEntrada,
                    delay: 0.2
                )
            }
            
            // Fila 2: Distancia y Rutinas
            HStack(spacing: 12) {
                MiniStatCard(
                    icono: "map.fill",
                    titulo: "Distancia",
                    valor: String(format: "%.1f", statsVM.kilometrosActuales),
                    meta: "km",
                    color: .greenMint,
                    animado: animarEntrada,
                    delay: 0.3
                )
                
                MiniStatCard(
                    icono: "checkmark.seal.fill",
                    titulo: "Rutinas",
                    valor: "\(perfil.rutinasCompletadas)",
                    meta: "completadas",
                    color: .magentaProfundo,
                    animado: animarEntrada,
                    delay: 0.4
                )
            }
        }
    }
    
    // MARK: - 5. Datos Corporales
    private var datosCorporalesCompactos: some View {
        HStack(spacing: 12) {
            DatoCompacto(icono: "scalemass.fill", titulo: "Peso", valor: String(format: "%.1f", perfil.pesoKg), unidad: "kg")
            DatoCompacto(icono: "ruler.fill", titulo: "Altura", valor: "\(perfil.alturaCm)", unidad: "cm")
            
            // IMC con color semántico
            VStack(spacing: 6) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 16))
                    .foregroundColor(perfil.colorIMC)
                Text(String(format: "%.1f", perfil.imc))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.grisPizarra)
                Text(perfil.categoriaIMC)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(perfil.colorIMC))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
        }
    }
    
    // MARK: - 6. Accesos Rápidos
    private var accesosRapidos: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: MisRutinasView()) {
                AccesoRapidoFila(
                    icono: "folder.fill",
                    titulo: "Mis Rutinas Guardadas",
                    color: .magentaProfundo
                )
            }
            .buttonStyle(.plain)
            
            NavigationLink(destination: MiDietaView()) {
                AccesoRapidoFila(
                    icono: "fork.knife.circle.fill",
                    titulo: "Mi Dieta",
                    color: .greenMint
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Helpers
    
    private var fraseDelDia: String {
        let frases = [
            "Cada paso que das\nte acerca a la mejor\nversión de ti.",
            "No se trata de ser\nperfecto, se trata de\nser constante.",
            "Tu cuerpo puede\ncon todo. Convence\na tu mente.",
            "El único mal\nentrenamiento es\nel que no hiciste.",
            "Hoy es un buen día\npara superar al\nde ayer.",
            "La disciplina es\nel puente entre\nmetas y logros.",
            "Pequeños pasos,\ngrandes cambios.",
        ]
        let diaDelAno = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return frases[diaDelAno % frases.count]
    }
    
    private func formatearNumero(_ numero: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: numero)) ?? "\(numero)"
    }
}

// MARK: - Componentes Reutilizables

struct MiniStatCard: View {
    let icono: String
    let titulo: String
    let valor: String
    let meta: String
    let color: Color
    var animado: Bool
    var delay: Double = 0
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: icono)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.aidaEtiqueta)
                    .foregroundColor(.gray)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(valor)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.grisPizarra)
                    Text(meta)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
        .scaleEffect(animado ? 1.0 : 0.85)
        .opacity(animado ? 1.0 : 0)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7).delay(delay),
            value: animado
        )
    }
}

struct DatoCompacto: View {
    let icono: String
    let titulo: String
    let valor: String
    let unidad: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icono)
                .font(.system(size: 16))
                .foregroundColor(.coralEnergetico)
            Text(valor)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.grisPizarra)
            Text(unidad)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }
}

struct AccesoRapidoFila: View {
    let icono: String
    let titulo: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icono)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(titulo)
                .font(.aidaCuerpo)
                .foregroundColor(.grisPizarra)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }
}

// MARK: - Componente legado (MetricRingCard) preservado para compatibilidad
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
