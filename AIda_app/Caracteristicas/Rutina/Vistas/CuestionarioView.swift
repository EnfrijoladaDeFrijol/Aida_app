import SwiftUI

// MARK: - CuestionarioView
// Esta vista muestra las preguntas una por una con animaciones fluidas.
// Usa el RutinaViewModel para saber en qué paso va y qué ha seleccionado el usuario.

struct CuestionarioView: View {
    // Recibimos el ViewModel del padre (RutinaContenedorView)
    @Bindable var vm: RutinaViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- BARRA DE PROGRESO ---
            barraProgreso
            
            // --- TÍTULO DEL PASO ---
            VStack(spacing: 8) {
                Text(vm.tituloPasoActual)
                    .font(.aidaTituloGrande)
                    .foregroundColor(.grisPizarra)
                    .multilineTextAlignment(.center)
                
                Text(vm.subtituloPasoActual)
                    .font(.aidaCuerpo)
                    .foregroundColor(.gray)
            }
            .padding(.top, 24)
            .padding(.horizontal)
            
            // --- OPCIONES DEL PASO ACTUAL ---
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    contenidoDelPaso
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 100) // Espacio para el botón flotante
            }
            
            Spacer()
            
            // --- BOTONES DE NAVEGACIÓN ---
            botonesNavegacion
        }
    }
    
    // MARK: - Barra de Progreso
    private var barraProgreso: some View {
        VStack(spacing: 8) {
            // Indicador de paso: "Paso 1 de 4"
            Text("Paso \(vm.pasoActual + 1) de \(vm.totalPasos)")
                .font(.aidaEtiqueta)
                .foregroundColor(.gray)
            
            // Barra visual de progreso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Fondo gris
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                    
                    // Progreso con color animado
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [.coralEnergetico, .magentaProfundo],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * vm.progresoCuestionario, height: 6)
                        .animation(.spring(response: 0.4), value: vm.progresoCuestionario)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Contenido de cada paso
    // Según el paso actual, mostramos las opciones correspondientes
    @ViewBuilder
    private var contenidoDelPaso: some View {
        switch vm.pasoActual {
        case 0:
            // Tipo de ejercicio
            ForEach(TipoEjercicio.allCases) { opcion in
                TarjetaOpcion(
                    titulo: opcion.rawValue,
                    icono: opcion.icono,
                    color: opcion.color,
                    estaSeleccionada: vm.perfil.tipoEjercicio == opcion,
                    accion: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if vm.perfil.tipoEjercicio != opcion {
                                vm.perfil.tipoEjercicio = opcion
                                // Resetear campos que dependen del tipo de ejercicio
                                vm.perfil.objetivo = nil
                                vm.perfil.equipo = nil
                            }
                        }
                    }
                )
            }
        case 1:
            // Objetivo fitness
            ForEach(vm.opcionesObjetivo) { opcion in
                TarjetaOpcion(
                    titulo: opcion.rawValue,
                    icono: opcion.icono,
                    color: opcion.color,
                    estaSeleccionada: vm.perfil.objetivo == opcion,
                    accion: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.perfil.objetivo = opcion
                        }
                    }
                )
            }
        case 2:
            // Nivel de experiencia
            ForEach(NivelExperiencia.allCases) { opcion in
                TarjetaOpcion(
                    titulo: opcion.rawValue,
                    icono: opcion.icono,
                    color: opcion.color,
                    estaSeleccionada: vm.perfil.nivel == opcion,
                    accion: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.perfil.nivel = opcion
                        }
                    }
                )
            }
        case 3:
            // Duración
            ForEach(DuracionRutina.allCases) { opcion in
                TarjetaOpcion(
                    titulo: opcion.rawValue,
                    icono: opcion.icono,
                    color: opcion.color,
                    estaSeleccionada: vm.perfil.duracion == opcion,
                    accion: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.perfil.duracion = opcion
                        }
                    }
                )
            }
        case 4:
            // Equipo disponible
            ForEach(vm.opcionesEquipo) { opcion in
                TarjetaOpcion(
                    titulo: opcion.rawValue,
                    icono: opcion.icono,
                    color: opcion.color,
                    estaSeleccionada: vm.perfil.equipo == opcion,
                    accion: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.perfil.equipo = opcion
                        }
                    }
                )
            }
        default:
            EmptyView()
        }
    }
    
    // MARK: - Botones de Navegación
    private var botonesNavegacion: some View {
        HStack(spacing: 16) {
            // Botón Atrás (solo si no es el primer paso)
            if vm.pasoActual > 0 {
                Button(action: { vm.retrocederPaso() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text("Atrás")
                            .font(.aidaBoton)
                    }
                    .foregroundColor(.grisPizarra)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            
            // Botón Siguiente / Generar Rutina
            Button(action: { vm.avanzarPaso() }) {
                HStack(spacing: 8) {
                    Text(vm.esUltimoPaso ? "Generar Rutina" : "Siguiente")
                        .font(.aidaBoton)
                    Image(systemName: vm.esUltimoPaso ? "sparkles" : "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    vm.puedeAvanzar
                    ? LinearGradient(colors: [.coralEnergetico, .magentaProfundo], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(
                    color: vm.puedeAvanzar ? .magentaProfundo.opacity(0.3) : .clear,
                    radius: 8, x: 0, y: 4
                )
            }
            .disabled(!vm.puedeAvanzar)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
}

// MARK: - TarjetaOpcion (Componente Reutilizable)
// Cada opción del cuestionario se ve como una tarjeta con icono, texto y check.
struct TarjetaOpcion: View {
    let titulo: String
    let icono: String
    let color: Color
    let estaSeleccionada: Bool
    let accion: () -> Void
    
    var body: some View {
        Button(action: {
            accion()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack(spacing: 20) {
                // Icono con fondo circular
                ZStack {
                    Circle()
                        .fill(estaSeleccionada ? color : color.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: icono)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(estaSeleccionada ? .white : color)
                }
                
                // Texto
                Text(titulo)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(estaSeleccionada ? .bold : .medium)
                    .foregroundColor(estaSeleccionada ? .grisPizarra : .gray)
                
                Spacer()
                
                // Check de selección
                if estaSeleccionada {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(estaSeleccionada ? color.opacity(0.5) : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: estaSeleccionada ? color.opacity(0.2) : Color.black.opacity(0.04),
                radius: estaSeleccionada ? 12 : 6,
                x: 0, y: estaSeleccionada ? 6 : 3
            )
            .scaleEffect(estaSeleccionada ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
