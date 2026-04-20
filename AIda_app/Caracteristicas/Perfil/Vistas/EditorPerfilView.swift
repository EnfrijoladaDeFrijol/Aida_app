import SwiftUI

// MARK: - EditorPerfilView
// Modal para editar los datos del usuario.
// Usa campos temporales del ViewModel que no se persisten hasta confirmar.

struct EditorPerfilView: View {
    @Bindable var vm: PerfilViewModel
    @FocusState private var campoEnfocado: CampoEdicion?
    
    enum CampoEdicion {
        case nombre, edad, peso, altura
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.rosaBruma.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Avatar preview dinámico
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: vm.perfil.gradienteAnimo,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(
                                        vm.nombreEditando.isEmpty
                                        ? vm.perfil.iniciales
                                        : String(vm.nombreEditando.prefix(2)).uppercased()
                                    )
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                )
                        }
                        .padding(.top, 8)
                        
                        // Campos de edición
                        VStack(spacing: 16) {
                            CampoEdicionPerfil(
                                titulo: "Nombre",
                                icono: "person.fill",
                                texto: $vm.nombreEditando,
                                placeholder: "Tu nombre",
                                teclado: .default
                            )
                            .focused($campoEnfocado, equals: .nombre)
                            
                            CampoEdicionPerfil(
                                titulo: "Edad",
                                icono: "calendar",
                                texto: $vm.edadEditando,
                                placeholder: "Años",
                                teclado: .numberPad
                            )
                            .focused($campoEnfocado, equals: .edad)
                            
                            CampoEdicionPerfil(
                                titulo: "Peso (kg)",
                                icono: "scalemass.fill",
                                texto: $vm.pesoEditando,
                                placeholder: "70.0",
                                teclado: .decimalPad
                            )
                            .focused($campoEnfocado, equals: .peso)
                            
                            CampoEdicionPerfil(
                                titulo: "Altura (cm)",
                                icono: "ruler.fill",
                                texto: $vm.alturaEditando,
                                placeholder: "170",
                                teclado: .numberPad
                            )
                            .focused($campoEnfocado, equals: .altura)
                        }
                        .padding(.horizontal, 24)
                        
                        // IMC preview en tiempo real
                        if let peso = Double(vm.pesoEditando),
                           let altura = Int(vm.alturaEditando),
                           peso > 0, altura > 0 {
                            let alturaM = Double(altura) / 100.0
                            let imcPreview = peso / (alturaM * alturaM)
                            
                            HStack(spacing: 10) {
                                Image(systemName: "heart.text.square.fill")
                                    .foregroundColor(.coralEnergetico)
                                Text("IMC estimado:")
                                    .font(.aidaEtiqueta)
                                    .foregroundColor(.gray)
                                Text(String(format: "%.1f", imcPreview))
                                    .font(.aidaCuerpoDestacado)
                                    .foregroundColor(.grisPizarra)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.8))
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        vm.cancelarEdicion()
                    }
                    .foregroundColor(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        vm.guardarEdicion()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.coralEnergetico)
                }
            }
            .onTapGesture {
                campoEnfocado = nil
            }
        }
    }
}

// MARK: - Campo de Edición Reutilizable
struct CampoEdicionPerfil: View {
    let titulo: String
    let icono: String
    @Binding var texto: String
    let placeholder: String
    var teclado: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(.aidaEtiqueta)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Image(systemName: icono)
                    .font(.system(size: 16))
                    .foregroundColor(.coralEnergetico)
                    .frame(width: 24)
                
                TextField(placeholder, text: $texto)
                    .font(.aidaCuerpo)
                    .foregroundColor(.grisPizarra)
                    .keyboardType(teclado)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    EditorPerfilView(vm: PerfilViewModel())
}
