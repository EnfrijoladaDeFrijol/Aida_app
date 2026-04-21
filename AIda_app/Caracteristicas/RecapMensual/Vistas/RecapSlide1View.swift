import SwiftUI

// MARK: - RecapSlide1View
// Slide 1: Intro + Resumen de actividad general.
// Estilo: Minimalista oscuro, tipografía grande, compartible en redes.

struct RecapSlide1View: View {
    @ObservedObject var viewModel: RecapViewModel
    
    @State private var aparecer = false
    @State private var contadorPasos: Int = 0
    
    private let fondo = Color(red: 0.06, green: 0.06, blue: 0.10)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                fondo.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // MARK: - Emoji grande divertido
                    Text("🏆")
                        .font(.system(size: 64))
                        .scaleEffect(aparecer ? 1 : 0.3)
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 20)
                    
                    // MARK: - Mes
                    Text(viewModel.mesCorto)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.35))
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 8)
                    
                    // MARK: - Título heroico
                    Text("Mi Recap")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(aparecer ? 1 : 0)
                        .offset(y: aparecer ? 0 : 15)
                    
                    Spacer().frame(height: 32)
                    
                    // MARK: - Métrica héroe: Pasos
                    VStack(spacing: 2) {
                        Text(formatearNumero(contadorPasos))
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                        
                        Text("pasos este mes")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 40)
                    
                    // MARK: - Stats grid minimalista
                    HStack(spacing: 0) {
                        statPill(valor: viewModel.caloriasFormateadas, etiqueta: "kcal", emoji: "🔥")
                        
                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 1, height: 44)
                        
                        statPill(valor: viewModel.kmFormateados, etiqueta: "km", emoji: "📍")
                        
                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 1, height: 44)
                        
                        statPill(valor: "\(viewModel.rutinasCompletadas)", etiqueta: "rutinas", emoji: "✅")
                    }
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white.opacity(0.05))
                    )
                    .padding(.horizontal, 24)
                    .opacity(aparecer ? 1 : 0)
                    .offset(y: aparecer ? 0 : 20)
                    
                    Spacer()
                    
                    // MARK: - Branding sutil
                    HStack(spacing: 6) {
                        Image("LogoAIda_negro")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white.opacity(0.2))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                        
                        Text("AIda Fitness")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 24)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                aparecer = true
            }
            animarContador()
        }
    }
    
    // MARK: - Stat pill
    private func statPill(valor: String, etiqueta: String, emoji: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 16))
            Text(valor)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(etiqueta)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Animación del contador
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
