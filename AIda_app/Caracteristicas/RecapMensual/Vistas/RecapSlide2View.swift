import SwiftUI

// MARK: - RecapSlide2View
// Slide 2: Deporte Estrella — Mascota prominente con stats detalladas.
// Blur de fondo con la mascota, tarjetas limpias.

struct RecapSlide2View: View {
    @ObservedObject var viewModel: RecapViewModel
    
    @State private var aparecer = false
    
    private let fondo = Color(red: 0.06, green: 0.06, blue: 0.10)
    
    var body: some View {
        let deporte = viewModel.deporteEstrella
        
        GeometryReader { geo in
            ZStack {
                fondo.ignoresSafeArea()
                
                // MARK: - Mascota blur de fondo
                Image(deporte.imagenMascota)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width * 1.4, height: geo.size.height * 0.8)
                    .clipped()
                    .blur(radius: 50)
                    .opacity(0.25)
                    .offset(y: 60)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // MARK: - Header
                    Text("DEPORTE ESTRELLA")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(5)
                        .foregroundColor(.white.opacity(0.3))
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 14)
                    
                    // MARK: - Nombre del deporte
                    Text(deporte.nombre)
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(aparecer ? 1 : 0)
                    
                    Text(deporte.mensaje)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(deporte.color.opacity(0.7))
                        .padding(.top, 2)
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 20)
                    
                    // MARK: - Mascota hero
                    Image(deporte.imagenMascota)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .scaleEffect(aparecer ? 1 : 0.4)
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 24)
                    
                    // MARK: - Tarjetas de stats
                    VStack(spacing: 10) {
                        // Fila 1: Métricas principales
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
                                    color: .yellow
                                )
                            }
                        }
                        
                        // Fila 2: Stats complementarias
                        HStack(spacing: 10) {
                            if viewModel.sesionesNado > 0 {
                                miniStat(valor: "\(viewModel.sesionesNado)", etiqueta: "sesiones nado")
                            }
                            
                            if viewModel.elevacion > 0 {
                                miniStat(valor: String(format: "%.0f", viewModel.elevacion), etiqueta: "m elevación")
                            }
                            
                            miniStat(valor: viewModel.caloriasFormateadas, etiqueta: "kcal")
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(aparecer ? 1 : 0)
                    .offset(y: aparecer ? 0 : 20)
                    
                    Spacer()
                    
                    // Racha
                    if viewModel.rachaActual > 0 {
                        HStack(spacing: 6) {
                            Text("⚡")
                                .font(.system(size: 13))
                            Text("\(viewModel.rachaActual) días de racha")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .opacity(aparecer ? 1 : 0)
                    }
                    
                    Spacer().frame(height: 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                aparecer = true
            }
        }
    }
    
    // MARK: - Stat Card
    private func statCard(valor: String, etiqueta: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(valor)
                .font(.system(size: 24, weight: .black, design: .rounded))
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
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Mini stat
    private func miniStat(valor: String, etiqueta: String) -> some View {
        VStack(spacing: 3) {
            Text(valor)
                .font(.system(size: 15, weight: .bold, design: .rounded))
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
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white.opacity(0.04))
        )
    }
}
