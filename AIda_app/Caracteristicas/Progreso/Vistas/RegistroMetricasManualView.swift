import SwiftUI
import SwiftData

struct RegistroMetricasManualView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var registros: [RegistroMensual]
    
    @State private var metrosNatacion: String = ""
    @State private var nombrePR: String = ""
    @State private var pesoPR: String = ""
    @State private var tonelajeGimnasio: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("🏊‍♂️ Natación")) {
                    TextField("Metros nadados hoy", text: $metrosNatacion)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("🏋️‍♂️ Gimnasio")) {
                    TextField("Tonelaje total de hoy (kg)", text: $tonelajeGimnasio)
                        .keyboardType(.numberPad)
                    
                    TextField("Ejercicio de PR (Ej: Sentadilla)", text: $nombrePR)
                    TextField("Peso de PR (kg)", text: $pesoPR)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Registrar Actividad")
            .navigationBarItems(
                leading: Button("Cancelar") { dismiss() },
                trailing: Button("Guardar") { guardarDatos() }
            )
        }
    }
    
    private func guardarDatos() {
        // Obtenemos el inicio del mes actual
        let mesActual = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        
        // Buscamos si ya existe el registro de este mes, si no, lo creamos
        let registro = registros.first(where: { $0.mes == mesActual }) ?? {
            let nuevo = RegistroMensual(mes: mesActual)
            context.insert(nuevo)
            return nuevo
        }()
        
        // Sumamos lo nuevo a lo existente
        if let metros = Double(metrosNatacion) {
            registro.metrosTotales += metros
            registro.sesionesNado += 1
        }
        
        if let tonelaje = Double(tonelajeGimnasio) {
            registro.tonelajeTotal += tonelaje
        }
        
        if !nombrePR.isEmpty && !pesoPR.isEmpty {
            registro.ejercicioPR = "\(nombrePR): \(pesoPR)kg"
        }
        
        // Guardamos los cambios
        try? context.save()
        dismiss()
    }
}

#Preview {
    RegistroMetricasManualView()
}
