import SwiftUI

// MARK: - PerfilView
// Pantalla de perfil premium con:
// - Header dinámico que cambia según el ánimo
// - Tarjetas de estadísticas con animaciones
// - Historial visual de ánimos de la semana
// - Datos corporales con IMC
// - Sección de edición

struct PerfilView: View {
    @State private var vm = PerfilViewModel()
    @State private var animarEntrada = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con gradiente reactivo al ánimo
                LinearGradient(
                    colors: [vm.perfil.gradienteAnimo[0].opacity(0.15), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // 1. Header con avatar y saludo
                        headerPerfil
                        
                        // 2. Tarjetas de estadísticas rápidas
                        estadisticasRapidas
                        
                        // 3. Historial de ánimos de la semana
                        historialAnimoSemana
                        
                        // 4. Datos corporales
                        tarjetaDatosCorporales
                        
                        // 5. Acciones
                        seccionAcciones
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Mi Perfil")
            .sheet(isPresented: $vm.mostrarEditorPerfil) {
                EditorPerfilView(vm: vm)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    animarEntrada = true
                }
            }
        }
    }
    
    // MARK: - Header del Perfil
    private var headerPerfil: some View {
        VStack(spacing: 16) {
            // Avatar con gradiente dinámico
            ZStack {
                // Anillo exterior animado
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: vm.perfil.gradienteAnimo,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 96, height: 96)
                    .scaleEffect(animarEntrada ? 1.0 : 0.5)
                    .opacity(animarEntrada ? 1.0 : 0)
                
                // Círculo con iniciales
                Circle()
                    .fill(
                        LinearGradient(
                            colors: vm.perfil.gradienteAnimo,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                    .overlay(
                        Text(vm.perfil.iniciales)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
                    .scaleEffect(animarEntrada ? 1.0 : 0.3)
                
                // Badge de ánimo actual
                if let animo = vm.perfil.animoActual {
                    Image(systemName: animo.icono)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(animo.colorAsociado))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 34, y: 34)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Nombre y saludo
            VStack(spacing: 6) {
                Text(vm.perfil.nombre)
                    .font(.aidaTitulo)
                    .foregroundColor(.grisPizarra)
                
                Text(vm.fraseMotivacional)
                    .font(.aidaCuerpo)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Estadísticas Rápidas
    private var estadisticasRapidas: some View {
        HStack(spacing: 12) {
            TarjetaEstadistica(
                titulo: "Racha",
                valor: "\(vm.perfil.diasDeRacha)",
                unidad: "días",
                icono: "flame.fill",
                color: .orange,
                animarEntrada: animarEntrada,
                delay: 0.1
            )
            
            TarjetaEstadistica(
                titulo: "Rutinas",
                valor: "\(vm.perfil.rutinasCompletadas)",
                unidad: "hechas",
                icono: "checkmark.seal.fill",
                color: .greenMint,
                animarEntrada: animarEntrada,
                delay: 0.2
            )
            
            TarjetaEstadistica(
                titulo: "Ánimos",
                valor: "\(vm.perfil.animosRegistrados)",
                unidad: "registros",
                icono: "heart.text.square.fill",
                color: .coralEnergetico,
                animarEntrada: animarEntrada,
                delay: 0.3
            )
        }
    }
    
    // MARK: - Historial de Ánimo Semanal
    private var historialAnimoSemana: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tu semana emocional")
                    .font(.aidaSubtitulo)
                    .foregroundColor(.grisPizarra)
                
                Spacer()
                
                // Porcentaje de cobertura
                Text("\(Int(vm.porcentajeSemanaCubierta * 100))%")
                    .font(.aidaEtiqueta)
                    .fontWeight(.bold)
                    .foregroundColor(.coralEnergetico)
            }
            
            HStack(spacing: 8) {
                ForEach(Array(vm.perfil.historialAnimosSemana.enumerated()), id: \.offset) { index, registro in
                    VStack(spacing: 10) {
                        // Burbuja de ánimo
                        ZStack {
                            Circle()
                                .fill(
                                    registro.animo != nil
                                    ? registro.animo!.colorAsociado.opacity(0.15)
                                    : Color.gray.opacity(0.08)
                                )
                                .frame(width: 42, height: 42)
                            
                            if let animo = registro.animo {
                                Image(systemName: animo.icono)
                                    .font(.system(size: 18))
                                    .foregroundColor(animo.colorAsociado)
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                                    .frame(width: 28, height: 28)
                            }
                        }
                        .scaleEffect(animarEntrada ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.6)
                            .delay(Double(index) * 0.08 + 0.3),
                            value: animarEntrada
                        )
                        
                        // Día abreviado
                        Text(registro.dia)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(
                                Calendar.current.isDateInToday(Date()) && index == 6
                                ? .coralEnergetico
                                : .gray
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
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
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 5)
    }
    
    // MARK: - Datos Corporales
    private var tarjetaDatosCorporales: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Datos Corporales")
                    .font(.aidaSubtitulo)
                    .foregroundColor(.grisPizarra)
                Spacer()
                Button(action: { vm.prepararEdicion() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Editar")
                    }
                    .font(.aidaEtiqueta)
                    .fontWeight(.semibold)
                    .foregroundColor(.coralEnergetico)
                }
            }
            
            // Grid de datos
            HStack(spacing: 12) {
                DatoCorporalMini(titulo: "Edad", valor: "\(vm.perfil.edad)", unidad: "años", icono: "calendar")
                DatoCorporalMini(titulo: "Peso", valor: String(format: "%.1f", vm.perfil.pesoKg), unidad: "kg", icono: "scalemass.fill")
            }
            
            HStack(spacing: 12) {
                DatoCorporalMini(titulo: "Altura", valor: "\(vm.perfil.alturaCm)", unidad: "cm", icono: "ruler.fill")
                
                // IMC con color semántico
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 14))
                            .foregroundColor(vm.perfil.colorIMC)
                        Text("IMC")
                            .font(.aidaEtiqueta)
                            .foregroundColor(.gray)
                    }
                    Text(String(format: "%.1f", vm.perfil.imc))
                        .font(.aidaTitulo)
                        .foregroundColor(.grisPizarra)
                    Text(vm.perfil.categoriaIMC)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(vm.perfil.colorIMC))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
            }
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
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 5)
    }
    
    // MARK: - Acciones
    private var seccionAcciones: some View {
        VStack(spacing: 12) {
            BotonPerfilAccion(
                titulo: "Editar perfil",
                icono: "person.crop.circle",
                color: .coralEnergetico,
                accion: { vm.prepararEdicion() }
            )
            
            BotonPerfilAccion(
                titulo: "Sobre AIda",
                icono: "sparkles",
                color: .magentaProfundo,
                accion: {}
            )
            
            // Versión de la app
            Text("AIda v1.0 — Hecho con ❤️")
                .font(.aidaNota)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
    }
}

// MARK: - Componentes del Perfil

struct TarjetaEstadistica: View {
    let titulo: String
    let valor: String
    let unidad: String
    let icono: String
    let color: Color
    var animarEntrada: Bool
    var delay: Double = 0
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icono)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(valor)
                .font(.aidaTitulo)
                .foregroundColor(.grisPizarra)
            
            Text(unidad)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(animarEntrada ? 1.0 : 0.7)
        .opacity(animarEntrada ? 1.0 : 0)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7).delay(delay),
            value: animarEntrada
        )
    }
}

struct DatoCorporalMini: View {
    let titulo: String
    let valor: String
    let unidad: String
    let icono: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icono)
                    .font(.system(size: 14))
                    .foregroundColor(.coralEnergetico)
                Text(titulo)
                    .font(.aidaEtiqueta)
                    .foregroundColor(.gray)
            }
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(valor)
                    .font(.aidaTitulo)
                    .foregroundColor(.grisPizarra)
                Text(unidad)
                    .font(.aidaEtiqueta)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
    }
}

struct BotonPerfilAccion: View {
    let titulo: String
    let icono: String
    let color: Color
    let accion: () -> Void
    
    var body: some View {
        Button(action: accion) {
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
        .buttonStyle(.plain)
    }
}

#Preview {
    PerfilView()
}
