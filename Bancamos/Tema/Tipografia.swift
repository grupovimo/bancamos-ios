import SwiftUI
import UIKit

/// Outfit (variable, wght 100–900; por defecto Thin, así que siempre se pasa el peso).
/// 600 títulos y cifras · 400/500 texto · 600–700 botones.
enum Tipo {
    private static let wght = NSNumber(value: 0x7767_6874) // 'wght'
    nonisolated(unsafe) private static var cache: [String: UIFont] = [:]
    private static let candado = NSLock()

    static func uiFont(_ tamano: CGFloat, _ peso: CGFloat) -> UIFont {
        let clave = "\(tamano)-\(peso)"
        candado.lock(); defer { candado.unlock() }
        if let f = cache[clave] { return f }
        // Se copia la base con la variación: pedirla por nombre reusa la instancia y salen todos iguales.
        let base = CTFontCreateWithName("Outfit-Thin" as CFString, tamano, nil)
        let desc = CTFontDescriptorCreateWithAttributes([kCTFontVariationAttribute: [wght: NSNumber(value: Double(peso))]] as CFDictionary)
        let f = CTFontCreateCopyWithAttributes(base, tamano, nil, desc) as UIFont
        cache[clave] = f
        return f
    }
}

/// Escala del sistema (12/13/14/15/16/17/20/24/28/32/40/48).
enum Estilo {
    /// Título: 600, −0,02 em.
    case titulo(CGFloat)
    /// Cifra: 600, tabular, −0,02 em.
    case numero(CGFloat)
    /// Texto con peso explícito (400 texto, 500 medio, 600 fuerte, 700 botones).
    case texto(CGFloat, CGFloat)
    /// Etiqueta: 12, 700, mayúsculas, 0,08 em.
    case etiqueta

    var tamano: CGFloat {
        switch self {
        case .titulo(let t), .numero(let t), .texto(let t, _): return t
        case .etiqueta: return 12
        }
    }

    /// Cuánto crece con Dynamic Type: el texto sí, los títulos y cifras grandes poco.
    func factor(_ dts: DynamicTypeSize) -> CGFloat {
        let f: CGFloat
        switch dts {
        case .xSmall: f = 0.88
        case .small: f = 0.92
        case .medium: f = 0.96
        case .large: f = 1
        case .xLarge: f = 1.08
        case .xxLarge: f = 1.16
        case .xxxLarge: f = 1.24
        default: f = 1.3
        }
        let tope: CGFloat = tamano >= 28 ? 1.08 : 1.3
        return min(f, tope)
    }

    func uiFont(_ dts: DynamicTypeSize = .large) -> UIFont {
        let t = tamano * factor(dts)
        switch self {
        case .titulo, .numero: return Tipo.uiFont(t, 600)
        case .texto(_, let p): return Tipo.uiFont(t, p)
        case .etiqueta: return Tipo.uiFont(t, 700)
        }
    }

    func font(_ dts: DynamicTypeSize = .large) -> Font {
        if case .numero = self { return Font(uiFont(dts)).monospacedDigit() }
        return Font(uiFont(dts))
    }

    var tracking: CGFloat {
        switch self {
        case .titulo(let t), .numero(let t): return t * -0.02
        case .etiqueta: return 12 * 0.08
        case .texto: return 0
        }
    }
}

private struct ModificadorTipo: ViewModifier {
    let estilo: Estilo
    @Environment(\.dynamicTypeSize) private var dts
    func body(content: Content) -> some View {
        content.font(estilo.font(dts)).tracking(estilo.tracking)
    }
}

extension View {
    func tipo(_ estilo: Estilo) -> some View { modifier(ModificadorTipo(estilo: estilo)) }
}

/// Título de la marca (Outfit 600).
struct Titulo: View {
    let texto: String
    var tamano: CGFloat = 32
    var color: Color = .tinta
    init(_ texto: String, tamano: CGFloat = 32, color: Color = .tinta) {
        self.texto = texto; self.tamano = tamano; self.color = color
    }
    var body: some View {
        Text(texto)
            .tipo(.titulo(tamano))
            .foregroundStyle(color)
            .lineSpacing(-2)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Etiqueta en mayúsculas (12, 700, 0,08 em).
struct Etiqueta: View {
    let texto: String
    var color: Color = .gris
    init(_ texto: String, color: Color = .gris) { self.texto = texto; self.color = color }
    var body: some View {
        Text(texto.uppercased(with: Locale(identifier: "es_AR")))
            .tipo(.etiqueta)
            .foregroundStyle(color)
            .lineLimit(1)
    }
}

/// Texto secundario (14, gris).
struct Sec: View {
    let texto: String
    var tamano: CGFloat = 14
    init(_ texto: String, tamano: CGFloat = 14) { self.texto = texto; self.tamano = tamano }
    var body: some View {
        Text(texto).tipo(.texto(tamano, 400)).foregroundStyle(Color.gris).fixedSize(horizontal: false, vertical: true)
    }
}

/// La barra de navegación del sistema con Outfit (así se vuelve con el gesto y queda nativa).
enum AparienciaNav {
    static func aplicar() {
        let a = UINavigationBarAppearance()
        a.configureWithTransparentBackground()
        a.backgroundColor = .clear
        a.titleTextAttributes = [.font: Tipo.uiFont(17, 600), .foregroundColor: UIColor(Color.tinta)]
        a.largeTitleTextAttributes = [.font: Tipo.uiFont(32, 600), .foregroundColor: UIColor(Color.tinta), .kern: -0.6]
        let boton = UIBarButtonItemAppearance()
        boton.normal.titleTextAttributes = [.font: Tipo.uiFont(16, 600), .foregroundColor: UIColor(Color.tinta)]
        a.buttonAppearance = boton
        a.backButtonAppearance = boton
        let desplazada = UINavigationBarAppearance()
        desplazada.configureWithDefaultBackground()
        desplazada.titleTextAttributes = a.titleTextAttributes
        desplazada.largeTitleTextAttributes = a.largeTitleTextAttributes
        desplazada.buttonAppearance = boton
        desplazada.backButtonAppearance = boton
        let barra = UINavigationBar.appearance()
        barra.standardAppearance = desplazada
        barra.compactAppearance = desplazada
        barra.scrollEdgeAppearance = a
        barra.tintColor = UIColor(Color.tinta)
        UISegmentedControl.appearance().setTitleTextAttributes([.font: Tipo.uiFont(14, 600)], for: .normal)
    }
}
