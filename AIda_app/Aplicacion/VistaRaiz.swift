import SwiftUI

struct VistaRaiz: View {
    var body: some View {
        VStack(spacing: 0) {
            // Barra superior global
            BarraSuperiorAIda()
            
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
                
                // 3. La Rutina: Generada con IA
                RutinaContenedorView()
                    .tabItem {
                        Label("Rutina", systemImage: "figure.run")
                    }
                
                // 4. Progreso (datos/metricas)
                EstadisticasView()
                    .tabItem {
                        Label("Progreso", systemImage: "chart.bar.fill")
                    }
                // 5. Perfil del Usuario
                PerfilView()
                    .tabItem {
                        Label("Perfil", systemImage: "person.crop.circle.fill")
                    }
            }
            // Usamos el color de acento de tu Sistema de Diseño
            .tint(.aidaAcento)
        }
    }
}

// Visualiza toda tu app desde aquí
#Preview {
    VistaRaiz()
}
