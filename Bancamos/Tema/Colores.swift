import SwiftUI

/// Paleta de Bancamos (marca/sistema/tokens.css). Limpia, mucho blanco, esmeralda como protagonista.
/// La interfaz es sólo clara.
extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }

    // Esmeralda: el color de la marca.
    /// Barras de progreso, íconos y acentos grandes (≥ 24 pt sobre blanco).
    static let esmeralda = Color(hex: 0x0E9F6E)
    /// Botones con texto blanco y texto verde sobre blanco (5,3:1).
    static let esmeralda700 = Color(hex: 0x0B7A55)
    static let esmeralda900 = Color(hex: 0x064E36)
    static let esmeralda100 = Color(hex: 0xEAF7F1)
    static let esmeralda50 = Color(hex: 0xF4FBF8)

    // Neutros.
    static let fondo = Color(hex: 0xF7F8F7)
    static let linea = Color(hex: 0xE6E9E7)
    /// Texto secundario (5,8:1 sobre blanco).
    static let gris = Color(hex: 0x5F6670)
    static let tinta = Color(hex: 0x111418)

    // Estados.
    static let ok = Color(hex: 0x0B7A55)
    static let ok100 = Color(hex: 0xEAF7F1)
    static let alerta = Color(hex: 0x9A5B00)
    static let alerta100 = Color(hex: 0xFFF1D6)
    static let error = Color(hex: 0xB3261E)
    static let error100 = Color(hex: 0xFCEBEA)

    /// Mercado Pago: sólo en su botón y en su checkout.
    static let mp = Color(hex: 0x009EE3)
    static let mpOscuro = Color(hex: 0x2D3277)

    /// Papelitos de la celebración.
    static let papelitos: [Color] = [.esmeralda, Color(hex: 0xBFE8D6), .tinta, Color(hex: 0x7FD1AE)]
}
