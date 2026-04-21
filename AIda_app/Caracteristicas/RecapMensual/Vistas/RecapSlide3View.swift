import SwiftUI

// MARK: - RecapSlide3View
// Slide 3: Estado de Ánimo + Cierre motivacional.
// Estilo: Barras de ánimo con emojis, minimalista, compartible.

struct RecapSlide3View: View {
    @ObservedObject var viewModel: RecapViewModel
    
    @State private var aparecer = false
    @State private var mostrarBarras = false
    
    private let fondo = Color(red: 0.06, green: 0.06, blue: 0.10)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                fondo.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // MARK: - Header
                    Text("TU ÁNIMO DEL MES")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.3))
                        .opacity(aparecer ? 1 : 0)
                    
                    Spacer().frame(height: 16)
                    
                    // MARK: - Ánimo dominante
                    if let dom = viewModel.animoDominante {
                        VStack(spacing: 8) {
                            Image(systemName: dom.icono)
                                .font(.system(size: 52, weight: .medium))
                                .foregroundColor(dom.color)
                                .scaleEffect(aparecer ? 1 : 0.3)
                            
                            Text(dom.tipo)
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("\(dom.conteo) de \(viewModel.totalAnimosRegistrados) días")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .opacity(aparecer ? 1 : 0)
                    } else {
                        VStack(spacing: 8) {
                            Text("😊")
                                .font(.system(size: 52))
                            Text("Sin registros")
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Spacer().frame(height: 32)
                    
                    // MARK: - Barras de ánimo
                    if !viewModel.datosAnimoOrdenados.isEmpty {
                        VStack(spacing: 10) {
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
                        .opacity(aparecer ? 1 : 0)
                        .offset(y: aparecer ? 0 : 20)
                    }
                    
                    Spacer().frame(height: 36)
                    
                    // MARK: - Stats finales
                    HStack(spacing: 0) {
                        VStack(spacing: 2) {
                            Text(viewModel.pasosFormateados)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("pasos")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 1, height: 36)
                        
                        VStack(spacing: 2) {
                            Text(viewModel.caloriasFormateadas)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("kcal")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 1, height: 36)
                        
                        VStack(spacing: 2) {
                            Text("\(viewModel.rutinasCompletadas)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("rutinas")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.04))
                    )
                    .padding(.horizontal, 24)
                    .opacity(aparecer ? 1 : 0)
                    
                    Spacer()
                    
                    // MARK: - Cierre
                    VStack(spacing: 10) {
                        Text(viewModel.mensajeCierre)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.2))
                        
                        HStack(spacing: 6) {
                            Image("LogoAIda_negro")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white.opacity(0.15))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                            
                            Text("AIda")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.15))
                        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    mostrarBarras = true
                }
            }
        }
    }
    
    // MARK: - Barra de ánimo horizontal
    private func animoBar(nombre: String, icono: String, conteo: Int, color: Color, maxConteo: Int, index: Int) -> some View {
        HStack(spacing: 12) {
            // Ícono del ánimo
            Image(systemName: icono)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            // Nombre
            Text(nombre)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 70, alignment: .leading)
            
            // Barra
            GeometryReader { geo in
                let proporcion = maxConteo > 0 ? CGFloat(conteo) / CGFloat(maxConteo) : 0
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.6))
                    .frame(width: mostrarBarras ? max(geo.size.width * proporcion, 8) : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.08),
                        value: mostrarBarras
                    )
            }
            .frame(height: 8)
            
            // Conteo
            Text("\(conteo)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 24, alignment: .trailing)
        }
    }
}
