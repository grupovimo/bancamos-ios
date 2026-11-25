import SwiftUI

/// Las otras marcas de Grupo Vimo que se promocionan donde tienen sentido (ya diseñadas en pantallas/app.html).
enum PromoGrupo: String, CaseIterable {
    /// Para la profe de yoga (o cualquiera que da clases).
    case otraMas
    /// Para el que banca: leer a quienes banca.
    case laColumna
    /// Para el creador que escribe sobre su proceso.
    case laColumnaCreador

    /// La imagen del set de promos (propuestas/promos/<marca>-banner.jpg, a 600 px).
    var imagen: String { self == .otraMas ? "promo-otramas" : "promo-lacolumna" }
    var marca: String { self == .otraMas ? "Otra Más" : "La Columna" }
    var cta: String {
        switch self {
        case .otraMas: return "Conocer Otra Más"
        case .laColumna: return "Leer La Columna"
        case .laColumnaCreador: return "Empezar a escribir"
        }
    }
    var titulo: String {
        switch self {
        case .otraMas: return "Llevá tus clases y alumnos con Otra Más"
        case .laColumna: return "Leé a quienes bancás"
        case .laColumnaCreador: return "Contá tu proceso en La Columna"
        }
    }
    var texto: String {
        switch self {
        case .otraMas: return "Rutinas, cuotas y horarios, en una app"
        case .laColumna: return "Notas y columnas en La Columna"
        case .laColumnaCreador: return "Notas largas que se leen y se comparten"
        }
    }
    var link: URL? {
        switch self {
        case .otraMas: return URL(string: "https://otramas.com.ar")
        case .laColumna, .laColumnaCreador: return URL(string: "https://lacolumna.com.ar")
        }
    }
}

/// Promo de otra marca del grupo, como una publicidad de verdad: la imagen (foto y la app), «De Grupo Vimo»,
/// el título y el CTA. Se cierra con la cruz y no vuelve por 30 días. Sin popups.
struct BannerGrupo: View {
    let promo: PromoGrupo
    @AppStorage private var cerrado: Double
    @Environment(\.openURL) private var abrir

    init(_ promo: PromoGrupo) {
        self.promo = promo
        _cerrado = AppStorage(wrappedValue: 0, "banner-\(promo.rawValue)")
    }

    static let dias: TimeInterval = 30 * 24 * 3600
    private var visible: Bool { cerrado == 0 || Date().timeIntervalSince1970 - cerrado > Self.dias }

    var body: some View {
        if visible {
            Button {
                Haptico.seleccion()
                if let url = promo.link { abrir(url) }
            } label: { contenido }
                .buttonStyle(Apretable())
                .accessibilityLabel("De Grupo Vimo: \(promo.titulo). \(promo.cta).")
                .overlay(alignment: .topTrailing) {
                    Button {
                        withAnimation(.snappy) { cerrado = Date().timeIntervalSince1970 }
                    } label: {
                        IconoVista(.cruz, tamano: 14, grosor: 2.4).foregroundStyle(Color.tinta)
                            .frame(width: 30, height: 30).background(.white.opacity(0.92), in: Circle())
                            .frame(width: 44, height: 44)
                    }
                    .padding(4)
                    .accessibilityLabel("Cerrar la promo de \(promo.marca)")
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
        }
    }

    private var contenido: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear.frame(height: 150)
                .overlay { Image(promo.imagen).resizable().scaledToFill() }
                .clipped()
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("DE GRUPO VIMO").tipo(.texto(11, 600)).tracking(0.88).foregroundStyle(Color.gris)
                Text(promo.titulo).tipo(.texto(16, 700)).foregroundStyle(Color.tinta).multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(promo.texto).tipo(.texto(13, 400)).foregroundStyle(Color.gris).multilineTextAlignment(.leading)
                HStack(spacing: 4) {
                    Text(promo.cta).tipo(.texto(14, 700))
                    IconoVista(.flecha, tamano: 16)
                }
                .foregroundStyle(Color.esmeralda700)
                .padding(.top, 6)
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous).strokeBorder(Color.linea, lineWidth: 1.5))
    }
}
