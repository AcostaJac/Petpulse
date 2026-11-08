import SwiftUI

@main
struct PetCareApp: App {
    @StateObject private var petStore = PetStore()
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(petStore)
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}

// Vista raíz — el .preferredColorScheme aquí arriba propaga a TODAS las vistas,
// incluyendo sheets, fullScreenCover y tabs.
struct RootView: View {
    @EnvironmentObject var petStore: PetStore

    var body: some View {
        Group {
            if petStore.isLoggedIn {
                ContentView()
            } else {
                AuthRootView()
            }
        }
        .sheet(isPresented: $petStore.showPremiumPaywall) {
            PremiumView().environmentObject(petStore)
        }
        .animation(.easeInOut(duration: 0.3), value: petStore.isLoggedIn)
    }
}
