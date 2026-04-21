import SwiftUI

// MARK: - RecapSlide2View
// Slide 2: Deporte Estrella — Mascota en círculo, gradientes de color.
// Stats en tarjetas limpias, divertido, compartible.

struct RecapSlide2View: View {
    @ObservedObject var viewModel: RecapViewModel
    
    @State private var aparecer = false
    
    private let fondo = RecapContenedorView.fondo
    
    var body: some View {
        let deporte = viewModel.deporteEstrella
        
        ZStack {
            fondo
            
            // MARK: - Orbes de color del deporte
            Circle()
                .fill(
                    RadialGradient(
                        colors: [deporte.color.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 60, y: -180)
                .blur(radius: 40)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.greenMint.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .offset(x: -100, y: 250)
                .blur(radius: 50)
            
            // MARK: - Contenido
            VStack(spacing: 0) {
                
                Spacer()
                
                // Header
                Text("DEPORTE ESTRELLA")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(5)
                    .foregroundColor(.white.opacity(0.3))
                    .opacity(aparecer ? 1 : 0)
                
                Spacer().frame(height: 10)
                
                // Nombre
                Text(deporte.nombre)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(aparecer ? 1 : 0)
                
                Text(deporte.mensaje)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(deporte.color.opacity(0.7))
                    .padding(.top, 2)
                    .opacity(aparecer ? 1 : 0)
                
                Spacer().frame(height: 20)
                
                // MARK: - Mascota en círculo
                ZStack {
                    // Resplandor
                    Circle()
                        .fill(deporte.color.opacity(0.1))
                        .frame(width: 165, height: 165)
                    
                    Circle()
                        .fill(fondo)
                        .frame(width: 150, height: 150)
                    
                    Image(deporte.imagenMascota)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 135, height: 135)
                        .clipShape(Circle())
                }
                .scaleEffect(aparecer ? 1 : 0.4)
                .opacity(aparecer ? 1 : 0)
                
                Spacer().frame(height: 24)
                
                // MARK: - Stats principales
                HStack(spacing: 10) {
                    statCard(
                        valor: deporte.metricaPrincipal,
                        etiqueta: deporte.unidadPrincipal,
                        color: deporte.color
                    )
                    
                    if !deporte.metricaSecundaria.isEmpty {
                        statCard(
                            valor: deporte.metricaSecundaria,
                            etiqueta: deporte.unidadSecundaria,
                            color: .yellow.opacity(0.8)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .opacity(aparecer ? 1 : 0)
                .offset(y: aparecer ? 0 : 18)
                
                Spacer().frame(height: 10)
                
                // MARK: - Stats secundarias
                HStack(spacing: 10) {
                    if viewModel.sesionesNado > 0 {
                        miniStat(valor: "\(viewModel.sesionesNado)", etiqueta: "sesiones nado")
                    }
                    
                    if viewModel.elevacion > 0 {
                        miniStat(valor: String(format: "%.0f", viewModel.elevacion), etiqueta: "m elevación")
                    }
                    
                    miniStat(valor: viewModel.caloriasFormateadas, etiqueta: "kcal")
                }
                .padding(.horizontal, 24)
                .opacity(aparecer ? 1 : 0)
                .offset(y: aparecer ? 0 : 18)
                
                Spacer()
                
                // Racha
                if viewModel.rachaActual > 0 {
                    HStack(spacing: 5) {
                        Text("⚡")
                            .font(.system(size: 13))
                        Text("\(viewModel.rachaActual) días de racha")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.25))
                    }
                    .opacity(aparecer ? 1 : 0)
                }
                
                Spacer().frame(height: 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                aparecer = true
            }
        }
    }
    
    // MARK: - Stat Card
    private func statCard(valor: String, etiqueta: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Text(valor)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text(etiqueta)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(color.opacity(0.12), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Mini stat
    private func miniStat(valor: String, etiqueta: String) -> some View {
        VStack(spacing: 3) {
            Text(valor)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(etiqueta)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white.opacity(0.03))
        )
    }
}
