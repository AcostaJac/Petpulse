import SwiftUI

// MARK: - Ícono oficial PetCare (usar en UI y como referencia para Assets)
struct AppIconView: View {
    var size: CGFloat = 80
    var cornerRadius: CGFloat? = nil

    private var radius: CGFloat { cornerRadius ?? size * 0.2237 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(Color(hex: "1D9E75"))
                .frame(width: size, height: size)

            // Pata principal
            VStack(spacing: size * 0.04) {
                // Deditos superiores
                HStack(spacing: size * 0.06) {
                    pawDot(w: size*0.15, h: size*0.18)
                    pawDot(w: size*0.18, h: size*0.21)
                    pawDot(w: size*0.18, h: size*0.21)
                    pawDot(w: size*0.15, h: size*0.18)
                }
                // Almohadilla central
                pawDot(w: size*0.38, h: size*0.32)
                    .offset(y: -size*0.02)
            }
            .offset(y: -size*0.04)
            .foregroundColor(.white)

            // Corazón pequeño
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.14))
                .foregroundColor(Color.white.opacity(0.9))
                .offset(x: size*0.22, y: size*0.26)
        }
        .frame(width: size, height: size)
    }

    private func pawDot(w: CGFloat, h: CGFloat) -> some View {
        Ellipse().frame(width: w, height: h)
    }
}

// Versión para splash / pantalla grande
struct AppLogoView: View {
    var size: CGFloat = 90

    var body: some View {
        VStack(spacing: 12) {
            AppIconView(size: size)
                .shadow(color: Color(hex:"1D9E75").opacity(0.3), radius: 16, y: 8)

            Text("PetCare")
                .font(.system(size: size * 0.33, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex:"1D9E75"))
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        VStack(spacing: 30) {
            AppIconView(size: 120)
            AppLogoView(size: 80)
        }
    }
}
