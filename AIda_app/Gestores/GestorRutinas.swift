import Foundation

// MARK: - GestorRutinas
// Maneja el guardado, edición y eliminación de las rutinas generadas localmente
// usando UserDefaults.

class GestorRutinas: ObservableObject {
    static let compartido = GestorRutinas()
    
    @Published var rutinasGuardadas: [RutinaGenerada] = []
    
    private let claveAlmacenamiento = "rutinasGuardadasAIda"
    
    private init() {
        cargarRutinas()
    }
    
    // MARK: - Operaciones CRUD
    
    func cargarRutinas() {
        guard let datos = UserDefaults.standard.data(forKey: claveAlmacenamiento) else { return }
        do {
            let decodificador = JSONDecoder()
            rutinasGuardadas = try decodificador.decode([RutinaGenerada].self, from: datos)
            // Ordenar por fecha de guardado (más recientes primero)
            rutinasGuardadas.sort { ($0.fechaGuardado ?? Date.distantPast) > ($1.fechaGuardado ?? Date.distantPast) }
        } catch {
            print("Error al cargar rutinas: \(error)")
        }
    }
    
    func guardarRutina(_ rutina: RutinaGenerada) {
        var nuevaRutina = rutina
        nuevaRutina.fechaGuardado = Date()
        
        // Evitar duplicados por nombre y fecha aproximada (opcional, o solo añadir)
        rutinasGuardadas.insert(nuevaRutina, at: 0)
        guardarEnDisco()
    }
    
    func actualizarRutina(_ rutina: RutinaGenerada) {
        if let index = rutinasGuardadas.firstIndex(where: { $0.id == rutina.id }) {
            rutinasGuardadas[index] = rutina
            guardarEnDisco()
        }
    }
    
    func eliminarRutina(conId id: String) {
        rutinasGuardadas.removeAll { $0.id == id }
        guardarEnDisco()
    }
    
    private func guardarEnDisco() {
        do {
            let codificador = JSONEncoder()
            let datos = try codificador.encode(rutinasGuardadas)
            UserDefaults.standard.set(datos, forKey: claveAlmacenamiento)
        } catch {
            print("Error al guardar rutinas en disco: \(error)")
        }
    }
}
