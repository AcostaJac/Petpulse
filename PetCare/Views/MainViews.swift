import SwiftUI

// MARK: - PetProfileView

struct PetProfileView: View {
    let pet: Pet
    @EnvironmentObject var petStore: PetStore
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero header
                    ZStack(alignment: .bottom) {
                        Color.primary.frame(height: 160)
                        VStack(spacing: 8) {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 76, height: 76)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                                if let data = pet.photoData, let img = UIImage(data: data) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                        .frame(width: 72, height: 72).clipShape(Circle())
                                } else {
                                    Text(pet.species.emoji).font(.system(size: 36))
                                }
                            }
                            Text(pet.name).font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                            Text("\(pet.breed) · \(pet.gender.symbol) \(pet.gender.rawValue)")
                                .font(.system(size: 12)).foregroundColor(Color(hex:"9FE1CB"))
                            HStack(spacing: 6) {
                                ForEach(["\(Int(pet.ageYears)) años", "\(String(format:"%.1f", pet.weight)) kg", pet.color.isEmpty ? pet.species.rawValue : pet.color], id: \.self) { t in
                                    Text(t).font(.system(size: 10))
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white).cornerRadius(10)
                                }
                            }
                        }
                        .padding(.bottom, 16)
                    }

                    VStack(spacing: 12) {
                        // Stats
                        HStack(spacing: 8) {
                            StatCard(value: "\(Int(pet.ageYears))", label: "Años")
                            StatCard(value: String(format: "%.1f kg", pet.weight), label: "Peso")
                            StatCard(value: "\(pet.vaccines.filter(\.isApplied).count)", label: "Vacunas")
                            StatCard(value: "\(pet.healthRecords.count)", label: "Registros")
                        }

                        // General info
                        CardView {
                            VStack(alignment: .leading, spacing: 0) {
                                SectionHeader(title: "Información").padding(.bottom, 8)
                                infoRow("Microchip", pet.microchip.isEmpty ? "No registrado" : pet.microchip)
                                infoRow("Esterilizado", pet.sterilized ? "Sí" : "No")
                                infoRow("Alergias", pet.allergies)
                                infoRow("Tipo de sangre", pet.bloodType.isEmpty ? "No registrado" : pet.bloodType)
                                infoRow("Fecha de nac.", pet.birthDate.formatted(date: .abbreviated, time: .omitted))
                            }
                        }

                        // Vaccines
                        CardView {
                            VStack(alignment: .leading, spacing: 0) {
                                SectionHeader(title: "Vacunas").padding(.bottom, 8)
                                if pet.vaccines.isEmpty {
                                    Text("Sin vacunas registradas").font(.system(size: 12)).foregroundColor(.textMuted)
                                        .padding(.vertical, 8)
                                } else {
                                    ForEach(pet.vaccines) { v in
                                        HStack(spacing: 8) {
                                            Text(v.isApplied ? "✅" : "⚠️").font(.system(size: 14))
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text(v.name).font(.system(size: 12, weight: .medium))
                                                if let next = v.nextDate {
                                                    Text("Próx: \(next.formatted(date: .abbreviated, time: .omitted))")
                                                        .font(.system(size: 10)).foregroundColor(.textMuted)
                                                }
                                            }
                                            Spacer()
                                            Text(v.statusLabel).font(.system(size: 10))
                                                .foregroundColor(v.isApplied ? .primary : .coral)
                                        }
                                        .padding(.vertical, 5)
                                        Divider()
                                    }
                                }
                            }
                        }

                        // Edit button
                        OutlineButton(title: "✏️ Editar perfil") { showEdit = true }

                        Button(role: .destructive) { showDeleteAlert = true } label: {
                            Text("Eliminar mascota")
                                .font(.system(size: 14)).foregroundColor(.coral)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                        }
                    }
                    .padding(14).padding(.bottom, 20)
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color.bgPage)
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26)).foregroundStyle(Color.white, Color.black.opacity(0.3))
                }
                .padding(.top, 52).padding(.trailing, 16)
            }
            .sheet(isPresented: $showEdit) {
                AddPetView(existingPet: pet).environmentObject(petStore)
            }
            .alert("¿Eliminar a \(pet.name)?", isPresented: $showDeleteAlert) {
                Button("Eliminar", role: .destructive) { petStore.deletePet(pet); dismiss() }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label).font(.system(size: 12)).foregroundColor(.textMuted)
                Spacer()
                Text(value).font(.system(size: 12, weight: .medium))
            }
            .padding(.vertical, 5)
            Divider()
        }
    }
}

// MARK: - StoresView

struct StoresView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    let categories = ["Todo","Comida","Juguetes","Accesorios","Medicinas"]
    let stores = PetShop.sampleData

    var filteredStores: [PetShop] {
        stores.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.products.contains { $0.localizedCaseInsensitiveContains(searchText) } }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.textMuted)
                TextField("Buscar tiendas o productos…", text: $searchText)
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 12).padding(.vertical, 9)
            .background(Color(white: 0.97))
            .cornerRadius(11)
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.cardBorder, lineWidth: 0.5))
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(Color.white)

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(categories, id: \.self) { c in
                        Button { selectedCategory = selectedCategory == c ? nil : c } label: {
                            Text(c).font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(selectedCategory == c ? Color.goldLight : Color(white: 0.95))
                                .foregroundColor(selectedCategory == c ? Color(hex:"633806") : Color(white: 0.4))
                                .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
            }
            .background(Color.white).overlay(Divider(), alignment: .bottom)

            // Store list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredStores) { s in
                        StoreCard(store: s)
                    }
                }
                .padding(12)
            }
            .background(Color.bgPage)
        }
    }
}

struct StoreCard: View {
    let store: PetShop
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(Color.goldLight).frame(width: 40, height: 40)
                        Text(store.emoji).font(.system(size: 20))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(store.name).font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Badge(text: store.isOpen ? "Abierta" : "Cerrada",
                                  color: store.isOpen ? Color(hex:"3B6D11") : Color(white: 0.4),
                                  bgColor: store.isOpen ? Color.greenLight : Color(white: 0.93))
                        }
                        Text("\(store.type) · \(String(format: "%.1f", store.distanceKm)) km")
                            .font(.system(size: 10)).foregroundColor(.textMuted)
                    }
                }
                FlowLayout(spacing: 5) {
                    ForEach(store.products, id: \.self) { p in
                        Text(p).font(.system(size: 10))
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Color(white: 0.95)).cornerRadius(6)
                    }
                }
                HStack(spacing: 8) {
                    Button {
                        if let url = URL(string: "tel://\(store.phone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill").font(.system(size: 10))
                            Text(store.phone).font(.system(size: 10, weight: .medium))
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(Color.goldLight).foregroundColor(Color(hex:"854F0B")).cornerRadius(8)
                    }
                    Button {} label: {
                        Text("Ver →").font(.system(size: 10, weight: .medium))
                            .padding(.vertical, 8).padding(.horizontal, 14)
                            .background(Color.greenLight).foregroundColor(Color(hex:"3B6D11")).cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - PremiumView

struct PremiumView: View {
    @EnvironmentObject var petStore: PetStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("⭐").font(.system(size: 40))
                        Text("PetCare Plus").font(.system(size: 22, weight: .semibold)).foregroundColor(Color(hex:"412402"))
                        Text("Cuida a todas tus mascotas sin límite")
                            .font(.system(size: 14)).foregroundColor(Color(hex:"854F0B"))
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 24)
                    .background(Color.goldLight)

                    VStack(spacing: 14) {
                        // Comparison
                        HStack(alignment: .top, spacing: 10) {
                            planCard(title: "Gratis", price: "$0/mes", features: [
                                (true, "1 mascota"),
                                (true, "Chat IA básico"),
                                (true, "Mapa veterinarias"),
                                (true, "Seguimiento salud"),
                                (false, "Mascotas ilimitadas"),
                                (false, "IA avanzada (Gemini)"),
                                (false, "Historial sin límite"),
                                (false, "Alertas prioritarias"),
                            ], isFeatured: false)

                            planCard(title: "Plus ⭐", price: "$79/mes", features: [
                                (true, "Mascotas ilimitadas"),
                                (true, "Chat IA Gemini avanzado"),
                                (true, "Mapa veterinarias"),
                                (true, "Seguimiento salud"),
                                (true, "IA avanzada"),
                                (true, "Historial sin límite"),
                                (true, "Alertas prioritarias"),
                                (true, "Soporte premium"),
                            ], isFeatured: true)
                        }

                        // Note
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill").foregroundColor(Color(hex:"854F0B")).font(.system(size: 14))
                            Text("A partir de la segunda mascota necesitas PetCare Plus. ¡No dejes a ninguno sin cuidar!")
                                .font(.system(size: 12)).foregroundColor(Color(hex:"854F0B"))
                        }
                        .padding(12).background(Color.goldLight).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex:"FAC775"), lineWidth: 0.5))

                        PrimaryButton(title: "Comenzar prueba gratis 7 días", color: Color.gold) {
                            petStore.upgradeToPremium()
                            dismiss()
                        }

                        Text("Sin cargos hasta que termine tu prueba · Cancela cuando quieras")
                            .font(.system(size: 10)).foregroundColor(.textMuted)
                            .multilineTextAlignment(.center)

                        // Annual plan
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Plan anual").font(.system(size: 13, weight: .medium))
                                Text("$699/año — Ahorra 26%").font(.system(size: 11)).foregroundColor(.textMuted)
                            }
                            Spacer()
                            Badge(text: "💰 Mejor valor", color: Color(hex:"3B6D11"), bgColor: Color.greenLight)
                        }
                        .padding(12).background(Color.white).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cardBorder, lineWidth: 0.5))
                    }
                    .padding(.horizontal, 16).padding(.bottom, 20)
                }
            }
            .background(Color.bgPage)
            .navigationTitle("PetCare Plus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Cerrar") { dismiss() } } }
        }
    }

    private func planCard(title: String, price: String, features: [(Bool, String)], isFeatured: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 12, weight: .semibold))
                .foregroundColor(isFeatured ? Color(hex:"854F0B") : .textMuted)
            Text(price).font(.system(size: 17, weight: .semibold))
            ForEach(features, id: \.1) { ok, label in
                HStack(spacing: 5) {
                    Text(ok ? (isFeatured ? "⭐" : "✓") : "✗")
                        .font(.system(size: ok ? 10 : 11))
                        .foregroundColor(ok ? (isFeatured ? .gold : .primary) : Color.textHint)
                    Text(label).font(.system(size: 10)).foregroundColor(ok ? Color(white: 0.2) : Color.textHint)
                }
            }
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(isFeatured ? Color.gold : Color.cardBorder, lineWidth: isFeatured ? 2 : 0.5))
        .overlay(alignment: .top) {
            if isFeatured {
                Text("MÁS POPULAR")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.gold).cornerRadius(10)
                    .offset(y: -12)
            }
        }
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject var petStore: PetStore
    @State private var showAddPet = false
    @State private var showPremium = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("notifVaccines") private var notifVaccines = true
    @AppStorage("notifMeds") private var notifMeds = true
    @AppStorage("notifAppointments") private var notifAppointments = true
    // auth manejado por PetStore

    var body: some View {
        NavigationStack {
            List {
                // Profile header
                Section {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color.primary).frame(width: 50, height: 50)
                            Text(String(petStore.currentUser?.name.prefix(1) ?? "U"))
                                .font(.system(size: 22, weight: .semibold)).foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(petStore.currentUser?.name ?? "Usuario").font(.system(size: 14, weight: .medium))
                            Text(petStore.currentUser?.email ?? "").font(.system(size: 11)).foregroundColor(.textMuted)
                        }
                        Spacer()
                        Badge(text: petStore.isPremium ? "Plus ⭐" : "Gratis",
                              color: petStore.isPremium ? Color(hex:"854F0B") : .textMuted,
                              bgColor: petStore.isPremium ? Color.goldLight : Color(white: 0.93))
                    }
                    .padding(.vertical, 4)
                }

                Section("Mascotas") {
                    ForEach(petStore.pets) { p in
                        HStack(spacing: 8) {
                            Text(p.species.emoji).font(.system(size: 18))
                            Text(p.name).font(.system(size: 13))
                            Spacer()
                            Text("\(Int(p.ageYears)) años · \(String(format:"%.1f", p.weight))kg")
                                .font(.system(size: 11)).foregroundColor(.textMuted)
                        }
                    }
                    Button { showAddPet = true } label: {
                        Label("Agregar mascota", systemImage: "plus.circle").font(.system(size: 13)).foregroundColor(.primary)
                    }
                    if !petStore.isPremium {
                        Button { showPremium = true } label: {
                            Label("Mejorar a PetCare Plus ⭐", systemImage: "star.fill")
                                .font(.system(size: 13)).foregroundColor(Color(hex:"854F0B"))
                        }
                    }
                }

                Section("Apariencia") {
                    HStack {
                        Image(systemName: darkModeEnabled ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 13)).foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(darkModeEnabled ? Color(white:0.2) : Color.gold).cornerRadius(7)
                        Text("Modo nocturno").font(.system(size: 13))
                        Spacer()
                        Toggle("", isOn: $darkModeEnabled)
                            .tint(Color.primary)
                            .labelsHidden()
                            // Dark mode manejado por .preferredColorScheme en PetCareApp
                    }
                }

                Section("Notificaciones") {
                    notifRow("Vacunas", icon: "bell.badge.fill", color: .coral, binding: $notifVaccines)
                    notifRow("Medicación", icon: "pills.fill", color: .blue, binding: $notifMeds)
                    notifRow("Citas veterinarias", icon: "calendar.badge.clock", color: .primary, binding: $notifAppointments)
                }

                Section("Cuenta") {
                    settingRow("Editar perfil", icon: "person.fill", color: .primary)
                    settingRow("Privacidad y seguridad", icon: "lock.fill", color: Color(white: 0.4))
                    settingRow("Suscripción", icon: "creditcard.fill", color: .gold)
                }

                Section("App") {
                    settingRow("Idioma: Español", icon: "globe", color: .blue)
                    settingRow("Permisos de ubicación", icon: "location.fill", color: .coral)
                }

                Section("Soporte") {
                    settingRow("Ayuda y FAQ", icon: "questionmark.circle.fill", color: .primary)
                    settingRow("Contactar soporte", icon: "envelope.fill", color: .blue)
                    settingRow("Calificar la app", icon: "star.fill", color: .gold)
                }

                Section {
                    Button(role: .destructive) {
                        petStore.logout()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cerrar sesión").font(.system(size: 14, weight: .medium))
                            Spacer()
                        }
                    }
                } footer: {
                    Text("PetCare v1.0.0 · Swift Changemakers Hackathon 2026")
                        .font(.system(size: 10)).foregroundColor(.textHint)
                        .multilineTextAlignment(.center).frame(maxWidth: .infinity).padding(.top, 8)
                }
            }
            .navigationTitle("Configuración")
            .sheet(isPresented: $showAddPet) { AddPetView().environmentObject(petStore) }
            .sheet(isPresented: $showPremium) { PremiumView().environmentObject(petStore) }

        }
    }

    private func notifRow(_ title: String, icon: String, color: Color, binding: Binding<Bool>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 13)).foregroundColor(.white)
                .frame(width: 28, height: 28).background(color).cornerRadius(7)
            Text(title).font(.system(size: 13))
            Spacer()
            Toggle("", isOn: binding).tint(Color.primary).labelsHidden()
        }
    }

    private func settingRow(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 13)).foregroundColor(.white)
                .frame(width: 28, height: 28).background(color).cornerRadius(7)
            Text(title).font(.system(size: 13))
        }
    }
}
