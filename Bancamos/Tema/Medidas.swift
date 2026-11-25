import SwiftUI

/// Radios del sistema: 20 tarjetas, 12–14 controles, 24 fotos y hojas.
enum Radio {
    static let tarjeta: CGFloat = 20
    static let control: CGFloat = 14
    static let chico: CGFloat = 12
    static let foto: CGFloat = 24
}

/// Grilla de 4. Margen lateral del teléfono: 20.
enum Espacio {
    static let margen: CGFloat = 20
    /// Alto mínimo de lo que se toca.
    static let tactil: CGFloat = 44
    /// Lo que ocupa la barra flotante (64 + 26 de abajo + aire) para que el contenido no quede tapado.
    static let bajoBarra: CGFloat = 110
}

extension View {
    /// --bc-sombra: 0 1px 2px rgb(17 20 24 / .05), 0 10px 28px rgb(17 20 24 / .07)
    func sombra() -> some View {
        self.shadow(color: Color.tinta.opacity(0.05), radius: 1, x: 0, y: 1)
            .shadow(color: Color.tinta.opacity(0.07), radius: 14, x: 0, y: 10)
    }

    /// --bc-sombra-alta: 0 24px 60px rgb(17 20 24 / .16)
    func sombraAlta() -> some View {
        self.shadow(color: Color.tinta.opacity(0.16), radius: 30, x: 0, y: 24)
    }
}
