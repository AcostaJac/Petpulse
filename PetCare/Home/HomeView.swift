import SwiftUI

struct HomeView: View {
    @EnvironmentObject var petStore: PetStore
    @State private var showAddPet = false
    @State private var showPetProfile = false

    var pet: Pet? { petStore.selectedPet }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    contentSection
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color.bgPage)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddPet) { AddPetView().environmentObject(petStore) }
        .sheet(isPresented: $showPetProfile) {
            if let p = pet { PetProfileView(pet: p).environmentObject(petStore) }
        }
    }

    // MARK: Header
    private var headerSection: some View {
        ZStack(alignment: .top) {
            Color.primary.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Color.clear.frame(height: 50)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Buenos días 👋").font(.system(size: 12)).foregroundColor(Color(hex:"9FE1CB"))
                        Text(petStore.currentUser?.name.components(separatedBy:" ").first ?? "").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                    }
                    Spacer()
                    // Ícono de la app en el header
                    AppIconView(size: 38, cornerRadius: 10)
                        .overlay(RoundedRectangle(cornerRadius:10).stroke(Color.white.opacity(0.3),lineWidth:1))
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(petStore.pets) { p in
                            PetChip(pet: p, isSelected: petStore.selectedPet?.id == p.id) { petStore.selectPet(p) }
                        }
                        Button {
                            if petStore.canAddMorePets { showAddPet = true }
                            else { petStore.showPremiumPaywall = true }
                        } label: {
                            Text("+ Agregar").font(.system(size:11,weight:.medium)).foregroundColor(.white)
                                .padding(.horizontal,12).padding(.vertical,6)
                                .background(Color.white.opacity(0.15)).cornerRadius(18)
                        }
                    }
                }
                Color.clear.frame(height: 4)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity).padding(.bottom, 12)
    }

    // MARK: Content
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let p = pet {
                // Pet hero
                Button { showPetProfile = true } label: { petHeroCard(p) }.buttonStyle(.plain)

                // Stats
                HStack(spacing: 8) {
                    StatCard(value: String(format:"%.1f kg", p.weight), label: "Peso")
                    StatCard(value: "\(Int(p.ageYears)) años", label: "Edad")
                    StatCard(value: "\(p.vaccines.filter(\.isApplied).count)", label: "Vacunas")
                }

                // Quick actions — FUNCIONALES
                SectionHeader(title: "Acciones rápidas").padding(.top, 4)
                quickActionsGrid

                // Reminder
                reminderCard(p)

                // Health recent
                if !p.healthRecords.isEmpty {
                    SectionHeader(title: "Registros recientes").padding(.top, 4)
                    recentHealthCard(p)
                }
            } else {
                emptyState
            }
        }
        .padding(16)
    }

    // MARK: Pet hero card
    private func petHeroCard(_ p: Pet) -> some View {
        CardView {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius:14).fill(Color.primaryLight).frame(width:64,height:64)
                    if let data = p.photoData, let img = UIImage(data:data) {
                        Image(uiImage:img).resizable().scaledToFill().frame(width:64,height:64).clipShape(RoundedRectangle(cornerRadius:14))
                    } else {
                        Text(p.species.emoji).font(.system(size:34))
                    }
                }
                VStack(alignment:.leading,spacing:4) {
                    Text(p.name).font(.system(size:15,weight:.semibold))
                    Text("\(p.breed) · \(Int(p.ageYears)) años · \(String(format:"%.1f",p.weight)) kg")
                        .font(.system(size:11)).foregroundColor(.textMuted)
                    HStack(spacing:5) {
                        Badge(text:"Saludable",color:.green,bgColor:.greenLight)
                        Badge(text:"Vacunas al día",color:.green,bgColor:.greenLight)
                    }
                }
                Spacer()
                Image(systemName:"chevron.right").font(.system(size:12)).foregroundColor(.textHint)
            }
        }
    }

    // MARK: Quick actions — navegan a tabs reales
    private var quickActionsGrid: some View {
        LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())], spacing:8) {
            quickAction(icon:"💬", label:"Chat IA",    bg:.primaryLight, tab:1)
            quickAction(icon:"🏥", label:"Veterinarias", bg:.coralLight, tab:2)
            quickAction(icon:"📊", label:"Salud",       bg:.blueLight,   tab:3)
            quickAction(icon:"🗺️", label:"Pet Friendly", bg:.greenLight,  tab:2)
        }
    }

    private func quickAction(icon: String, label: String, bg: Color, tab: Int) -> some View {
        Button {
            petStore.selectedTab = tab
        } label: {
            CardView {
                HStack(spacing:8) {
                    ZStack {
                        RoundedRectangle(cornerRadius:8).fill(bg).frame(width:32,height:32)
                        Text(icon).font(.system(size:15))
                    }
                    Text(label).font(.system(size:12,weight:.medium))
                    Spacer()
                    Image(systemName:"chevron.right").font(.system(size:10)).foregroundColor(.textHint)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func reminderCard(_ p: Pet) -> some View {
        HStack(spacing:10) {
            Text("💉").font(.system(size:20))
            VStack(alignment:.leading,spacing:2) {
                Text("Próxima vacuna").font(.system(size:12,weight:.medium)).foregroundColor(Color(hex:"633806"))
                if let v = p.vaccines.first(where:{ !$0.isApplied }) {
                    Text(v.name).font(.system(size:11)).foregroundColor(Color(hex:"854F0B"))
                } else {
                    Text("Todas al día ✓").font(.system(size:11)).foregroundColor(.green)
                }
            }
            Spacer()
            Button { petStore.selectedTab = 3 } label: {
                Text("Ver →").font(.system(size:11,weight:.medium)).foregroundColor(Color(hex:"854F0B"))
            }
        }
        .padding(12).background(Color.goldLight).cornerRadius(11)
        .overlay(RoundedRectangle(cornerRadius:11).stroke(Color(hex:"FAC775"),lineWidth:0.5))
    }

    private func recentHealthCard(_ p: Pet) -> some View {
        CardView {
            VStack(spacing:0) {
                ForEach(p.healthRecords.prefix(3)) { r in
                    HStack(spacing:8) {
                        ZStack {
                            RoundedRectangle(cornerRadius:7).fill(r.type.bgColor).frame(width:26,height:26)
                            Text(r.type.emoji).font(.system(size:12))
                        }
                        Text(r.note.isEmpty ? r.type.rawValue : r.note).font(.system(size:11)).lineLimit(1)
                        Spacer()
                        Text(r.date,style:.date).font(.system(size:10)).foregroundColor(.textHint)
                    }
                    .padding(.vertical,5)
                    Divider()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing:16) {
            AppIconView(size:70)
            Text("Agrega tu primera mascota").font(.system(size:16,weight:.medium))
            PrimaryButton(title:"Agregar mascota") { showAddPet = true }
        }
        .frame(maxWidth:.infinity).padding(40)
    }
}
