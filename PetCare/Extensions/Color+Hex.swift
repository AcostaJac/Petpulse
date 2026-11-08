import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

extension Color {
    static let primary   = Color(hex: "1D9E75")
    static let primaryLight = Color(hex: "E1F5EE")
    static let coral     = Color(hex: "D85A30")
    static let coralLight = Color(hex: "FAECE7")
    static let gold      = Color(hex: "EF9F27")
    static let goldLight = Color(hex: "FAEEDA")
    static let blue      = Color(hex: "185FA5")
    static let blueLight = Color(hex: "E6F1FB")
    static let green     = Color(hex: "3B6D11")
    static let greenLight = Color(hex: "EAF3DE")
    static let bgPage    = Color(hex: "F7F8FA")
    static let cardBorder = Color(hex: "EBEBEB")
    static let textMuted = Color(hex: "888888")
    static let textHint  = Color(hex: "BBBBBB")
}
