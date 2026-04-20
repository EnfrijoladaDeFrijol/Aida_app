import SwiftUI

struct BotonAIda: View {
    let titulo: String
    var icono: String? = nil // Opcional: Para agregar un SF Symbol
    let accion: () -> Void
    var colorFondo: Color = .aidaAcento
    
    // Estados clave para la UX
    var estaDeshabilitado: Bool = false
    var estaCargando: Bool = false
    
    var body: some View {
        Button(action: accion) {
            HStack(spacing: 12) {
                // Si está cargando la IA, mostramos el spinner
                if estaCargando {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    // Si no carga y hay ícono, lo mostramos
                    if let icono = icono {
                        Image(systemName: icono)
                            .font(.system(size: 20, weight: .bold))
                    }
                    Text(titulo)
                        .font(.aidaBoton)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            // La lógica visual cambia si está deshabilitado o cargando
            .background(estaDeshabilitado || estaCargando ? colorFondo.opacity(0.4) : colorFondo)
            .cornerRadius(16)
            // Quitamos la sombra si no se puede usar, para que se vea "plano"
            .shadow(color: estaDeshabilitado || estaCargando ? .clear : colorFondo.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        // Aplicamos nuestro estilo personalizado de presión
        .buttonStyle(EstiloBotonAIda())
        // Deshabilitamos el toque real si aplica
        .disabled(estaDeshabilitado || estaCargando)
        .padding(.horizontal)
    }
}

// --- ESTILO PERSONALIZADO PARA ANIMACIÓN FLUIDA ---
struct EstiloBotonAIda: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Efecto de escala al mantener presionado (muy Apple-like)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

// --- PREVIEW ---
#Preview {
    VStack(spacing: 20) {
        BotonAIda(titulo: "Guardar Ánimo", accion: {})
        
        BotonAIda(titulo: "Generando Rutina con IA...", accion: {}, estaCargando: true)
        
        BotonAIda(titulo: "Faltan datos", accion: {}, colorFondo: .aidaGris, estaDeshabilitado: true)
        
        BotonAIda(titulo: "Conectar Apple Health", icono: "heart.fill", accion: {}, colorFondo: .aidaRojo)
    }
}
