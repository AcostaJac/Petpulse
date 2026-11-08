import SwiftUI

struct ContentView: View {
    @EnvironmentObject var petStore: PetStore
    @State private var showAddPetOnboarding = false

    var body: some View {
        Group {
            if petStore.pets.isEmpty {
                // Primera vez: agregar mascota
                NavigationStack {
                    VStack(spacing: 24) {
                        Spacer()
                        AppLogoView(size: 80)
                        Text("¡Hola, \(petStore.currentUser?.name.components(separatedBy:" ").first ?? "")! 👋")
                            .font(.system(size: 22, weight: .bold))
                        Text("Agrega tu primera mascota\npara comenzar")
                            .font(.system(size: 15)).foregroundColor(.textMuted)
                            .multilineTextAlignment(.center)
                        PrimaryButton(title: "🐾  Agregar mi mascota") { showAddPetOnboarding = true }
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                    .background(Color(hex:"F0FBF6").ignoresSafeArea())
                }
                .fullScreenCover(isPresented: $showAddPetOnboarding) {
                    AddPetView(isOnboarding: true).environmentObject(petStore)
                }
            } else {
                TabView(selection: $petStore.selectedTab) {
                    HomeView()
                        .tabItem { Label("Inicio", systemImage: "house.fill") }.tag(0)
                    AIChatView()
                        .tabItem { Label("Chat IA", systemImage: "message.fill") }.tag(1)
                    MapTabView()
                        .tabItem { Label("Mapa", systemImage: "map.fill") }.tag(2)
                    HealthTrackingView()
                        .tabItem { Label("Salud", systemImage: "chart.bar.fill") }.tag(3)
                    SettingsView()
                        .tabItem { Label("Config.", systemImage: "gearshape.fill") }.tag(4)
                }
                .tint(Color.primary)
            }
        }
        .environmentObject(petStore)
    }
}

struct MapTabView: View {
    @State private var mapTab = 0
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mapa", selection: $mapTab) {
                    Text("Veterinarias").tag(0)
                    Text("Pet Friendly").tag(1)
                    Text("Tiendas").tag(2)
                }
                .pickerStyle(.segmented).padding(.horizontal).padding(.vertical, 8)
                .background(Color.white)
                if mapTab == 0 { VetMapView() }
                else if mapTab == 1 { PetFriendlyMapView() }
                else { StoresView() }
            }
            .navigationTitle("Explorar").navigationBarTitleDisplayMode(.inline)
        }
    }
}
