import Foundation
import SwiftUI
import UIKit

// MARK: - GestorFotos
// Administra el guardado y recuperación de las fotos de progreso del usuario
// Las imágenes se guardan en el directorio "Documents" del dispositivo
// y los metadatos (fechas, notas) se guardan en UserDefaults.

class GestorFotos: ObservableObject {
    static let compartido = GestorFotos()
    
    @Published var fotosGuardadas: [FotoProgreso] = []
    
    private let claveAlmacenamiento = "fotosProgresoAIda"
    
    private init() {
        cargarMetadatos()
    }
    
    // MARK: - Operaciones
    
    func cargarMetadatos() {
        guard let datos = UserDefaults.standard.data(forKey: claveAlmacenamiento) else { return }
        do {
            let decodificador = JSONDecoder()
            fotosGuardadas = try decodificador.decode([FotoProgreso].self, from: datos)
            // Ordenar por fecha (más recientes primero)
            fotosGuardadas.sort { $0.fecha > $1.fecha }
        } catch {
            print("Error al cargar metadatos de fotos: \(error)")
        }
    }
    
    func guardarFoto(imagen: UIImage, categoria: CategoriaProgreso, nota: String? = nil) {
        let nombreArchivo = UUID().uuidString + ".jpg"
        
        // 1. Guardar la imagen en el directorio de Documentos
        guard let dataImagen = imagen.jpegData(compressionQuality: 0.8),
              let urlDirectorio = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let urlArchivo = urlDirectorio.appendingPathComponent(nombreArchivo)
        
        do {
            try dataImagen.write(to: urlArchivo)
            
            // 2. Guardar los metadatos
            let nuevaFoto = FotoProgreso(fecha: Date(), categoria: categoria, nombreArchivo: nombreArchivo, nota: nota)
            
            DispatchQueue.main.async {
                self.fotosGuardadas.insert(nuevaFoto, at: 0)
                self.guardarEnDisco()
            }
        } catch {
            print("Error al guardar imagen física: \(error)")
        }
    }
    
    func eliminarFoto(conId id: String) {
        guard let index = fotosGuardadas.firstIndex(where: { $0.id == id }) else { return }
        let foto = fotosGuardadas[index]
        
        // 1. Eliminar archivo físico
        if let urlDirectorio = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let urlArchivo = urlDirectorio.appendingPathComponent(foto.nombreArchivo)
            do {
                if FileManager.default.fileExists(atPath: urlArchivo.path) {
                    try FileManager.default.removeItem(at: urlArchivo)
                }
            } catch {
                print("Error eliminando archivo de imagen: \(error)")
            }
        }
        
        // 2. Eliminar metadatos
        fotosGuardadas.remove(at: index)
        guardarEnDisco()
    }
    
    func cargarImagenFisica(nombreArchivo: String) -> UIImage? {
        guard let urlDirectorio = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let urlArchivo = urlDirectorio.appendingPathComponent(nombreArchivo)
        return UIImage(contentsOfFile: urlArchivo.path)
    }
    
    private func guardarEnDisco() {
        do {
            let codificador = JSONEncoder()
            let datos = try codificador.encode(fotosGuardadas)
            UserDefaults.standard.set(datos, forKey: claveAlmacenamiento)
        } catch {
            print("Error al guardar metadatos de fotos: \(error)")
        }
    }
}
