import SwiftUI
import UIKit
import ImageIO

// MARK: - GIFImageView
// Componente que reproduce un GIF animado desde el bundle de la app.
// Usa UIViewRepresentable para envolver un UIImageView con animación nativa.

struct GIFImageView: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let data = NSData(contentsOfFile: path) {
            let frames = GIFImageView.animatedFrames(from: data as Data)
            imageView.animationImages = frames.images
            imageView.animationDuration = frames.duration
            imageView.animationRepeatCount = 0 // Loop infinito
            imageView.image = frames.images.first
            imageView.startAnimating()
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {}
    
    // MARK: - Decodificador de GIF
    static func animatedFrames(from data: Data) -> (images: [UIImage], duration: Double) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return ([], 0)
        }
        
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration: Double = 0
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                
                // Obtener duración del frame
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                   let gifDict = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                    let delay = gifDict[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double
                        ?? gifDict[kCGImagePropertyGIFDelayTime as String] as? Double
                        ?? 0.1
                    totalDuration += delay
                }
            }
        }
        
        return (images, totalDuration)
    }
}
