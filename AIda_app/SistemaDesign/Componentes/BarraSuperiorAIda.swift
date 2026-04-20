import SwiftUI

// MARK: - BarraSuperiorAIda
// Barra de navegación personalizada que se muestra en toda la app.
// Incluye el logo de AIda, el nombre de la app y un ícono de búsqueda.

struct BarraSuperiorAIda: View {
    var body: some View {
        HStack(spacing: 10) {
            // Logo de AIda
            Image("LogoAIDA_negro")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.grisPizarra)
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
            
            // Nombre de la app
            Text("Aida")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.grisPizarra)
            
            Spacer()
            
            // Lupa
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.grisPizarra)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}
