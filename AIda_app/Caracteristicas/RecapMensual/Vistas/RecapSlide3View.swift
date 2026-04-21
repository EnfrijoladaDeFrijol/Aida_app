import SwiftUI

// MARK: - RecapSlide3View
// Slide 3: Estado de Ánimo + Cierre.
// Mascota Bravo (celebrando) con blur, barras de ánimo, resumen final.

struct RecapSlide3View: View {
    @ObservedObject var viewModel: RecapViewModel
    
    @State private var aparecer = false
    @State private var mostrarBarras = false
    
    private let fondo = Color(red: 0.06, green: 0.06, blue: 0.10)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                fondo.ignoresSafeArea()
                
                // MARK: - Mascota Bravo blur de fondo
                Image("AIDA_Bravo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width * 1.3, height: geo.size.height * 0.6)
                    .clipped()
                    .blur(radius: 45)
                    .opacity(0.2)
                    .offset(y: -80)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // MARK: - Header
                    Text("TU ÁNIMO DEL MES")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(5)
                        .foregroundColor(.white.opacity(0.3))
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 12)
                    
                    // MARK: - Ánimo dominante con mascota
                    if let dom = viewModel.animoDominante {
                        VStack(spacing: 8) {
                            // Mascota Bravo pequeña arriba
                            Image("AIDA_Bravo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .scaleEffect(aparecer ? 1 : 0.3)
                                .opacity(aparecer ? 1 : 0)
                            
                            Text(dom.tipo)
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("\(dom.conteo) de \(viewModel.totalAnimosRegistrados) días")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .opacity(aparecer ? 1 : 0)
                    } else {
                        VStack(spacing: 8) {
                            Image("AIDA_Bravo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                            Text("Sin registros")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Spacer().frame(height: 24)
                    
                    // MARK: - Barras de ánimo
                    if !viewModel.datosAnimoOrdenados.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.datosAnimoOrdenados.enumerated()), id: \.offset) { index, dato in
                                animoBar(
                                    nombre: dato.nombre,
                                    icono: dato.icono,
                                    conteo: dato.conteo,
                                    color: dato.color,
                                    maxConteo: viewModel.datosAnimoOrdenados.first?.conteo ?? 1,
                                    index: index
                                )
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial.opacity(0.3))
                        )
                        .padding(.horizontal, 20)
                        .opacity(aparecer ? 1 : 0)
                        .offset(y: aparecer ? 0 : 18)
                    }
                    
                    Spacer().frame(height: 24)
                    
                    // MARK: - Stats finales
                    HStack(spacing: 0) {
                        VStack(spacing: 2) {
                            Text(viewModel.pasosFormateados)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("pasos")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(.white.opacity(0.06))
                            .frame(width: 1, height: 32)
                        
                        VStack(spacing: 2) {
                            Text(viewModel.caloriasFormateadas)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("kcal")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(.white.opacity(0.06))
                            .frame(width: 1, height: 32)
                        
                        VStack(spacing: 2) {
                            Text("\(viewModel.rutinasCompletadas)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("rutinas")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white.opacity(0.04))
                    )
                    .padding(.horizontal, 24)
                    .opacity(aparecer ? 1 : 0)
                    
                    Spacer()
                    
                    // MARK: - Cierre
                    VStack(spacing: 8) {
                        Text(viewModel.mensajeCierre)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.2))
                        
                        HStack(spacing: 5) {
                            Image("LogoAIda_negro")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white.opacity(0.15))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 13, height: 13)
                            
                            Text("AIda")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.15))
                        }
                    }
                    .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                aparecer = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    mostrarBarras = true
                }
            }
        }
    }
    
    // MARK: - Barra de ánimo horizontal
    private func animoBar(nombre: String, icono: String, conteo: Int, color: Color, maxConteo: Int, index: Int) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(nombre)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
                .frame(width: 65, alignment: .leading)
            
            GeometryReader { geo in
                let proporcion = maxConteo > 0 ? CGFloat(conteo) / CGFloat(maxConteo) : 0
                RoundedRectangle(cornerRadius: 3)
                    .fill(color.opacity(0.5))
                    .frame(width: mostrarBarras ? max(geo.size.width * proporcion, 6) : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.08),
                        value: mostrarBarras
                    )
            }
            .frame(height: 6)
            
            Text("\(conteo)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 22, alignment: .trailing)
        }
    }
}
