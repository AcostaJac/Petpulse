import Foundation
import SwiftUI
import CoreLocation

// MARK: - Pet

struct Pet: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var species: PetSpecies
    var breed: String
    var ageYears: Double
    var weight: Double
    var gender: Gender
    var color: String
    var microchip: String
    var sterilized: Bool
    var allergies: String
    var bloodType: String
    var birthDate: Date
    var healthRecords: [HealthRecord]
    var vaccines: [Vaccine]
    var photoData: Data?

    init(name: String, species: PetSpecies, breed: String, ageYears: Double,
         weight: Double, gender: Gender, color: String = "", microchip: String = "",
         sterilized: Bool = false, allergies: String = "Ninguna", bloodType: String = "",
         birthDate: Date = Date(), healthRecords: [HealthRecord] = [], vaccines: [Vaccine] = [],
         photoData: Data? = nil) {
        self.name = name; self.species = species; self.breed = breed
        self.ageYears = ageYears; self.weight = weight; self.gender = gender
        self.color = color; self.microchip = microchip; self.sterilized = sterilized
        self.allergies = allergies; self.bloodType = bloodType; self.birthDate = birthDate
        self.healthRecords = healthRecords; self.vaccines = vaccines
        self.photoData = photoData
    }

    static func == (lhs: Pet, rhs: Pet) -> Bool { lhs.id == rhs.id }

    enum PetSpecies: String, Codable, CaseIterable {
        case dog = "Perro", cat = "Gato", rabbit = "Conejo", bird = "Ave", fish = "Pez", other = "Otro"
        var emoji: String {
            switch self { case .dog: "🐶"; case .cat: "🐱"; case .rabbit: "🐰"; case .bird: "🦜"; case .fish: "🐠"; case .other: "🐾" }
        }
    }

    enum Gender: String, Codable, CaseIterable {
        case male = "Macho", female = "Hembra"
        var symbol: String { self == .male ? "♂" : "♀" }
    }
}

// MARK: - HealthRecord

struct HealthRecord: Identifiable, Codable {
    var id = UUID()
    var type: RecordType
    var note: String
    var date: Date
    var weight: Double?
    var foodScore: Int?

    enum RecordType: String, Codable, CaseIterable {
        case food = "Comida", medicine = "Medicina", illness = "Enfermedad", weight = "Peso", general = "General"
        var emoji: String {
            switch self { case .food: "🍽️"; case .medicine: "💊"; case .illness: "🤒"; case .weight: "⚖️"; case .general: "📋" }
        }
        var color: Color {
            switch self {
            case .food: .green; case .medicine: .blue; case .illness: .coral; case .weight: Color(hex:"854F0B"); case .general: .gray
            }
        }
        var bgColor: Color {
            switch self {
            case .food: .greenLight; case .medicine: .blueLight; case .illness: .coralLight; case .weight: .goldLight; case .general: Color(hex:"F1EFE8")
            }
        }
    }
}

// MARK: - Vaccine

struct Vaccine: Identifiable, Codable {
    var id = UUID()
    var name: String
    var appliedDate: Date?
    var nextDate: Date?
    var isApplied: Bool

    var statusLabel: String {
        guard isApplied, let applied = appliedDate else { return "Pendiente" }
        let fmt = DateFormatter(); fmt.dateStyle = .medium; fmt.locale = Locale(identifier: "es_MX")
        return fmt.string(from: applied)
    }
}

// MARK: - Veterinaria

struct Veterinaria: Identifiable {
    var id = UUID()
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var phone: String
    var stars: Double
    var reviewCount: Int
    var priceLevel: String
    var isAssociated: Bool
    var isAvailable: Bool
    var isOpen: Bool
    var openHours: String
    var distanceKm: Double
    var services: [String]
    var acceptedAnimals: [String]

    static let sampleData: [Veterinaria] = [
        Veterinaria(name: "VetCare Plus", address: "Av. Insurgentes Sur 1234, CDMX",
                    coordinate: CLLocationCoordinate2D(latitude: 19.432, longitude: -99.132),
                    phone: "55 1234 5678", stars: 5.0, reviewCount: 142, priceLevel: "$$",
                    isAssociated: true, isAvailable: true, isOpen: true, openHours: "9am – 8pm",
                    distanceKm: 0.8, services: ["Consulta general","Vacunación","Cirugía","Urgencias 24h"],
                    acceptedAnimals: ["🐶 Perros","🐱 Gatos","🐰 Conejos"]),
        Veterinaria(name: "Clínica Animal", address: "Calle Durango 45, Col. Roma",
                    coordinate: CLLocationCoordinate2D(latitude: 19.426, longitude: -99.160),
                    phone: "55 9876 5432", stars: 4.0, reviewCount: 87, priceLevel: "$",
                    isAssociated: false, isAvailable: false, isOpen: true, openHours: "8am – 6pm",
                    distanceKm: 1.4, services: ["Consulta general","Vacunación","Peluquería"],
                    acceptedAnimals: ["🐶 Perros","🐱 Gatos","🦜 Aves"]),
        Veterinaria(name: "PetSalud Especialistas", address: "Av. Coyoacán 890, Del Valle",
                    coordinate: CLLocationCoordinate2D(latitude: 19.380, longitude: -99.162),
                    phone: "55 5555 1234", stars: 5.0, reviewCount: 203, priceLevel: "$$$",
                    isAssociated: true, isAvailable: true, isOpen: true, openHours: "24 horas",
                    distanceKm: 2.1, services: ["Consulta","Cirugía","Diagnóstico por imagen","Urgencias"],
                    acceptedAnimals: ["🐶 Perros","🐱 Gatos","🐰 Conejos","🦜 Aves","🐠 Pez"]),
    ]
}

// MARK: - PetFriendlyPlace

struct PetFriendlyPlace: Identifiable {
    var id = UUID()
    var name: String
    var type: PlaceType
    var address: String
    var coordinate: CLLocationCoordinate2D
    var stars: Double
    var distanceKm: Double
    var acceptedAnimals: [Pet.PetSpecies]
    var phone: String
    var openHours: String

    enum PlaceType: String, CaseIterable {
        case park = "Parque", restaurant = "Restaurante", hotel = "Hotel", cafe = "Café", store = "Tienda"
        var emoji: String {
            switch self { case .park: "🌳"; case .restaurant: "🍽️"; case .hotel: "🏨"; case .cafe: "☕"; case .store: "🛍️" }
        }
    }

    static let sampleData: [PetFriendlyPlace] = [
        PetFriendlyPlace(name: "Parque Mascotas CDMX", type: .park, address: "Bosque de Chapultepec",
                         coordinate: CLLocationCoordinate2D(latitude: 19.420, longitude: -99.190),
                         stars: 5.0, distanceKm: 0.5, acceptedAnimals: [.dog,.cat,.rabbit], phone: "55 0000 0000", openHours: "6am – 9pm"),
        PetFriendlyPlace(name: "Café Patitas", type: .cafe, address: "Calle Ámsterdam 123, Condesa",
                         coordinate: CLLocationCoordinate2D(latitude: 19.413, longitude: -99.172),
                         stars: 4.0, distanceKm: 1.2, acceptedAnimals: [.dog], phone: "55 1111 2222", openHours: "8am – 8pm"),
        PetFriendlyPlace(name: "Hotel Pet Paradise", type: .hotel, address: "Av. Reforma 500",
                         coordinate: CLLocationCoordinate2D(latitude: 19.430, longitude: -99.155),
                         stars: 5.0, distanceKm: 2.8, acceptedAnimals: [.dog,.cat], phone: "55 3333 4444", openHours: "Recepción 24h"),
        PetFriendlyPlace(name: "El Asador Pet Friendly", type: .restaurant, address: "Calle Michoacán 67",
                         coordinate: CLLocationCoordinate2D(latitude: 19.415, longitude: -99.168),
                         stars: 4.0, distanceKm: 1.8, acceptedAnimals: [.dog], phone: "55 5566 7788", openHours: "1pm – 11pm"),
    ]
}

// MARK: - PetStore (model for store view)

struct PetShop: Identifiable {
    var id = UUID()
    var name: String
    var type: String
    var address: String
    var distanceKm: Double
    var isOpen: Bool
    var phone: String
    var products: [String]
    var emoji: String

    static let sampleData: [PetShop] = [
        PetShop(name: "PetShop Centro", type: "Tienda completa", address: "Av. Insurgentes 456",
                distanceKm: 0.9, isOpen: true, phone: "55 1234 5678",
                products: ["Comida","Juguetes","Accesorios","Ropa"], emoji: "🐾"),
        PetShop(name: "NutriMascota", type: "Especialista en alimentos", address: "Calle Sonora 89",
                distanceKm: 1.5, isOpen: true, phone: "55 9876 5432",
                products: ["Comida premium","Suplementos","Vitaminas"], emoji: "🦴"),
        PetShop(name: "ToyPets MX", type: "Juguetes y entretenimiento", address: "Av. Coyoacán 234",
                distanceKm: 2.2, isOpen: false, phone: "55 5555 0000",
                products: ["Juguetes","Camas","Ropa","Accesorios"], emoji: "🎾"),
    ]
}

// MARK: - ChatMessage

struct ChatMessage: Identifiable {
    var id = UUID()
    var content: String
    var isUser: Bool
    var timestamp: Date = Date()
}
