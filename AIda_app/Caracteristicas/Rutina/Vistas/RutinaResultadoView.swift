import SwiftUI

// MARK: - RutinaResultadoView
// Muestra la rutina generada por Gemini de forma visual y atractiva.
// Incluye las secciones con ejercicios, mensaje motivacional,
// y botones para regenerar o volver al cuestionario.

struct RutinaResultadoView: View {
    @Bindable var vm: RutinaViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // --- CABECERA CON NOMBRE DE LA RUTINA ---
                if let rutina = vm.rutinaGenerada {
                    cabeceraRutina(rutina)
                    
                    // --- MENSAJE MOTIVACIONAL ---
                    mensajeMotivacional(rutina.mensajeMotivacional)
                    
                    // --- SECCIONES DE EJERCICIOS ---
                    if rutina.secciones.isEmpty, let textoLibre = rutina.textoLibre {
                        // Si Gemini no devolvió JSON válido, mostramos el texto
                        tarjetaTextoLibre(textoLibre)
                    } else {
                        ForEach(rutina.secciones) { seccion in
                            tarjetaSeccion(seccion)
                        }
                    }
                    
                    // --- BOTONES DE ACCIÓN ---
                    botonesAccion
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Cabecera
    private func cabeceraRutina(_ rutina: RutinaGenerada) -> some View {
        VStack(spacing: 12) {
            // Icono grande animado
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.coralEnergetico.opacity(0.2), .magentaProfundo.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.coralEnergetico, .magentaProfundo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(rutina.nombre)
                .font(.aidaTitulo)
                .foregroundColor(.grisPizarra)
                .multilineTextAlignment(.center)
            
            // Duración estimada
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                Text(rutina.duracionEstimada)
                    .font(.aidaEtiqueta)
            }
            .foregroundColor(.gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(Color.gray.opacity(0.1))
            )
        }
        .padding(.top, 8)
    }
    
    // MARK: - Mensaje Motivacional
    private func mensajeMotivacional(_ mensaje: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(LinearGradient(
                    colors: [.coralEnergetico, .magentaProfundo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AIda dice:")
                    .font(.aidaEtiqueta)
                    .fontWeight(.bold)
                    .foregroundColor(.magentaProfundo)
                Text(mensaje)
                    .font(.aidaCuerpo)
                    .foregroundColor(.grisPizarra)
                    .lineSpacing(4)
            }
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
    }
    
    // MARK: - Tarjeta de Sección
    private func tarjetaSeccion(_ seccion: SeccionRutina) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Título de la sección
            Text(seccion.titulo)
                .font(.aidaSubtitulo)
                .foregroundColor(.grisPizarra)
            
            // Lista de ejercicios
            VStack(spacing: 12) {
                ForEach(seccion.ejercicios) { ejercicio in
                    filaEjercicio(ejercicio)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Fila de Ejercicio
    private func filaEjercicio(_ ejercicio: Ejercicio) -> some View {
        HStack(spacing: 14) {
            // Punto de viñeta con color
            Circle()
                .fill(LinearGradient(
                    colors: [.coralEnergetico, .magentaProfundo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ejercicio.nombre)
                    .font(.aidaCuerpoDestacado)
                    .foregroundColor(.grisPizarra)
                Text(ejercicio.detalle)
                    .font(.aidaEtiqueta)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Texto Libre (fallback)
    private func tarjetaTextoLibre(_ texto: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tu Rutina")
                .font(.aidaSubtitulo)
                .foregroundColor(.grisPizarra)
            
            Text(texto)
                .font(.aidaCuerpo)
                .foregroundColor(.grisPizarra)
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Botones de Acción
    private var botonesAccion: some View {
        VStack(spacing: 14) {
            // Botón COMPLETAR rutina (actualiza la racha)
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    vm.completarRutina()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: vm.rutinaCompletada ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.system(size: 20, weight: .bold))
                    
                    if vm.rutinaCompletada {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("¡Rutina completada!")
                                .font(.aidaBoton)
                            Text("🔥 Racha: \(GestorRacha.compartido.rachaActual) días")
                                .font(.aidaEtiqueta)
                                .opacity(0.9)
                        }
                    } else {
                        Text("Completar rutina")
                            .font(.aidaBoton)
                    }
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    vm.rutinaCompletada
                    ? LinearGradient(colors: [.greenMint, .green], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [.coralEnergetico, .magentaProfundo], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(
                    color: vm.rutinaCompletada ? .greenMint.opacity(0.3) : .magentaProfundo.opacity(0.3),
                    radius: 8, x: 0, y: 4
                )
            }
            .disabled(vm.rutinaCompletada)
            .scaleEffect(vm.rutinaCompletada ? 1.03 : 1.0)
            
            // Botón regenerar
            if !vm.rutinaCompletada {
                Button(action: { vm.regenerarRutina() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.trianglehead.2.counterclockwise")
                            .font(.system(size: 16, weight: .bold))
                        Text("Regenerar con AIda")
                            .font(.aidaBoton)
                    }
                    .foregroundColor(.grisPizarra)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            
            // Botón nuevo cuestionario
            Button(action: { vm.reiniciarCuestionario() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 14, weight: .bold))
                    Text("Nuevo cuestionario")
                        .font(.aidaEtiqueta)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.gray)
                .padding(.vertical, 12)
            }
        }
        .padding(.top, 8)
    }
}
