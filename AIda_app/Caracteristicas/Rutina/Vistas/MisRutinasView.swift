import SwiftUI

struct MisRutinasView: View {
    @StateObject private var gestorRutinas = GestorRutinas.compartido
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.aidaFondo.edgesIgnoringSafeArea(.all)
                
                if gestorRutinas.rutinasGuardadas.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No tienes rutinas guardadas")
                            .font(.aidaSubtitulo)
                            .foregroundColor(.grisPizarra)
                        
                        Text("Cuando generes una rutina que te guste, guárdala para verla aquí.")
                            .font(.aidaCuerpo)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(gestorRutinas.rutinasGuardadas) { rutina in
                            NavigationLink(destination: DetalleRutinaGuardadaView(rutina: rutina)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(rutina.nombre)
                                        .font(.aidaCuerpoDestacado)
                                        .foregroundColor(.grisPizarra)
                                    
                                    HStack {
                                        Text(rutina.duracionEstimada)
                                        Spacer()
                                        if let fecha = rutina.fechaGuardado {
                                            Text(fecha, style: .date)
                                        }
                                    }
                                    .font(.aidaEtiqueta)
                                    .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .onDelete(perform: eliminarRutinas)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Mis Rutinas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.coralEnergetico)
                }
            }
        }
    }
    
    private func eliminarRutinas(at offsets: IndexSet) {
        for index in offsets {
            let rutina = gestorRutinas.rutinasGuardadas[index]
            gestorRutinas.eliminarRutina(conId: rutina.id)
        }
    }
}

// MARK: - Vista de Detalle y Edición
struct DetalleRutinaGuardadaView: View {
    @State var rutina: RutinaGenerada
    @Environment(\.dismiss) var dismiss
    @State private var editandoNombre = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Nombre Editable
                if editandoNombre {
                    TextField("Nombre de la rutina", text: $rutina.nombre)
                        .font(.aidaTitulo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onSubmit {
                            GestorRutinas.compartido.actualizarRutina(rutina)
                            editandoNombre = false
                        }
                } else {
                    Text(rutina.nombre)
                        .font(.aidaTitulo)
                        .foregroundColor(.grisPizarra)
                        .multilineTextAlignment(.center)
                        .padding()
                        .onTapGesture {
                            editandoNombre = true
                        }
                }
                
                Text("Toca el nombre para editarlo")
                    .font(.aidaEtiqueta)
                    .foregroundColor(.gray)
                
                // Secciones
                ForEach(rutina.secciones) { seccion in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(seccion.titulo)
                            .font(.aidaSubtitulo)
                            .foregroundColor(.coralEnergetico)
                        
                        ForEach(seccion.ejercicios) { ejercicio in
                            HStack {
                                Text(ejercicio.nombre)
                                    .font(.aidaCuerpoDestacado)
                                Spacer()
                                Text(ejercicio.detalle)
                                    .font(.aidaCuerpo)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                

            }
            .padding(.bottom, 30)
        }
        .background(Color.aidaFondo.edgesIgnoringSafeArea(.all))
        .navigationTitle("Detalle de Rutina")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    GestorRutinas.compartido.actualizarRutina(rutina)
                    dismiss()
                }
                .foregroundColor(.coralEnergetico)
            }
        }
    }
}
