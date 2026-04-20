import SwiftUI
import PhotosUI

struct ProgresoView: View {
    @StateObject private var gestorFotos = GestorFotos.compartido
    @State private var seleccionDeFoto: PhotosPickerItem? = nil
    @State private var categoriaSeleccionada: CategoriaProgreso = .semanal
    @State private var fotoSeleccionadaParaVer: FotoProgreso? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.aidaFondo.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Selector de categoría
                    Picker("Categoría", selection: $categoriaSeleccionada) {
                        ForEach(CategoriaProgreso.allCases, id: \.self) { categoria in
                            Text(categoria.rawValue).tag(categoria)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    ScrollView {
                        if fotosDeCategoria.isEmpty {
                            VStack(spacing: 20) {
                                Spacer().frame(height: 100)
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No hay fotos de progreso \(categoriaSeleccionada.rawValue.lowercased())")
                                    .font(.aidaSubtitulo)
                                    .foregroundColor(.grisPizarra)
                                Text("Añade tu primera foto para empezar a ver tus resultados.")
                                    .font(.aidaCuerpo)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(fotosDeCategoria) { foto in
                                    TarjetaFotoProgreso(foto: foto)
                                        .onTapGesture {
                                            fotoSeleccionadaParaVer = foto
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Progreso Visual")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $seleccionDeFoto, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "camera.badge.ellipsis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.coralEnergetico)
                    }
                }
            }
            .onChange(of: seleccionDeFoto) { _, nuevaSeleccion in
                guard let seleccion = nuevaSeleccion else { return }
                manejarSeleccionDeFoto(seleccion)
            }
            .sheet(item: $fotoSeleccionadaParaVer) { foto in
                VistaDetalleFoto(foto: foto)
            }
        }
    }
    
    private var fotosDeCategoria: [FotoProgreso] {
        gestorFotos.fotosGuardadas.filter { $0.categoria == categoriaSeleccionada }
    }
    
    private func manejarSeleccionDeFoto(_ seleccion: PhotosPickerItem) {
        Task {
            if let data = try? await seleccion.loadTransferable(type: Data.self),
               let imagen = UIImage(data: data) {
                // Guardar foto con la categoría actual
                gestorFotos.guardarFoto(imagen: imagen, categoria: categoriaSeleccionada)
            }
            // Limpiar selección
            seleccionDeFoto = nil
        }
    }
}

// MARK: - Tarjeta de Foto
struct TarjetaFotoProgreso: View {
    let foto: FotoProgreso
    @State private var imagenCargada: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(3/4, contentMode: .fit)
                
                if let uiImage = imagenCargada {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(3/4, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    ProgressView()
                }
            }
            
            Text(foto.fecha, style: .date)
                .font(.aidaEtiqueta)
                .foregroundColor(.grisPizarra)
        }
        .onAppear {
            if let uiImage = GestorFotos.compartido.cargarImagenFisica(nombreArchivo: foto.nombreArchivo) {
                self.imagenCargada = uiImage
            }
        }
    }
}

// MARK: - Vista Detalle de Foto
struct VistaDetalleFoto: View {
    let foto: FotoProgreso
    @Environment(\.dismiss) var dismiss
    @State private var imagenCargada: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                if let uiImage = imagenCargada {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                        .padding()
                    
                    // Botón para compartir la foto
                    ShareLink(
                        item: Image(uiImage: uiImage),
                        preview: SharePreview("Mi progreso", image: Image(uiImage: uiImage))
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartir progreso")
                        }
                        .font(.aidaBoton)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.coralEnergetico)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            .navigationTitle(foto.categoria.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.coralEnergetico)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive, action: {
                        GestorFotos.compartido.eliminarFoto(conId: foto.id)
                        dismiss()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                self.imagenCargada = GestorFotos.compartido.cargarImagenFisica(nombreArchivo: foto.nombreArchivo)
            }
        }
    }
}
