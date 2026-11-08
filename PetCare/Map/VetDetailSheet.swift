import SwiftUI
import MapKit

// MARK: - VetDetailSheet

struct VetDetailSheet: View {
    let vet: Veterinaria
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    // Header
                    CardView {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12).fill(Color.primaryLight).frame(width: 54, height: 54)
                                Text("🏥").font(.system(size: 26))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(vet.name).font(.system(size: 16, weight: .semibold))
                                    if vet.isAssociated {
                                        Badge(text: "✓ Asociada", color: Color.green, bgColor: Color.greenLight)
                                    }
                                }
                                HStack(spacing: 4) {
                                    StarRatingView(rating: vet.stars)
                                    Text("(\(vet.reviewCount) reseñas)")
                                        .font(.system(size: 10)).foregroundColor(.textMuted)
                                }
                            }
                        }
                    }

                    // Association info
                    if vet.isAssociated {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14)).foregroundColor(.primary)
                            Text("Esta veterinaria está asociada porque cumple con los estándares de calidad PetCare: instalaciones certificadas, personal especializado y atención de excelencia.")
                                .font(.system(size: 11)).foregroundColor(Color(hex:"0F6E56"))
                        }
                        .padding(10)
                        .background(Color.primaryLight)
                        .cornerRadius(10)
                    }

                    // Info grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        InfoTile(icon: "📍", label: "Distancia", value: String(format: "%.1f km", vet.distanceKm))
                        InfoTile(icon: "💰", label: "Precio", value: vet.priceLevel == "$" ? "$ Económico" : vet.priceLevel == "$$" ? "$$ Moderado" : "$$$ Premium")
                        InfoTile(icon: "🕐", label: "Horario", value: vet.openHours)
                        InfoTile(icon: "📅", label: "Disponibilidad", value: vet.isAvailable ? "Hoy disponible" : "Sin disponibilidad")
                    }

                    // Accepted animals
                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Atiende a").font(.system(size: 11)).foregroundColor(.textMuted)
                            FlowLayout(spacing: 6) {
                                ForEach(vet.acceptedAnimals, id: \.self) { a in
                                    Text(a)
                                        .font(.system(size: 11))
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(Color(white: 0.96))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }

                    // Services
                    CardView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Servicios").font(.system(size: 11)).foregroundColor(.textMuted)
                                .padding(.bottom, 6)
                            ForEach(vet.services, id: \.self) { s in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark").font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text(s).font(.system(size: 12))
                                }
                                .padding(.vertical, 5)
                                Divider()
                            }
                        }
                    }

                    // Contact buttons
                    HStack(spacing: 8) {
                        Button {
                            if let url = URL(string: "tel://\(vet.phone.replacingOccurrences(of: " ", with: ""))") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack { Image(systemName: "phone.fill"); Text("Llamar") }
                                .font(.system(size: 12, weight: .medium))
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Color.primaryLight).foregroundColor(.primary).cornerRadius(10)
                        }

                        Button {
                            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: vet.coordinate, addressDictionary: nil))
                            mapItem.name = vet.name
                            mapItem.openInMaps()
                        } label: {
                            HStack { Image(systemName: "location.fill"); Text("Cómo llegar") }
                                .font(.system(size: 12, weight: .medium))
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Color.blueLight).foregroundColor(.blue).cornerRadius(10)
                        }
                    }

                    PrimaryButton(title: "Agendar cita") { dismiss() }
                }
                .padding(16)
            }
            .background(Color.bgPage)
            .navigationTitle(vet.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

struct InfoTile: View {
    let icon: String; let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(icon).font(.system(size: 16))
            Text(label).font(.system(size: 10)).foregroundColor(.textMuted)
            Text(value).font(.system(size: 11, weight: .medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10).background(Color.white).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cardBorder, lineWidth: 0.5))
    }
}

// MARK: - PetFriendlyMapView

struct PetFriendlyMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.416, longitude: -99.172),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedType: PetFriendlyPlace.PlaceType? = nil
    @State private var selectedSpecies: Pet.PetSpecies? = nil
    @State private var selectedPlace: PetFriendlyPlace? = nil

    let places = PetFriendlyPlace.sampleData

    var filteredPlaces: [PetFriendlyPlace] {
        places.filter {
            (selectedType == nil || $0.type == selectedType) &&
            (selectedSpecies == nil || $0.acceptedAnimals.contains(selectedSpecies!))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Species filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    Button {
                        selectedSpecies = nil
                    } label: {
                        Text("🐾 Todos")
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(selectedSpecies == nil ? Color.green : Color(white: 0.95))
                            .foregroundColor(selectedSpecies == nil ? .white : Color(white: 0.4))
                            .cornerRadius(14)
                    }
                    ForEach(Pet.PetSpecies.allCases.filter { $0 != .fish && $0 != .other }, id: \.self) { s in
                        Button { selectedSpecies = selectedSpecies == s ? nil : s } label: {
                            Text("\(s.emoji) \(s.rawValue)")
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(selectedSpecies == s ? Color.green : Color(white: 0.95))
                                .foregroundColor(selectedSpecies == s ? .white : Color(white: 0.4))
                                .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
            }
            .background(Color.white)
            .overlay(Divider(), alignment: .bottom)

            // Map
            Map(position: .constant(.region(region))) {
                ForEach(filteredPlaces) { place in
                    Annotation(place.name, coordinate: place.coordinate) {
                        Button { selectedPlace = place } label: {
                            ZStack {
                                Circle().fill(Color(hex:"3B6D11")).frame(width: 30, height: 30)
                                    .shadow(radius: 2)
                                Text("🐾").font(.system(size: 12))
                            }
                        }
                    }
                }
            }
            .frame(height: 200)

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    Button { selectedType = nil } label: {
                        Text("Todos")
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(selectedType == nil ? Color(hex:"3B6D11") : Color(white: 0.95))
                            .foregroundColor(selectedType == nil ? .white : Color(white: 0.4))
                            .cornerRadius(14)
                    }
                    ForEach(PetFriendlyPlace.PlaceType.allCases, id: \.self) { t in
                        Button { selectedType = selectedType == t ? nil : t } label: {
                            Text("\(t.emoji) \(t.rawValue)")
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(selectedType == t ? Color(hex:"3B6D11") : Color(white: 0.95))
                                .foregroundColor(selectedType == t ? .white : Color(white: 0.4))
                                .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
            }
            .background(Color.white).overlay(Divider(), alignment: .bottom)

            // Place list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredPlaces) { place in
                        PlaceRowCard(place: place)
                    }
                }
                .padding(12)
            }
            .background(Color.bgPage)
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailSheet(place: place)
        }
    }
}

// MARK: - PlaceRowCard

struct PlaceRowCard: View {
    let place: PetFriendlyPlace

    var body: some View {
        CardView {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color.greenLight).frame(width: 38, height: 38)
                    Text(place.type.emoji).font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name).font(.system(size: 12, weight: .semibold))
                    StarRatingView(rating: place.stars, size: 10)
                    HStack(spacing: 6) {
                        Text("\(place.type.rawValue) · \(String(format: "%.1f", place.distanceKm)) km")
                            .font(.system(size: 10)).foregroundColor(.textMuted)
                        Text(place.acceptedAnimals.map(\.emoji).joined())
                            .font(.system(size: 13))
                    }
                }
                Spacer()
                Text("Ver →").font(.system(size: 11, weight: .medium)).foregroundColor(Color(hex:"3B6D11"))
            }
        }
    }
}

// MARK: - PlaceDetailSheet

struct PlaceDetailSheet: View {
    let place: PetFriendlyPlace
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    CardView {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12).fill(Color.greenLight).frame(width: 54, height: 54)
                                Text(place.type.emoji).font(.system(size: 26))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(place.name).font(.system(size: 16, weight: .semibold))
                                StarRatingView(rating: place.stars)
                                Text(place.type.rawValue).font(.system(size: 11)).foregroundColor(.textMuted)
                            }
                        }
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Animales bienvenidos").font(.system(size: 11)).foregroundColor(.textMuted)
                            HStack(spacing: 8) {
                                ForEach(place.acceptedAnimals, id: \.self) { s in
                                    VStack(spacing: 2) {
                                        Text(s.emoji).font(.system(size: 22))
                                        Text(s.rawValue).font(.system(size: 9)).foregroundColor(.textMuted)
                                    }
                                }
                            }
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        InfoTile(icon: "📍", label: "Distancia", value: String(format: "%.1f km", place.distanceKm))
                        InfoTile(icon: "🕐", label: "Horario", value: place.openHours)
                        InfoTile(icon: "📞", label: "Teléfono", value: place.phone)
                        InfoTile(icon: "📍", label: "Dirección", value: place.address)
                    }

                    HStack(spacing: 8) {
                        Button {
                            if let url = URL(string: "tel://\(place.phone.replacingOccurrences(of: " ", with: ""))") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack { Image(systemName: "phone.fill"); Text("Llamar") }
                                .font(.system(size: 12, weight: .medium))
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Color.greenLight).foregroundColor(Color(hex:"3B6D11")).cornerRadius(10)
                        }
                        Button {
                            let item = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate, addressDictionary: nil))
                            item.name = place.name; item.openInMaps()
                        } label: {
                            HStack { Image(systemName: "location.fill"); Text("Cómo llegar") }
                                .font(.system(size: 12, weight: .medium))
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Color.blueLight).foregroundColor(.blue).cornerRadius(10)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.bgPage)
            .navigationTitle(place.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Cerrar") { dismiss() } } }
        }
    }
}
