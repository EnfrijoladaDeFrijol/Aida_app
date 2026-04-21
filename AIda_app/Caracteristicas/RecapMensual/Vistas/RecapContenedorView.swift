import SwiftUI
import SwiftData

// MARK: - RecapContenedorView
// Contenedor principal del Recap Mensual.
// Fondo oscuro premium, paginación horizontal, botón para compartir.

struct RecapContenedorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = RecapViewModel()
    @State private var paginaActual = 0
    @State private var mostrarShareSheet = false
    @State private var imagenExportar: UIImage?
    @State private var exportando = false
    
    private let fondo = Color(red: 0.06, green: 0.06, blue: 0.10)
    
    var body: some View {
        ZStack {
            fondo.ignoresSafeArea()
            
            if viewModel.isReady {
                VStack(spacing: 0) {
                    
                    // MARK: - Header mínimo
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(.white.opacity(0.08)))
                        }
                        
                        Spacer()
                        
                        // Indicadores
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { index in
                                Capsule()
                                    .fill(paginaActual == index ? .white : .white.opacity(0.15))
                                    .frame(width: paginaActual == index ? 20 : 6, height: 6)
                                    .animation(.spring(response: 0.3), value: paginaActual)
                            }
                        }
                        
                        Spacer()
                        
                        // Compartir
                        Button(action: { exportarSlideActual() }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(.white.opacity(0.08)))
                        }
                        .disabled(exportando)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    
                    // MARK: - Slides
                    TabView(selection: $paginaActual) {
                        RecapSlide1View(viewModel: viewModel)
                            .tag(0)
                        
                        RecapSlide2View(viewModel: viewModel)
                            .tag(1)
                        
                        RecapSlide3View(viewModel: viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: paginaActual)
                    
                    // MARK: - Footer: Guardar
                    Button(action: { exportarTodasLasSlides() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            
                            Text("Guardar Recap")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().fill(.white)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .padding(.top, 4)
                    .disabled(exportando)
                    
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Preparando...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
        .onAppear {
            viewModel.cargarDatos(context: context)
        }
        .sheet(isPresented: $mostrarShareSheet) {
            if let imagen = imagenExportar {
                ShareSheetView(items: [imagen])
            }
        }
    }
    
    // MARK: - Exportar slide actual como imagen
    @MainActor
    private func exportarSlideActual() {
        exportando = true
        let slideView = slideParaPagina(paginaActual)
        let renderer = ImageRenderer(content: slideView.frame(width: 390, height: 844))
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            imagenExportar = uiImage
            mostrarShareSheet = true
        }
        exportando = false
    }
    
    // MARK: - Exportar todas las slides
    @MainActor
    private func exportarTodasLasSlides() {
        exportando = true
        var imagenes: [UIImage] = []
        for i in 0..<3 {
            let slideView = slideParaPagina(i)
            let renderer = ImageRenderer(content: slideView.frame(width: 390, height: 844))
            renderer.scale = UIScreen.main.scale
            if let uiImage = renderer.uiImage {
                imagenes.append(uiImage)
            }
        }
        if !imagenes.isEmpty {
            imagenExportar = imagenes.first
            for imagen in imagenes {
                UIImageWriteToSavedPhotosAlbum(imagen, nil, nil, nil)
            }
            mostrarShareSheet = true
        }
        exportando = false
    }
    
    @ViewBuilder
    private func slideParaPagina(_ pagina: Int) -> some View {
        switch pagina {
        case 0: RecapSlide1View(viewModel: viewModel)
        case 1: RecapSlide2View(viewModel: viewModel)
        case 2: RecapSlide3View(viewModel: viewModel)
        default: RecapSlide1View(viewModel: viewModel)
        }
    }
}

// MARK: - ShareSheet UIKit Wrapper
struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    RecapContenedorView()
        .modelContainer(for: [RegistroMensual.self])
}
