import SwiftUI

// MARK: - RutinaContenedorView
// Esta es la vista PRINCIPAL del tab "Rutina".
// Actúa como un "contenedor" que muestra la pantalla correcta
// según el estado del flujo:
//   .cuestionario → CuestionarioView
//   .generando    → Pantalla de carga animada
//   .rutinaLista  → RutinaResultadoView
//   .error        → Pantalla de error

struct RutinaContenedorView: View {
    @State private var vm = RutinaViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con gradiente sutil
                LinearGradient(
                    colors: [.rosaBruma, .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Mostramos la vista que corresponde al estado actual
                switch vm.estado {
                case .cuestionario:
                    CuestionarioView(vm: vm)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    
                case .generando:
                    vistaGenerando
                        .transition(.opacity)
                    
                case .rutinaLista:
                    RutinaResultadoView(vm: vm)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    
                case .error:
                    vistaError
                        .transition(.opacity)
                }
            }
            .navigationTitle(tituloNavegacion)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: vm.estado)
        }
    }
    
    // MARK: - Título dinámico según el estado
    private var tituloNavegacion: String {
        switch vm.estado {
        case .cuestionario: return "Tu Rutina 💪"
        case .generando: return "Generando..."
        case .rutinaLista: return "¡Lista! 🎉"
        case .error: return "Oops 😅"
        }
    }
    
    // MARK: - Vista de Carga (mientras Gemini genera)
    private var vistaGenerando: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animación del ícono de AIda
            ZStack {
                // Círculos pulsantes
                Circle()
                    .fill(Color.coralEnergetico.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animarPulso ? 1.3 : 1.0)
                    .opacity(animarPulso ? 0 : 0.5)
                
                Circle()
                    .fill(Color.magentaProfundo.opacity(0.1))
                    .frame(width: 90, height: 90)
                    .scaleEffect(animarPulso ? 1.2 : 1.0)
                    .opacity(animarPulso ? 0 : 0.5)
                
                // Ícono central
                Circle()
                    .fill(LinearGradient(
                        colors: [.coralEnergetico, .magentaProfundo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(animarPulso ? 360 : 0))
                    )
            }
            
            VStack(spacing: 10) {
                Text("AIda está creando tu rutina...")
                    .font(.aidaTitulo)
                    .foregroundColor(.grisPizarra)
                
                Text("Analizando tu perfil y objetivos")
                    .font(.aidaCuerpo)
                    .foregroundColor(.gray)
            }
            
            ProgressView()
                .tint(.coralEnergetico)
                .scaleEffect(1.2)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animarPulso = true
            }
        }
        .onDisappear {
            animarPulso = false
        }
    }
    
    @State private var animarPulso = false
    
    // MARK: - Vista de Error
    private var vistaError: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 10) {
                Text("Algo salió mal")
                    .font(.aidaTitulo)
                    .foregroundColor(.grisPizarra)
                
                Text(vm.mensajeError)
                    .font(.aidaCuerpo)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                // Reintentar
                Button(action: { vm.regenerarRutina() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("Reintentar")
                    }
                    .font(.aidaBoton)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.coralEnergetico, .magentaProfundo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                
                // Volver al cuestionario
                Button(action: { vm.reiniciarCuestionario() }) {
                    Text("Volver al cuestionario")
                        .font(.aidaEtiqueta)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

// Necesitamos que EstadoFlujo sea Equatable para la animación
extension RutinaViewModel.EstadoFlujo: Equatable {}

#Preview {
    RutinaContenedorView()
}
