import SwiftUI

struct MiDietaView: View {
    @ObservedObject private var gestorRutinas = GestorRutinas.compartido
    @State private var rutinaSeleccionadaId: String? = nil
    
    var body: some View {
        let rutinasConDieta = gestorRutinas.rutinasGuardadas.filter { $0.dieta != nil }
        
        ZStack {
            Color.aidaFondo.edgesIgnoringSafeArea(.all)
            
            if rutinasConDieta.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No hay dieta disponible")
                        .font(.aidaTitulo)
                        .foregroundColor(.grisPizarra)
                    Text("Genera y guarda una rutina primero para ver tu dieta sugerida y lista de compras.")
                        .font(.aidaCuerpo)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Selector de Rutina
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selecciona una rutina")
                                .font(.aidaCuerpoDestacado)
                                .foregroundColor(.grisPizarra)
                                .padding(.horizontal, 4)
                            
                            Picker("Rutina", selection: Binding(
                                get: { rutinaSeleccionadaId ?? rutinasConDieta.first?.id },
                                set: { rutinaSeleccionadaId = $0 }
                            )) {
                                ForEach(rutinasConDieta) { rutina in
                                    Text(rutina.nombre).tag(Optional(rutina.id))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        
                        // Mostrar dieta de la rutina seleccionada
                        if let rutinaId = rutinaSeleccionadaId ?? rutinasConDieta.first?.id,
                           let ultimaRutina = rutinasConDieta.first(where: { $0.id == rutinaId }),
                           let dieta = ultimaRutina.dieta {
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Dieta para: \(ultimaRutina.nombre)")
                                    .font(.aidaSubtitulo)
                                    .foregroundColor(.grisPizarra)
                                
                                Text(dieta.descripcion)
                                    .font(.aidaCuerpo)
                                    .foregroundColor(.gray)
                                
                                VStack(spacing: 12) {
                                    ForEach(dieta.comidas) { comida in
                                        filaComida(comida)
                                    }
                                }
                                
                                if let compras = dieta.listaCompras, !compras.isEmpty {
                                    Divider().padding(.vertical, 8)
                                    
                                    HStack {
                                        Image(systemName: "cart.fill")
                                            .foregroundColor(.greenMint)
                                        Text("Lista de Compras")
                                            .font(.aidaCuerpoDestacado)
                                            .foregroundColor(.grisPizarra)
                                        
                                        Spacer()
                                        
                                        ShareLink(
                                            item: "Lista de Compras - AIda:\n\n" + compras.map { "• \($0)" }.joined(separator: "\n"),
                                            subject: Text("Lista de Compras")
                                        ) {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.coralEnergetico)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(compras, id: \.self) { item in
                                            HStack(spacing: 8) {
                                                Image(systemName: "circle")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray.opacity(0.5))
                                                Text(item)
                                                    .font(.aidaCuerpo)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color.white)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                            
                        } else {
                            Text("Tu rutina guardada no contiene una dieta. Genera una nueva para obtener tu plan de alimentación.")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Mi Dieta")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func filaComida(_ comida: Comida) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(Color.coralEnergetico.opacity(0.6))
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(comida.tipo)
                    .font(.aidaCuerpoDestacado)
                    .foregroundColor(.grisPizarra)
                Text(comida.sugerencia)
                    .font(.aidaEtiqueta)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
