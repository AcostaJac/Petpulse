import SwiftUI
import Charts

struct HealthTrackingView: View {
    @EnvironmentObject var petStore: PetStore
    @State private var showAddRecord = false
    @State private var preselectedType: HealthRecord.RecordType = .food

    var pet: Pet? { petStore.selectedPet }

    var body: some View {
        NavigationStack {
            if let p = pet {
                ScrollView {
                    VStack(spacing: 14) {
                        quickLogButtons(p)
                        weightChart(p)
                        foodChart(p)
                        recentLog(p)
                    }
                    .padding(14).padding(.bottom, 20)
                }
                .background(Color.bgPage)
                .navigationTitle("Salud de \(p.name)")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            preselectedType = .general
                            showAddRecord = true
                        } label: {
                            Image(systemName: "plus.circle.fill").font(.system(size: 18)).foregroundColor(.primary)
                        }
                    }
                }
                .sheet(isPresented: $showAddRecord) {
                    AddHealthRecordView(pet: p, initialType: preselectedType).environmentObject(petStore)
                }
            } else {
                ContentUnavailableView("Sin mascota seleccionada", systemImage: "pawprint.circle",
                    description: Text("Selecciona una mascota para ver su salud."))
            }
        }
    }

    // MARK: - Quick log buttons — cada uno abre su propio formulario
    private func quickLogButtons(_ p: Pet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Registrar").font(.system(size: 13, weight: .medium)).foregroundColor(.textMuted)
            HStack(spacing: 8) {
                ForEach([HealthRecord.RecordType.food, .medicine, .illness, .weight], id: \.self) { type in
                    Button {
                        preselectedType = type
                        showAddRecord = true
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10).fill(type.bgColor).frame(width: 44, height: 44)
                                Text(type.emoji).font(.system(size: 22))
                            }
                            Text(type.rawValue).font(.system(size: 9, weight: .medium)).foregroundColor(type.color)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white).cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 0.5))
                    }
                }
            }
        }
    }

    // MARK: - Weight chart
    private func weightChart(_ p: Pet) -> some View {
        let records = p.healthRecords.filter { $0.type == .weight && $0.weight != nil }
            .sorted { $0.date < $1.date }.suffix(10)

        return CardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Peso (kg)").font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text("Últimos registros").font(.system(size: 10)).foregroundColor(.textMuted)
                }
                if records.isEmpty {
                    emptyChartPlaceholder("⚖️", "Sin registros de peso\nToca ⚖️ para agregar")
                } else {
                    Chart(Array(records), id: \.id) { r in
                        LineMark(x: .value("Fecha", r.date), y: .value("Kg", r.weight ?? 0))
                            .foregroundStyle(Color.primary).lineStyle(StrokeStyle(lineWidth: 2))
                        PointMark(x: .value("Fecha", r.date), y: .value("Kg", r.weight ?? 0))
                            .foregroundStyle(Color.primary)
                        AreaMark(x: .value("Fecha", r.date), y: .value("Kg", r.weight ?? 0))
                            .foregroundStyle(Color.primaryLight.opacity(0.5))
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated)).font(.system(size: 8))
                        }
                    }
                    .frame(height: 110)
                    HStack {
                        if let min = records.compactMap({ $0.weight }).min() {
                            Text("Mín: \(String(format:"%.1f",min)) kg").font(.system(size:10)).foregroundColor(.textMuted)
                        }
                        Spacer()
                        Text("Actual: \(String(format:"%.1f", p.weight)) kg").font(.system(size:10,weight:.medium)).foregroundColor(.primary)
                    }
                }
            }
        }
    }

    // MARK: - Food chart
    private func foodChart(_ p: Pet) -> some View {
        let cal = Calendar.current
        let days = (0..<7).map { i -> (String, Int) in
            let date = cal.date(byAdding: .day, value: -(6-i), to: Date())!
            let day = ["D","L","M","M","J","V","S"][cal.component(.weekday, from: date)-1]
            let score = p.healthRecords.filter { $0.type == .food && cal.isDate($0.date, inSameDayAs: date) }
                .compactMap { $0.foodScore }.max() ?? 0
            return (day, score)
        }
        return CardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Alimentación esta semana").font(.system(size: 13, weight: .medium))
                    Spacer()
                    HStack(spacing: 8) {
                        legendDot(.primary, "Bien"); legendDot(.gold, "Regular"); legendDot(.coral, "Poco")
                    }
                }
                Chart(days, id: \.0) { day, score in
                    BarMark(x: .value("Día", day), y: .value("Score", max(score, score==0 ? 0 : 1)))
                        .foregroundStyle(score >= 4 ? Color.primary : score >= 2 ? Color.gold : score == 0 ? Color(white:0.9) : Color.coral)
                        .cornerRadius(4)
                }
                .chartYScale(domain: 0...5).chartYAxis(.hidden).frame(height: 80)
                .chartXAxis { AxisMarks { v in AxisValueLabel().font(.system(size: 10)) } }
            }
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).font(.system(size: 9)).foregroundColor(.textMuted)
        }
    }

    // MARK: - Recent log
    private func recentLog(_ p: Pet) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Historial").font(.system(size: 13, weight: .medium))
                    Spacer()
                    if p.healthRecords.count > 5 {
                        Text("\(p.healthRecords.count) registros").font(.system(size: 11)).foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 8)
                if p.healthRecords.isEmpty {
                    emptyChartPlaceholder("📋", "Sin registros aún")
                } else {
                    ForEach(p.healthRecords.prefix(8)) { r in
                        HStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 7).fill(r.type.bgColor).frame(width: 28, height: 28)
                                Text(r.type.emoji).font(.system(size: 13))
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(r.note.isEmpty ? r.type.rawValue : r.note).font(.system(size: 11)).lineLimit(1)
                                if let w = r.weight { Text("\(String(format:"%.1f",w)) kg").font(.system(size:9)).foregroundColor(.textMuted) }
                                if let f = r.foodScore { Text(["","😞 Muy poco","😕 Poco","😐 Regular","😊 Bien","🤩 Muy bien"][min(f,5)]).font(.system(size:9)).foregroundColor(.textMuted) }
                            }
                            Spacer()
                            Text(r.date, style: .date).font(.system(size: 9)).foregroundColor(.textHint)
                        }
                        .padding(.vertical, 5)
                        Divider()
                    }
                }
            }
        }
    }

    private func emptyChartPlaceholder(_ emoji: String, _ text: String) -> some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 24))
            Text(text).font(.system(size: 11)).foregroundColor(.textMuted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20)
    }
}

// MARK: - AddHealthRecordView
struct AddHealthRecordView: View {
    let pet: Pet
    var initialType: HealthRecord.RecordType = .food
    @EnvironmentObject var petStore: PetStore
    @Environment(\.dismiss) private var dismiss

    @State private var type: HealthRecord.RecordType = .food
    @State private var note = ""
    @State private var weightVal: Double = 0
    @State private var foodScore = 3
    @State private var date = Date()
    @State private var illnessType = "Gripe / resfriado"

    let commonIllnesses = ["Gripe / resfriado","Gastritis","Diarrea leve","Conjuntivitis","Infección de oído","Alergia","Parásitos","Problema de piel","Fatiga / letargia","Otro"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo de registro") {
                    Picker("Tipo", selection: $type) {
                        ForEach(HealthRecord.RecordType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: icon(t)).tag(t)
                        }
                    }.pickerStyle(.menu)
                }

                Section("Detalles") {
                    DatePicker("Fecha", selection: $date, displayedComponents: [.date, .hourAndMinute])

                    if type == .weight {
                        HStack {
                            Text("Peso (kg)")
                            Spacer()
                            TextField("0.0", value: $weightVal, format: .number)
                                .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80)
                        }
                    }

                    if type == .food {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("¿Cómo comió hoy? \(["","😞","😕","😐","😊","🤩"][foodScore])")
                            Slider(value: Binding(get: { Double(foodScore) }, set: { foodScore = Int($0) }), in: 1...5, step: 1)
                                .tint(Color.primary)
                            HStack {
                                Text("Muy poco").font(.system(size:10)).foregroundColor(.textMuted)
                                Spacer()
                                Text("Excelente").font(.system(size:10)).foregroundColor(.textMuted)
                            }
                        }
                    }

                    if type == .illness {
                        Picker("Tipo de enfermedad", selection: $illnessType) {
                            ForEach(commonIllnesses, id: \.self) { Text($0) }
                        }.pickerStyle(.menu)
                    }

                    TextField(type == .illness ? "Síntomas observados…" : "Nota adicional (opcional)", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Nuevo registro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        let finalNote = type == .illness ? "\(illnessType)\(note.isEmpty ? "" : ": \(note)")" : note
                        let r = HealthRecord(type: type, note: finalNote, date: date,
                                            weight: type == .weight ? weightVal : nil,
                                            foodScore: type == .food ? foodScore : nil)
                        petStore.addHealthRecord(r, to: pet)
                        dismiss()
                    }.fontWeight(.semibold)
                }
            }
        }
        .onAppear { type = initialType; if type == .weight { weightVal = pet.weight } }
    }

    private func icon(_ t: HealthRecord.RecordType) -> String {
        switch t { case .food: "fork.knife"; case .medicine: "pills"; case .illness: "thermometer"; case .weight: "scalemass"; case .general: "note.text" }
    }
}
