import Foundation

// MARK: - GestorRacha
// Controla la racha de días consecutivos haciendo ejercicio.
//
// ¿Cómo funciona?
// - Cada vez que el usuario completa una rutina, llamamos registrarEjercicioHoy()
// - Si ayer también hizo ejercicio → la racha sube
// - Si ayer NO hizo ejercicio → la racha se reinicia a 1
// - Si hoy YA registró ejercicio → no cuenta doble
//
// Los datos se guardan en UserDefaults con las mismas claves que PerfilUsuario
// para que el Perfil los muestre automáticamente.

class GestorRacha {
    
    // Singleton: una sola instancia para toda la app
    static let compartido = GestorRacha()
    
    private let calendario = Calendar.current
    
    // MARK: - Claves de UserDefaults
    private let claveRacha = "perfil_racha"
    private let claveRutinasCompletadas = "perfil_rutinas_completadas"
    private let claveUltimoEjercicio = "perfil_ultimo_ejercicio"
    
    // MARK: - Propiedades
    
    var rachaActual: Int {
        get { UserDefaults.standard.integer(forKey: claveRacha) }
        set { UserDefaults.standard.set(newValue, forKey: claveRacha) }
    }
    
    var rutinasCompletadas: Int {
        get { UserDefaults.standard.integer(forKey: claveRutinasCompletadas) }
        set { UserDefaults.standard.set(newValue, forKey: claveRutinasCompletadas) }
    }
    
    var fechaUltimoEjercicio: Date? {
        get { UserDefaults.standard.object(forKey: claveUltimoEjercicio) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: claveUltimoEjercicio) }
    }
    
    var yaHizoEjercicioHoy: Bool {
        guard let ultima = fechaUltimoEjercicio else { return false }
        return calendario.isDateInToday(ultima)
    }
    
    // MARK: - Acción Principal
    
    /// Registra que el usuario completó ejercicio hoy.
    /// Actualiza la racha y el contador de rutinas.
    func registrarEjercicioHoy() {
        let hoy = Date()
        
        // Si ya hizo ejercicio hoy, solo sumamos la rutina (no la racha)
        if yaHizoEjercicioHoy {
            rutinasCompletadas += 1
            return
        }
        
        // ¿Hizo ejercicio ayer?
        if let ultima = fechaUltimoEjercicio,
           calendario.isDateInYesterday(ultima) {
            // ¡Sí! La racha continúa
            rachaActual += 1
        } else if let ultima = fechaUltimoEjercicio,
                  calendario.isDateInToday(ultima) {
            // Ya se contó hoy (no debería llegar aquí, pero por seguridad)
        } else {
            // No hizo ayer (o es primera vez) → racha nueva
            rachaActual = 1
        }
        
        rutinasCompletadas += 1
        fechaUltimoEjercicio = hoy
    }
    
    /// Verifica si la racha se rompió (no hizo ejercicio ayer ni hoy)
    func verificarRacha() {
        guard let ultima = fechaUltimoEjercicio else { return }
        
        // Si no hizo ejercicio ni ayer ni hoy, la racha se perdió
        if !calendario.isDateInToday(ultima) && !calendario.isDateInYesterday(ultima) {
            rachaActual = 0
        }
    }
}
