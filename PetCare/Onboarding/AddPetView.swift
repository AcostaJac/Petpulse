import SwiftUI
import PhotosUI

struct AddPetView: View {
    @EnvironmentObject var petStore: PetStore
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @Environment(\.dismiss) private var dismiss

    var isOnboarding: Bool = false
    var existingPet: Pet? = nil

    // Siempre empezar en selección de especie EXCEPTO cuando editas
    @State private var showSpeciesPicker: Bool = false
    @State private var name = ""
    @State private var species: Pet.PetSpecies = .dog
    @State private var breed = ""
    @State private var ageYears: Double = 1
    @State private var weight: Double = 5
    @State private var gender: Pet.Gender = .male
    @State private var petColor = ""
    @State private var microchip = ""
    @State private var sterilized = false
    @State private var allergies = ""
    @State private var bloodType = ""
    @State private var birthDate = Date()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showValidation = false

    var isEditing: Bool { existingPet != nil }

    var body: some View {
        NavigationStack {
            Group {
                if showSpeciesPicker {
                    speciesPickerView
                } else {
                    petFormView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if showSpeciesPicker {
                        Button("Cancelar") { dismiss() }
                    } else if !isOnboarding {
                        Button(isEditing ? "Cancelar" : "Atrás") {
                            if isEditing { dismiss() } else { showSpeciesPicker = true }
                        }
                    }
                }
            }
            .alert("Nombre requerido", isPresented: $showValidation) {
                Button("OK", role: .cancel) {}
            } message: { Text("Por favor ingresa el nombre de tu mascota.") }
        }
        .onAppear {
            if isEditing {
                populateIfEditing()
                showSpeciesPicker = false
            } else if isOnboarding {
                showSpeciesPicker = false // Primera mascota: ir directo al form
            } else {
                showSpeciesPicker = true  // Segunda+ mascota: pedir especie primero
            }
        }
    }

    // MARK: - Species Picker
    private var speciesPickerView: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    AppIconView(size: 64)
                    Text("¿Qué tipo de mascota\nquieres agregar?")
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("Personaliza los cuidados según su especie")
                        .font(.system(size: 13)).foregroundColor(.textMuted)
                }
                .padding(.top, 20)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(Pet.PetSpecies.allCases, id: \.self) { s in
                        Button {
                            species = s
                            showSpeciesPicker = false
                        } label: {
                            VStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(species == s ? Color.primaryLight : Color.white)
                                        .frame(height: 90)
                                        .overlay(RoundedRectangle(cornerRadius: 16)
                                            .stroke(species == s ? Color.primary : Color.cardBorder, lineWidth: species == s ? 2 : 0.5))
                                    VStack(spacing: 6) {
                                        Text(s.emoji).font(.system(size: 36))
                                        Text(s.rawValue).font(.system(size: 13, weight: .medium))
                                            .foregroundColor(species == s ? .primary : .textMuted)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                Spacer().frame(height: 20)
            }
        }
        .background(Color.bgPage)
        .navigationTitle("Nueva mascota")
    }

    // MARK: - Pet Form
    private var petFormView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Chip de especie seleccionada (solo si no es edición)
                if !isEditing && !isOnboarding {
                    HStack(spacing: 10) {
                        Text(species.emoji).font(.system(size: 26))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nuevo \(species.rawValue)").font(.system(size: 15, weight: .semibold))
                            Text("Completa su información").font(.system(size: 12)).foregroundColor(.textMuted)
                        }
                        Spacer()
                        Button {
                            showSpeciesPicker = true
                        } label: {
                            Text("Cambiar").font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.primaryLight).cornerRadius(8)
                        }
                    }
                    .padding(14).background(Color.primaryLight).cornerRadius(12)
                }

                // Foto
                HStack {
                    Spacer()
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.primary, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                .frame(width: 110, height: 110)
                                .background(Color.primaryLight.cornerRadius(16))
                            if let data = photoData, let img = UIImage(data: data) {
                                Image(uiImage: img).resizable().scaledToFill()
                                    .frame(width: 110, height: 110).clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 4) {
                                    Text("📷").font(.system(size: 28))
                                    Text("Agregar foto").font(.system(size: 11, weight: .medium)).foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                photoData = data
                            }
                        }
                    }
                    Spacer()
                }

                // Si es onboarding, mostrar selector de especie en el form
                if isOnboarding || isEditing {
                    fieldLabel("Especie")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(Pet.PetSpecies.allCases, id: \.self) { s in
                            Button { species = s } label: {
                                VStack(spacing: 2) {
                                    Text(s.emoji).font(.system(size: 22))
                                    Text(s.rawValue).font(.system(size: 10, weight: .medium))
                                        .foregroundColor(species == s ? .green : .textMuted)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(species == s ? Color.primaryLight : Color(white: 0.97))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(species == s ? Color.primary : Color.clear, lineWidth: 1))
                            }
                        }
                    }
                }

                fieldLabel("Nombre")
                TextField("Nombre de tu mascota", text: $name).textFieldStyle(PetFieldStyle())

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("Raza")
                        TextField("Ej: Labrador", text: $breed).textFieldStyle(PetFieldStyle())
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("Edad (años)")
                        TextField("0", value: $ageYears, format: .number)
                            .textFieldStyle(PetFieldStyle()).keyboardType(.decimalPad)
                    }
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("Peso (kg)")
                        TextField("0.0", value: $weight, format: .number)
                            .textFieldStyle(PetFieldStyle()).keyboardType(.decimalPad)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("Género")
                        HStack(spacing: 6) {
                            ForEach(Pet.Gender.allCases, id: \.self) { g in
                                Button { gender = g } label: {
                                    Text("\(g.symbol) \(g.rawValue)").font(.system(size: 12, weight: .medium))
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(gender == g ? Color.primaryLight : Color(white: 0.97))
                                        .foregroundColor(gender == g ? Color.green : .textMuted)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(gender == g ? Color.primary : Color.clear, lineWidth: 1))
                                }
                            }
                        }
                    }
                }

                fieldLabel("Color de pelaje")
                TextField("Ej: Dorado, negro con blanco…", text: $petColor).textFieldStyle(PetFieldStyle())

                Divider()
                Text("Información médica (opcional)").font(.system(size: 13, weight: .medium)).foregroundColor(.textMuted)

                fieldLabel("Microchip")
                TextField("Número de microchip", text: $microchip).textFieldStyle(PetFieldStyle())
                fieldLabel("Alergias")
                TextField("Ninguna", text: $allergies).textFieldStyle(PetFieldStyle())
                fieldLabel("Tipo de sangre")
                TextField("Ej: DEA 1.1+", text: $bloodType).textFieldStyle(PetFieldStyle())
                Toggle(isOn: $sterilized) {
                    Text("Esterilizado / castrado").font(.system(size: 13))
                }.tint(Color.primary)

                fieldLabel("Fecha de nacimiento")
                DatePicker("", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(.compact).labelsHidden()

                PrimaryButton(title: isEditing ? "Guardar cambios" : "Guardar mascota") { savePet() }
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color.bgPage)
        .navigationTitle(isEditing ? "Editar mascota" : "Nueva mascota")
    }

    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 11, weight: .medium)).foregroundColor(.textMuted)
    }

    private func savePet() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { showValidation = true; return }
        var pet = Pet(name: name, species: species, breed: breed, ageYears: ageYears, weight: weight,
                      gender: gender, color: petColor, microchip: microchip, sterilized: sterilized,
                      allergies: allergies.isEmpty ? "Ninguna" : allergies,
                      bloodType: bloodType, birthDate: birthDate, photoData: photoData)
        if let existing = existingPet { pet.id = existing.id; petStore.updatePet(pet) }
        else { petStore.addPet(pet) }
        if isOnboarding { hasOnboarded = true }
        dismiss()
    }

    private func populateIfEditing() {
        guard let p = existingPet else { return }
        name = p.name; species = p.species; breed = p.breed; ageYears = p.ageYears
        weight = p.weight; gender = p.gender; petColor = p.color; microchip = p.microchip
        sterilized = p.sterilized; allergies = p.allergies; bloodType = p.bloodType
        birthDate = p.birthDate; photoData = p.photoData
    }
}

struct PetFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration.font(.system(size: 13))
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(Color(white: 0.97)).cornerRadius(9)
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.cardBorder, lineWidth: 0.5))
    }
}
