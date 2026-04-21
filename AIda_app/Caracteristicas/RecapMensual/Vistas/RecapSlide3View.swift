import SwiftUI

// MARK: - RecapSlide3View
// Slide 3: Estado de Ánimo + Cierre.
// Mascota Bravo en círculo, gradientes morado/coral, barras de ánimo.

struct RecapSlide3View: View {
    @ObservedObject var viewModel: RecapViewModel
    
    @State private var aparecer = false
    @State private var mostrarBarras = false
    
    private let fondo = RecapContenedorView.fondo
    
    var body: some View {
        ZStack {
            fondo
            
            // MARK: - Orbes de color
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: 80, y: -220)
                .blur(radius: 40)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.coralEnergetico.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .offset(x: -90, y: 280)
                .blur(radius: 50)
            
            // MARK: - Contenido
            VStack(spacing: 0) {
                
                Spacer()
                
                // Header
                Text("TU ÁNIMO DEL MES")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(5)
                    .foregroundColor(.white.opacity(0.3))
                    .opacity(aparecer ? 1 : 0)
                
                Spacer().frame(height: 14)
                
                // MARK: - Ánimo dominante
                if let dom = viewModel.animoDominante {
                    VStack(spacing: 6) {
                        // Mascota Bravo en círculo
                        ZStack {
                            Circle()
                                .fill(dom.color.opacity(0.1))
                                .frame(width: 110, height: 110)
                            
                            Circle()
                                .fill(fondo)
                                .frame(width: 98, height: 98)
                            
                            Image("AIDA_Bravo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 86, height: 86)
                                .clipShape(Circle())
                        }
                        .scaleEffect(aparecer ? 1 : 0.3)
                        .opacity(aparecer ? 1 : 0)
                        
                        Text(dom.tipo)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("\(dom.conteo) de \(viewModel.totalAnimosRegistrados) días")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .opacity(aparecer ? 1 : 0)
                } else {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.05))
                                .frame(width: 98, height: 98)
                            Image("AIDA_Bravo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 86, height: 86)
                                .clipShape(Circle())
                        }
                        Text("Sin registros")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer().frame(height: 20)
                
                // MARK: - Barras de ánimo
                if !viewModel.datosAnimoOrdenados.isEmpty {
                    VStack(spacing: 7) {
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
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.04))
                    )
                    .padding(.horizontal, 24)
                    .opacity(aparecer ? 1 : 0)
                    .offset(y: aparecer ? 0 : 15)
                }
                
                Spacer().frame(height: 20)
                
                // MARK: - Stats finales
                HStack(spacing: 0) {
                    miniStatFinal(valor: viewModel.pasosFormateados, etiqueta: "pasos")
                    
                    Rectangle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 1, height: 30)
                    
                    miniStatFinal(valor: viewModel.caloriasFormateadas, etiqueta: "kcal")
                    
                    Rectangle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 1, height: 30)
                    
                    miniStatFinal(valor: "\(viewModel.rutinasCompletadas)", etiqueta: "rutinas")
                }
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(0.03))
                )
                .padding(.horizontal, 28)
                .opacity(aparecer ? 1 : 0)
                
                Spacer()
                
                // MARK: - Cierre
                VStack(spacing: 6) {
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
                
                Spacer().frame(height: 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                aparecer = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.4)) {
                    mostrarBarras = true
                }
            }
        }
    }
    
    // MARK: - Mini stat final
    private func miniStatFinal(valor: String, etiqueta: String) -> some View {
        VStack(spacing: 1) {
            Text(valor)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(etiqueta)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Barra de ánimo
    private func animoBar(nombre: String, icono: String, conteo: Int, color: Color, maxConteo: Int, index: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icono)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color)
                .frame(width: 18)
            
            Text(nombre)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 62, alignment: .leading)
            
            GeometryReader { geo in
                let proporcion = maxConteo > 0 ? CGFloat(conteo) / CGFloat(maxConteo) : 0
                RoundedRectangle(cornerRadius: 3)
                    .fill(color.opacity(0.5))
                    .frame(width: mostrarBarras ? max(geo.size.width * proporcion, 6) : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.07),
                        value: mostrarBarras
                    )
            }
            .frame(height: 6)
            
            Text("\(conteo)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 20, alignment: .trailing)
        }
    }
}
