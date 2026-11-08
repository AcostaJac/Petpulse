import SwiftUI
import Combine

// MARK: - User Model
struct AppUser: Codable {
    var id = UUID()
    var name: String
    var email: String
    var passwordHash: String
    var isVerified: Bool = false
    var verificationCode: String = ""
}

class PetStore: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var selectedPet: Pet?
    @Published var isPremium: Bool = false        // NO se carga de UserDefaults al inicio
    @Published var showPremiumPaywall: Bool = false
    @Published var selectedTab: Int = 0

    // Auth
    @Published var currentUser: AppUser? = nil
    @Published var isLoggedIn: Bool = false

    private let petsKey    = "savedPets_v2"
    private let premiumKey = "isPremium_v2"
    private let usersKey   = "registeredUsers_v2"

    var canAddMorePets: Bool { isPremium || pets.count < 1 }

    init() {
        // Primero restaurar sesión (establece currentUser)
        // LUEGO cargar mascotas (necesita currentUser)
        loadSession()
        // isPremium solo se activa manualmente, nunca en el init
    }

    // MARK: - Auth
    func register(name: String, email: String, password: String) -> (Bool, String) {
        var users = loadUsers()
        if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            return (false, "Este correo ya está registrado.")
        }
        // Código interno siempre es 123456 (simula envío al correo)
        let user = AppUser(
            name: name, email: email,
            passwordHash: simpleHash(password),
            isVerified: false,
            verificationCode: "123456"
        )
        users.append(user)
        saveUsers(users)
        return (true, "123456")
    }

    func verifyCode(_ code: String, email: String) -> Bool {
        var users = loadUsers()
        guard let idx = users.firstIndex(where: { $0.email.lowercased() == email.lowercased() }) else { return false }
        if users[idx].verificationCode == code {
            users[idx].isVerified = true
            saveUsers(users)
            currentUser = users[idx]
            isLoggedIn = true
            saveSession()
            loadPets()   // ← cargar mascotas del usuario recién verificado
            return true
        }
        return false
    }

    func login(email: String, password: String) -> (Bool, String) {
        let users = loadUsers()
        guard let user = users.first(where: { $0.email.lowercased() == email.lowercased() }) else {
            return (false, "Correo no registrado.")
        }
        if user.passwordHash != simpleHash(password) { return (false, "Contraseña incorrecta.") }
        if !user.isVerified { return (false, "Debes verificar tu correo primero.") }
        currentUser = user
        isLoggedIn = true
        isPremium = false  // siempre empieza sin premium al hacer login
        saveSession()
        loadPets()         // ← cargar mascotas del usuario
        return (true, "")
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
        isPremium = false   // reset premium al cerrar sesión
        pets = []
        selectedPet = nil
        selectedTab = 0
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
    }

    // MARK: - Premium (solo se activa con botón explícito)
    func upgradeToPremium() {
        isPremium = true
        // NO guardar en UserDefaults para que no persista entre sesiones en demo
    }

    // MARK: - Pets
    func addPet(_ pet: Pet) {
        guard canAddMorePets else { showPremiumPaywall = true; return }
        pets.append(pet)
        if selectedPet == nil { selectedPet = pet }
        savePets()
    }

    func updatePet(_ pet: Pet) {
        if let idx = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[idx] = pet
            if selectedPet?.id == pet.id { selectedPet = pet }
            savePets()
        }
    }

    func deletePet(_ pet: Pet) {
        pets.removeAll { $0.id == pet.id }
        if selectedPet?.id == pet.id { selectedPet = pets.first }
        savePets()
    }

    func selectPet(_ pet: Pet) { selectedPet = pet }

    func addHealthRecord(_ record: HealthRecord, to pet: Pet) {
        var updated = pet
        updated.healthRecords.insert(record, at: 0)
        updatePet(updated)
    }

    // MARK: - Persistencia privada
    private func savePets() {
        guard let u = currentUser else { return }
        let key = petsKey + u.id.uuidString
        if let d = try? JSONEncoder().encode(pets) {
            UserDefaults.standard.set(d, forKey: key)
        }
    }

    private func loadPets() {
        guard let u = currentUser else { return }
        let key = petsKey + u.id.uuidString
        guard let d = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Pet].self, from: d) else {
            pets = []; selectedPet = nil; return
        }
        pets = decoded
        selectedPet = pets.first
    }

    private func saveSession() {
        UserDefaults.standard.set(currentUser?.email, forKey: "currentUserEmail")
    }

    private func loadSession() {
        guard let email = UserDefaults.standard.string(forKey: "currentUserEmail") else { return }
        let users = loadUsers()
        guard let u = users.first(where: { $0.email == email }), u.isVerified else { return }
        currentUser = u
        isLoggedIn = true
        isPremium = false   // nunca restaurar premium desde disco
        loadPets()          // ← cargar mascotas DESPUÉS de establecer currentUser
    }

    private func simpleHash(_ s: String) -> String {
        String(s.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }) + s.count.description
    }

    private func loadUsers() -> [AppUser] {
        guard let d = UserDefaults.standard.data(forKey: usersKey),
              let u = try? JSONDecoder().decode([AppUser].self, from: d) else { return [] }
        return u
    }

    private func saveUsers(_ users: [AppUser]) {
        if let d = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(d, forKey: usersKey)
        }
    }
}
