import SwiftUI

// MARK: - RecapSlide2View
// Slide 2: Deporte Estrella + Stats detalladas.
// Estilo: Tarjetas limpias con emojis, divertido, compartible.

struct RecapSlide2View: View {
    @ObservedObject var viewModel: RecapViewModel
    
    @State private var aparecer = false
    
    private let fondo = Color(red: 0.06, green: 0.06, blue: 0.10)
    
    var body: some View {
        let deporte = viewModel.deporteEstrella
        
        GeometryReader { geo in
            ZStack {
                fondo.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // MARK: - Header
                    Text("DEPORTE ESTRELLA")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.3))
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 16)
                    
                    // MARK: - Emoji grande
                    Text(deporte.emoji)
                        .font(.system(size: 72))
                        .scaleEffect(aparecer ? 1 : 0.3)
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 12)
                    
                    // MARK: - Nombre del deporte
                    Text(deporte.nombre)
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(aparecer ? 1 : 0)
                    
                    Text(deporte.mensaje)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(deporte.color.opacity(0.8))
                        .padding(.top, 2)
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 36)
                    
                    // MARK: - Tarjetas de stats por deporte
                    VStack(spacing: 12) {
                        // Fila 1: Métrica principal + secundaria
                        HStack(spacing: 12) {
                            statCard(
                                emoji: deporte.emoji,
                                valor: deporte.metricaPrincipal,
                                etiqueta: deporte.unidadPrincipal,
                                color: deporte.color
                            )
                            
                            if !deporte.metricaSecundaria.isEmpty {
                                statCard(
                                    emoji: "🏅",
                                    valor: deporte.metricaSecundaria,
                                    etiqueta: deporte.unidadSecundaria,
                                    color: .yellow
                                )
                            }
                        }
                        
                        // Fila 2: Stats complementarias
                        HStack(spacing: 12) {
                            if viewModel.metrosNatacion > 0 {
                                miniStat(emoji: "🏊", valor: "\(viewModel.sesionesNado)", etiqueta: "sesiones de nado")
                            }
                            
                            if viewModel.kmTotales > 0 {
                                miniStat(emoji: "⛰️", valor: String(format: "%.0f", viewModel.elevacion), etiqueta: "m de elevación")
                            }
                            
                            miniStat(emoji: "🔥", valor: viewModel.caloriasFormateadas, etiqueta: "kcal quemadas")
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(aparecer ? 1 : 0)
                    .offset(y: aparecer ? 0 : 25)
                    
                    Spacer()
                    
                    // Racha
                    if viewModel.rachaActual > 0 {
                        HStack(spacing: 6) {
                            Text("⚡")
                                .font(.system(size: 14))
                            Text("\(viewModel.rachaActual) días de racha")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .opacity(aparecer ? 1 : 0)
                    }
                    
                    Spacer().frame(height: 24)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                aparecer = true
            }
        }
    }
    
    // MARK: - Stat Card grande
    private func statCard(emoji: String, valor: String, etiqueta: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 24))
            
            Text(valor)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text(etiqueta)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Mini stat
    private func miniStat(emoji: String, valor: String, etiqueta: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 16))
            Text(valor)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(etiqueta)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.04))
        )
    }
}
