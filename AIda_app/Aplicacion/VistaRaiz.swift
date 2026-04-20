import SwiftUI

struct VistaRaiz: View {
    var body: some View {
        TabView {
            // 1. Menú home
            InicioView()
                .tabItem{
                    Label("Inicio", systemImage: "house.fill")
                }
            
            // 2. Estado de Animo
            RegistroAnimoView()
                .tabItem {
                    Label("Ánimo", systemImage: "heart.text.square.fill")
                }
            
            // 2. La Rutina: Agua y Ejercicio
            Text("Aquí irá la vista de ResumenDiarioView")
                .tabItem {
                    Label("Rutina", systemImage: "figure.run")
                }
            
            // 3. Correlación de Datos
            Text("Aquí irá la vista de EstadisticasView")
                .tabItem {
                    Label("Progreso", systemImage: "chart.bar.fill")
                }
        }
        // Usamos el color de acento de tu Sistema de Diseño
        .tint(.aidaAcento)
    }
}

// Visualiza toda tu app desde aquí
#Preview {
    VistaRaiz()
}
