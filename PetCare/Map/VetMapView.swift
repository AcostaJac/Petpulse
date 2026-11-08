import SwiftUI
import MapKit

struct VetMapView: View {
    @EnvironmentObject var petStore: PetStore
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.432, longitude: -99.132),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))
    @State private var selectedVet: Veterinaria?
    @State private var showDetail = false
    @State private var filterAssociated = false
    @State private var filterAvailable = false
    @State private var filterOpen = false

    let vets = Veterinaria.sampleData

    var petSpecies: Pet.PetSpecies? { petStore.selectedPet?.species }

    var filteredVets: [Veterinaria] {
        vets.filter {
            (!filterAssociated || $0.isAssociated) &&
            (!filterAvailable || $0.isAvailable) &&
            (!filterOpen || $0.isOpen)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tu mascota actual
            if let pet = petStore.selectedPet {
                HStack(spacing: 8) {
                    Text(pet.species.emoji).font(.system(size: 16))
                    Text("Mostrando vets para \(pet.name) (\(pet.species.rawValue))")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Badge(text: "Filtrado", color: .green, bgColor: .greenLight)
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Color.primaryLight)
                .overlay(Divider(), alignment: .bottom)
            }

            Map(position: .constant(.region(region))) {
                ForEach(filteredVets) { vet in
                    Annotation(vet.name, coordinate: vet.coordinate) {
                        VetPin(vet: vet, isSelected: selectedVet?.id == vet.id,
                               canAttendPet: canAttend(vet: vet))
                            .onTapGesture { selectedVet = vet; showDetail = true }
                    }
                }
            }
            .frame(height: 220)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    FilterChip(title: "Asociadas",     isOn: $filterAssociated)
                    FilterChip(title: "Disponibles",   isOn: $filterAvailable)
                    FilterChip(title: "Abiertas ahora",isOn: $filterOpen)
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
            }
            .background(Color.white).overlay(Divider(), alignment: .bottom)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredVets) { vet in
                        VetRowCard(vet: vet, canAttendPet: canAttend(vet: vet), petSpecies: petSpecies)
                            .onTapGesture { selectedVet = vet; showDetail = true }
                    }
                }
                .padding(12)
            }
            .background(Color.bgPage)
        }
        .sheet(isPresented: $showDetail) {
            if let v = selectedVet { VetDetailSheet(vet: v).environmentObject(petStore) }
        }
    }

    private func canAttend(vet: Veterinaria) -> Bool {
        guard let species = petSpecies else { return true }
        return vet.acceptedAnimals.contains { $0.contains(species.rawValue) || $0.contains(species.emoji) }
    }
}

// MARK: - VetPin mejorado
struct VetPin: View {
    let vet: Veterinaria
    let isSelected: Bool
    let canAttendPet: Bool

    var pinColor: Color {
        if !canAttendPet { return Color.gray }
        return vet.isAssociated ? Color.primary : Color.gray
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle().fill(pinColor).frame(width: isSelected ? 38 : 30, height: isSelected ? 38 : 30)
                    .shadow(radius: isSelected ? 4 : 2)
                if !canAttendPet {
                    Image(systemName: "xmark").font(.system(size: isSelected ? 14 : 11, weight: .bold)).foregroundColor(.white)
                } else {
                    Image(systemName: "cross.fill").font(.system(size: isSelected ? 14 : 10)).foregroundColor(.white)
                }
            }
            Triangle().fill(pinColor).frame(width: 8, height: 5)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// MARK: - VetRowCard mejorada
struct VetRowCard: View {
    let vet: Veterinaria
    let canAttendPet: Bool
    let petSpecies: Pet.PetSpecies?

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(canAttendPet ? Color.primaryLight : Color(white:0.93))
                            .frame(width: 34, height: 34)
                        Text("🏥").font(.system(size: 16))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vet.name).font(.system(size: 12, weight: .semibold))
                        StarRatingView(rating: vet.stars)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.1f km", vet.distanceKm))
                            .font(.system(size: 11, weight: .medium)).foregroundColor(.coral)
                        Text(vet.priceLevel).font(.system(size: 10)).foregroundColor(.textMuted)
                    }
                }

                // Badge de compatibilidad con la mascota
                if let species = petSpecies {
                    HStack(spacing: 5) {
                        if canAttendPet {
                            Badge(text: "✓ Atiende \(species.rawValue)s", color: .green, bgColor: .greenLight)
                        } else {
                            Badge(text: "✗ No atiende \(species.rawValue)s", color: Color(white:0.5), bgColor: Color(white:0.93))
                        }
                        if vet.isAssociated { Badge(text: "★ Asociada", color: .green, bgColor: .greenLight) }
                        if vet.isAvailable  { Badge(text: "Disponible", color: .green, bgColor: .greenLight) }
                    }
                }

                Text("Atiende: \(vet.acceptedAnimals.joined(separator: ", "))")
                    .font(.system(size: 10)).foregroundColor(.textHint)
            }
        }
        .opacity(canAttendPet ? 1.0 : 0.6)
    }
}

struct FilterChip: View {
    let title: String
    @Binding var isOn: Bool
    var color: Color = .primary
    var body: some View {
        Button { isOn.toggle() } label: {
            Text(title).font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(isOn ? color : Color(white:0.95))
                .foregroundColor(isOn ? .white : Color(white:0.4))
                .cornerRadius(14)
        }
    }
}
