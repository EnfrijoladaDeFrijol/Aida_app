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
    
    // MARK: - Tarjeta de Dieta
    private func tarjetaDieta(_ dieta: DietaGenerada) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Título de la dieta
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.coralEnergetico)
                Text("Sugerencia de Alimentación")
                    .font(.aidaSubtitulo)
                    .foregroundColor(.grisPizarra)
            }
            
            Text(dieta.descripcion)
                .font(.aidaCuerpo)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            // Lista de comidas
            VStack(spacing: 12) {
                ForEach(dieta.comidas) { comida in
                    filaComida(comida)
                }
            }
            
            // Lista de compras
            if let compras = dieta.listaCompras, !compras.isEmpty {
                Divider()
                    .padding(.vertical, 8)
                
                HStack {
                    Image(systemName: "cart.fill")
                        .foregroundColor(.greenMint)
                    Text("Lista de Compras")
                        .font(.aidaCuerpoDestacado)
                        .foregroundColor(.grisPizarra)
                    
                    Spacer()
                    
                    ShareLink(
                        item: "Lista de Compras - AIda:\n\n" + compras.map { "• \($0)" }.joined(separator: "\n"),
                        subject: Text("Lista de Compras")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.coralEnergetico)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(compras, id: \.self) { item in
                        HStack(spacing: 8) {
                            Image(systemName: "circle")
                                .font(.system(size: 10))
                                .foregroundColor(.gray.opacity(0.5))
                            Text(item)
                                .font(.aidaCuerpo)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 4)
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
    
    // MARK: - Fila de Comida
    private func filaComida(_ comida: Comida) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Punto de viñeta
            Circle()
                .fill(Color.coralEnergetico.opacity(0.6))
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(comida.tipo)
                    .font(.aidaCuerpoDestacado)
                    .foregroundColor(.grisPizarra)
                Text(comida.sugerencia)
                    .font(.aidaEtiqueta)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
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
    
    @State private var rutinaGuardada: Bool = false
    
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
            
            // Botón Guardar Rutina
            if let rutina = vm.rutinaGenerada {
                Button(action: {
                    GestorRutinas.compartido.guardarRutina(rutina)
                    withAnimation {
                        rutinaGuardada = true
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: rutinaGuardada ? "checkmark.circle.fill" : "heart.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(rutinaGuardada ? "¡Rutina Guardada!" : "Guardar Rutina")
                            .font(.aidaBoton)
                    }
                    .foregroundColor(rutinaGuardada ? .white : .magentaProfundo)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(rutinaGuardada ? Color.green : Color.magentaProfundo.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(rutinaGuardada ? Color.clear : Color.magentaProfundo.opacity(0.3), lineWidth: 1)
                    )
                }
                .disabled(rutinaGuardada)
            }
            
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
