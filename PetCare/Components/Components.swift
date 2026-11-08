import SwiftUI

// MARK: - PrimaryButton

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var color: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon { Text(icon).font(.system(size: 16)) }
                Text(title).font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - OutlineButton

struct OutlineButton: View {
    let title: String
    var color: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.clear)
                .foregroundColor(color)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1))
        }
    }
}

// MARK: - StatCard

struct StatCard: View {
    let value: String
    let label: String
    var valueColor: Color = .primary

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 15, weight: .medium)).foregroundColor(valueColor)
            Text(label).font(.system(size: 10)).foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.bgPage)
        .cornerRadius(10)
    }
}

// MARK: - PetCard (selector chip)

struct PetChip: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(pet.species.emoji).font(.system(size: 14))
                Text(pet.name).font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .white)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(isSelected ? Color.white : Color.white.opacity(0.2))
            .cornerRadius(18)
        }
    }
}

// MARK: - Badge

struct Badge: View {
    let text: String
    let color: Color
    let bgColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(bgColor)
            .cornerRadius(10)
    }
}

// MARK: - SectionHeader

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.textMuted)
            .tracking(0.7)
    }
}

// MARK: - CardView

struct CardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 0.5))
    }
}

// MARK: - StarRatingView

struct StarRatingView: View {
    let rating: Double
    var size: CGFloat = 12

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<5) { i in
                Image(systemName: Double(i) + 0.5 <= rating ? "star.fill" : (Double(i) < rating ? "star.leadinghalf.filled" : "star"))
                    .font(.system(size: size))
                    .foregroundColor(.gold)
            }
        }
    }
}
