import SwiftUI

// MARK: - RecapSlide1View
// Slide 1: Intro — Mascota en círculo, gradientes de color de fondo.
// Minimalista, limpio, compartible.

struct RecapSlide1View: View {
    @ObservedObject var viewModel: RecapViewModel
    
    @State private var aparecer = false
    @State private var contadorPasos: Int = 0
    
    private let fondo = RecapContenedorView.fondo
    
    var body: some View {
        let deporte = viewModel.deporteEstrella
        
        ZStack {
            fondo
            
            // MARK: - Orbes de color de fondo (gradientes, NO imagen)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.coralEnergetico.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -80, y: -200)
                .blur(radius: 40)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.magentaProfundo.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 160
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 200)
                .blur(radius: 50)
            
            // MARK: - Contenido
            VStack(spacing: 0) {
                
                Spacer()
                
                // Mes
                Text(viewModel.mesCorto)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(5)
                    .foregroundColor(.white.opacity(0.3))
                    .opacity(aparecer ? 1 : 0)
                
                Spacer().frame(height: 8)
                
                // Título
                Text("Mi Recap")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(aparecer ? 1 : 0)
                    .offset(y: aparecer ? 0 : 10)
                
                Spacer().frame(height: 24)
                
                // MARK: - Mascota en círculo (sin fondo cuadrado)
                ZStack {
                    // Resplandor detrás
                    Circle()
                        .fill(deporte.color.opacity(0.12))
                        .frame(width: 170, height: 170)
                    
                    Circle()
                        .fill(fondo)
                        .frame(width: 155, height: 155)
                    
                    Image(deporte.imagenMascota)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                }
                .scaleEffect(aparecer ? 1 : 0.5)
                .opacity(aparecer ? 1 : 0)
                
                Spacer().frame(height: 24)
                
                // MARK: - Pasos
                VStack(spacing: 0) {
                    Text(formatearNumero(contadorPasos))
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                    
                    Text("pasos este mes")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                }
                .opacity(aparecer ? 1 : 0)
                
                Spacer().frame(height: 24)
                
                // MARK: - Stats
                HStack(spacing: 0) {
                    statPill(valor: viewModel.caloriasFormateadas, etiqueta: "kcal", emoji: "🔥")
                    
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 1, height: 36)
                    
                    statPill(valor: viewModel.kmFormateados, etiqueta: "km", emoji: "📍")
                    
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 1, height: 36)
                    
                    statPill(valor: "\(viewModel.rutinasCompletadas)", etiqueta: "rutinas", emoji: "✅")
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white.opacity(0.05))
                )
                .padding(.horizontal, 28)
                .opacity(aparecer ? 1 : 0)
                .offset(y: aparecer ? 0 : 15)
                
                Spacer()
                
                // Branding
                HStack(spacing: 5) {
                    Image("LogoAIda_negro")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white.opacity(0.15))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                    
                    Text("AIda Fitness")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.15))
                }
                .opacity(aparecer ? 1 : 0)
                
                Spacer().frame(height: 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                aparecer = true
            }
            animarContador()
        }
    }
    
    private func statPill(valor: String, etiqueta: String, emoji: String) -> some View {
        VStack(spacing: 3) {
            Text(emoji)
                .font(.system(size: 14))
            Text(valor)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(etiqueta)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func animarContador() {
        let objetivo = viewModel.pasosTotales
        guard objetivo > 0 else { return }
        let pasos = 35
        let intervalo = 1.2 / Double(pasos)
        for i in 1...pasos {
            DispatchQueue.main.asyncAfter(deadline: .now() + intervalo * Double(i)) {
                withAnimation(.easeOut(duration: 0.05)) {
                    let progreso = Double(i) / Double(pasos)
                    let factor = 1 - pow(1 - progreso, 3)
                    contadorPasos = Int(Double(objetivo) * factor)
                }
            }
        }
    }
    
    private func formatearNumero(_ numero: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        return f.string(from: NSNumber(value: numero)) ?? "0"
    }
}
