import SwiftUI
import SwiftData

struct RegistroMetricasManualView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: ProgresoViewModel
    
    @State private var metrosNatacion: String = ""
    @State private var nombrePR: String = ""
    @State private var pesoPR: String = ""
    @State private var tonelajeGimnasio: String = ""
    @State private var kmRunningManual: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("🏊‍♂️ Natación (Manual)"), footer: Text("Si no tienes Apple Watch, registra tus metros aquí. Se sumarán a tu total.")) {
                    TextField("Metros nadados", text: $metrosNatacion)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("🏃‍♂️ Running (Manual)"), footer: Text("Kilómetros extra fuera de tu teléfono/reloj.")) {
                    TextField("Kilómetros recorridos", text: $kmRunningManual)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("🏋️‍♂️ Gimnasio")) {
                    TextField("Tonelaje total levantado (kg)", text: $tonelajeGimnasio)
                        .keyboardType(.decimalPad)
                    
                    TextField("Ejercicio de PR (Ej: Sentadilla)", text: $nombrePR)
                    TextField("Peso de PR (kg)", text: $pesoPR)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Añadir Progreso")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") { dismiss() },
                trailing: Button("Guardar") { guardarDatos() }
                    .fontWeight(.bold)
            )
        }
    }
    
    private func guardarDatos() {
        guard let actual = viewModel.mesActual else { return }
        
        // Sumamos lo nuevo a lo existente
        if let metros = Double(metrosNatacion.replacingOccurrences(of: ",", with: ".")) {
            actual.metrosTotales += metros
            actual.sesionesNado += 1
        }
        
        if let kms = Double(kmRunningManual.replacingOccurrences(of: ",", with: ".")) {
            actual.kmTotales += kms
        }
        
        if let tonelaje = Double(tonelajeGimnasio.replacingOccurrences(of: ",", with: ".")) {
            actual.tonelajeTotal += tonelaje
        }
        
        if !nombrePR.isEmpty && !pesoPR.isEmpty {
            actual.ejercicioPR = "\(nombrePR): \(pesoPR)kg"
        }
        
        // Guardamos los cambios en la base de datos
        try? context.save()
        
        // Forzar actualización en el viewModel
        viewModel.objectWillChange.send()
        
        dismiss()
    }
}
