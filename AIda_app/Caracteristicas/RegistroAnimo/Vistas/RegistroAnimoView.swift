import SwiftUI
import SwiftData

struct RegistroAnimoView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @State private var vm = RegistroAnimoViewModel()
    
    var body: some View {
        ZStack {
            // Fondo Dinámico Premium
            vm.colorFondoDinamico
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: vm.animoSeleccionado)
            
            VStack(spacing: 24) {
                // --- CABECERA ELEGANTE ---
                VStack(spacing: 8) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                    
                    Text(vm.saludo)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                    
                    Text("¿Cómo te sientes hoy?")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.grisPizarra)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // --- LISTA VERTICAL PREMIUM ---
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(TipoAnimo.allCases) { animo in
                            TarjetaAnimoPremium(
                                animo: animo,
                                estaSeleccionado: vm.animoSeleccionado == animo,
                                accion: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        vm.seleccionarAnimo(animo)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                
                // --- BOTÓN DE GUARDAR FLOTANTE ---
                Button(action: {
                    if vm.guardarAnimo(context: context) {
                        dismiss()
                    }
                }) {
                    Text(vm.textoBoton)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(vm.colorBoton)
                        .clipShape(Capsule())
                        .shadow(
                            color: vm.colorSombraBoton,
                            radius: 12, x: 0, y: 6
                        )
                }
                .disabled(!vm.puedeGuardar)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                .animation(.spring(), value: vm.animoSeleccionado)
            }
        }
        .onAppear {
            vm.cargarAnimoGuardado()
        }
    }
}

// --- SUBCOMPONENTE: Tarjeta Estilo Píldora Premium ---
struct TarjetaAnimoPremium: View {
    let animo: TipoAnimo
    let estaSeleccionado: Bool
    let accion: () -> Void
    
    var body: some View {
        Button(action: accion) {
            HStack(spacing: 20) {
                // 1. Icono con fondo circular suave
                ZStack {
                    Circle()
                        .fill(estaSeleccionado ? animo.colorAsociado : animo.colorAsociado.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: animo.icono)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(estaSeleccionado ? .white : animo.colorAsociado)
                        .scaleEffect(estaSeleccionado ? 1.15 : 1.0)
                }
                
                // 2. Texto
                Text(animo.rawValue)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(estaSeleccionado ? .bold : .medium)
                    .foregroundColor(estaSeleccionado ? .grisPizarra : .gray)
                
                Spacer()
                
                // 3. Indicador visual de selección
                if estaSeleccionado {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(animo.colorAsociado)
                        // Transición suave al aparecer
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(12)
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity)
            // SOLUCIÓN AL FONDO NEGRO: Añadimos .fill() al RoundedRectangle
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
            )
            // Borde sutil al seleccionar
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(estaSeleccionado ? animo.colorAsociado.opacity(0.5) : Color.clear, lineWidth: 2)
            )
            // Sombra refinada
            .shadow(
                color: estaSeleccionado ? animo.colorAsociado.opacity(0.2) : Color.black.opacity(0.05),
                radius: estaSeleccionado ? 15 : 8,
                x: 0, y: estaSeleccionado ? 8 : 4
            )
            // Efecto de levantamiento al seleccionar
            .scaleEffect(estaSeleccionado ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RegistroAnimoView()
}
