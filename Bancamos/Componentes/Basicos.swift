import SwiftUI
import UIKit

// MARK: - Tarjetas

/// Tarjeta blanca con sombra (.card).
struct Tarjeta<Contenido: View>: View {
    var relleno: CGFloat = 0
    var radio: CGFloat = Radio.tarjeta
    @ViewBuilder var contenido: () -> Contenido

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { contenido() }
            .padding(relleno)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: radio, style: .continuous))
            .sombra()
    }
}

/// Tarjeta blanca con borde de 1,5 (.borde): sobre fondo blanco.
struct Borde<Contenido: View>: View {
    var relleno: CGFloat = 0
    var radio: CGFloat = Radio.tarjeta
    var color: Color = .linea
    var ancho: CGFloat = 1.5
    var fondo: Color = .white
    @ViewBuilder var contenido: () -> Contenido

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { contenido() }
            .padding(relleno)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fondo, in: RoundedRectangle(cornerRadius: radio, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radio, style: .continuous).strokeBorder(color, lineWidth: ancho))
    }
}

struct Divisor: View {
    var izquierda: CGFloat = 0
    var body: some View { Rectangle().fill(Color.linea).frame(height: 1).padding(.leading, izquierda) }
}

// MARK: - Imágenes

/// Foto recortada al tamaño que le den, con un punto de foco y un acercamiento (el background-size del CSS).
struct FotoRecortada: View {
    let imagen: Imagen
    var zoom: Double? = nil

    var body: some View {
        GeometryReader { g in
            if let ui = imagen.uiImage {
                let z = CGFloat(zoom ?? 1)
                let escala = max(g.size.width / ui.size.width, g.size.height / ui.size.height) * z
                let w = ui.size.width * escala, h = ui.size.height * escala
                let x = min(0, max(g.size.width - w, g.size.width / 2 - w * imagen.fx))
                let y = min(0, max(g.size.height - h, g.size.height / 2 - h * imagen.fy))
                Image(uiImage: ui)
                    .resizable()
                    .frame(width: w, height: h)
                    .offset(x: x, y: y)
            } else {
                LinearGradient(colors: [.esmeralda100, Color(hex: 0xD5EFE3)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

/// Avatar redondo: la foto (acercada a la cara) o las iniciales en esmeralda suave.
struct Avatar: View {
    var imagen: Imagen?
    var iniciales: String
    var tamano: CGFloat = 40
    var gris = false
    var aro: CGFloat = 0

    var body: some View {
        Group {
            if let imagen, imagen.existe {
                FotoRecortada(imagen: imagen, zoom: imagen.datos != nil ? 1 : imagen.zoom)
            } else {
                Text(iniciales)
                    .font(Estilo.texto(tamano >= 64 ? tamano * 0.34 : tamano * 0.35, 700).font())
                    .foregroundStyle(gris ? Color.gris : Color.esmeralda700)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(gris ? Color.fondo : Color.esmeralda100)
            }
        }
        .frame(width: tamano, height: tamano)
        .clipShape(Circle())
        .overlay { if aro > 0 { Circle().strokeBorder(Color.white, lineWidth: aro) } }
        .accessibilityHidden(true)
    }
}

extension Avatar {
    init(_ c: Creador, tamano: CGFloat = 40, aro: CGFloat = 0) {
        self.init(imagen: c.foto, iniciales: c.iniciales, tamano: tamano, aro: aro)
    }
}

// MARK: - La meta

/// La barra de 12: esmeralda sobre línea, y opcionalmente «lo tuyo» en tinta al final.
struct BarraMeta: View {
    var fraccion: Double
    var vos: Double = 0
    var alto: CGFloat = 12
    var color: Color = .esmeralda
    var pista: Color = .linea

    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            let base = max(0, min(1, fraccion)), extra = max(0, min(1 - base, vos))
            ZStack(alignment: .leading) {
                Capsule().fill(pista)
                if extra > 0 {
                    Capsule().fill(Color.tinta).frame(width: max(alto, w * (base + extra)))
                }
                Capsule().fill(color).frame(width: base > 0 ? max(alto, w * base) : 0)
            }
        }
        .frame(height: alto)
        .accessibilityElement()
        .accessibilityLabel("Avance de la meta")
        .accessibilityValue("\(Int(fraccion * 100)) por ciento")
    }
}

/// La meta como en la página (título, % en chip, cifras y barra).
struct TarjetaMeta: View {
    let meta: Meta
    var vos: Int = 0
    var pie: String?
    var sombra = false

    var body: some View {
        let contenido = VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Text(meta.titulo).tipo(.texto(16, 700)).foregroundStyle(Color.tinta).lineLimit(2)
                Spacer(minLength: 4)
                Chip(texto: "\(min(999, Int(Double(meta.recaudado + vos) / Double(max(meta.objetivo, 1)) * 100))) %", tono: .marca)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(Plata.texto(meta.recaudado + vos)).tipo(.numero(28)).foregroundStyle(Color.tinta)
                    .contentTransition(.numericText(value: Double(meta.recaudado + vos)))
                Spacer(minLength: 4)
                Text("de \(Plata.texto(meta.objetivo))").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
            }
            BarraMeta(fraccion: meta.fraccion, vos: Double(vos) / Double(max(meta.objetivo, 1)))
            if let pie { Text(pie).tipo(.texto(14, 400)).foregroundStyle(Color.gris) }
        }
        .padding(16)
        if sombra { Tarjeta { contenido } } else { Borde { contenido } }
    }
}

// MARK: - Chips

struct Chip: View {
    enum Tono { case marca, ok, alerta, gris, error, oscuro }
    let texto: String
    var tono: Tono = .marca
    var icono: Icono? = nil

    var body: some View {
        HStack(spacing: 5) {
            if let icono { IconoVista(icono, tamano: 13, grosor: 2.4) }
            Text(texto).tipo(.texto(13, 700)).lineLimit(1)
        }
        .foregroundStyle(frente)
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(fondo, in: Capsule())
        .fixedSize()
    }

    private var fondo: Color {
        switch tono {
        case .marca, .ok: return .esmeralda100
        case .alerta: return .alerta100
        case .gris: return .fondo
        case .error: return .error100
        case .oscuro: return .tinta
        }
    }
    private var frente: Color {
        switch tono {
        case .marca, .ok: return .esmeralda700
        case .alerta: return .alerta
        case .gris: return .gris
        case .error: return .error
        case .oscuro: return .white
        }
    }
}

/// Chip que se elige (categorías, filtros, «Quién lo ve»): 40 de alto, tinta cuando está elegido.
struct ChipOpcion: View {
    let titulo: String
    var simbolo: String? = nil
    var elegido: Bool
    var accion: () -> Void

    var body: some View {
        Button {
            Haptico.seleccion()
            accion()
        } label: {
            HStack(spacing: 6) {
                if elegido { IconoVista(.tilde, tamano: 16) }
                else if let simbolo { Image(systemName: simbolo).font(.system(size: 14, weight: .medium)) }
                Text(titulo).tipo(.texto(15, 600)).lineLimit(1)
            }
            .foregroundStyle(elegido ? Color.white : Color.tinta)
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(elegido ? Color.tinta : Color.white, in: Capsule())
            .overlay(Capsule().strokeBorder(elegido ? Color.clear : Color.linea, lineWidth: 1.5))
            .contentShape(Capsule())
        }
        .buttonStyle(Apretable())
        .accessibilityAddTraits(elegido ? .isSelected : [])
    }
}

/// Distribuye chips en renglones (como flex-wrap).
struct Renglones: Layout {
    var espacio: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let ancho = proposal.width ?? 360
        var x: CGFloat = 0, y: CGFloat = 0, alto: CGFloat = 0
        for s in subviews {
            let t = s.sizeThatFits(.unspecified)
            if x > 0 && x + t.width > ancho { x = 0; y += alto + espacio; alto = 0 }
            x += t.width + espacio
            alto = max(alto, t.height)
        }
        return CGSize(width: ancho, height: y + alto)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, alto: CGFloat = 0
        for s in subviews {
            let t = s.sizeThatFits(.unspecified)
            if x > bounds.minX && x + t.width > bounds.maxX { x = bounds.minX; y += alto + espacio; alto = 0 }
            s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(t))
            x += t.width + espacio
            alto = max(alto, t.height)
        }
    }
}

// MARK: - Títulos de sección

struct TituloSeccion: View {
    let texto: String
    var accion: String? = nil
    var arriba: CGFloat = 24
    var alTocar: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(texto).tipo(.titulo(20)).foregroundStyle(Color.tinta).accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            if let accion, let alTocar {
                Button(action: alTocar) {
                    Text(accion).tipo(.texto(14, 700)).foregroundStyle(Color.esmeralda700)
                        .frame(minHeight: 44).contentShape(Rectangle())
                }
                .buttonStyle(Apretable())
            }
        }
        .padding(.top, arriba)
        .padding(.bottom, accion == nil ? 12 : 2)
    }
}

// MARK: - Filas

/// Fila de menú: ícono en círculo, título, bajada y flecha. 56 de alto como mínimo.
struct FilaMenu: View {
    let icono: Icono
    let titulo: String
    var sub: String? = nil
    var badge: Int = 0
    var colorIcono: Color = .esmeralda700
    var fondoIcono: Color = .esmeralda100

    var body: some View {
        HStack(spacing: 12) {
            IconoVista(icono, tamano: 20)
                .foregroundStyle(colorIcono)
                .frame(width: 40, height: 40)
                .background(fondoIcono, in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(titulo).tipo(.texto(16, 600)).foregroundStyle(Color.tinta)
                if let sub { Text(sub).tipo(.texto(13, 400)).foregroundStyle(Color.gris).lineLimit(2) }
            }
            Spacer(minLength: 8)
            if badge > 0 {
                Text("\(badge)").tipo(.texto(13, 700)).foregroundStyle(.white)
                    .padding(.horizontal, 7).frame(minWidth: 24, minHeight: 24)
                    .background(Color.esmeralda700, in: Capsule())
            }
            IconoVista(.der, tamano: 16).foregroundStyle(Color.gris.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
    }
}

/// «Etiqueta ……… valor» de los resúmenes (.lin).
struct FilaDato: View {
    let etiqueta: String
    let valor: String
    var fuerte = true
    var colorValor: Color = .tinta

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(etiqueta).tipo(.texto(15, 400)).foregroundStyle(Color.gris)
            Spacer(minLength: 8)
            Text(valor).tipo(.texto(15, fuerte ? 700 : 500)).foregroundStyle(colorValor).multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

/// Interruptor con título y bajada (el .sw del diseño: tinta cuando está prendido).
struct FilaInterruptor: View {
    let titulo: String
    var sub: String? = nil
    @Binding var valor: Bool

    var body: some View {
        Toggle(isOn: Binding(get: { valor }, set: { v in Haptico.seleccion(); withAnimation(.snappy) { valor = v } })) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo).tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                if let sub { Text(sub).tipo(.texto(13, 400)).foregroundStyle(Color.gris).fixedSize(horizontal: false, vertical: true) }
            }
        }
        .tint(Color.tinta)
        .frame(minHeight: 44)
    }
}

/// Recuadro gris con un escudo: «La plata va directo al Mercado Pago de Ana. Bancamos no la toca.»
struct NotaSegura: View {
    let texto: String
    var icono: Icono = .segura
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconoVista(icono, tamano: 20).foregroundStyle(Color.ok).padding(.top, 1)
            Text(texto).tipo(.texto(14, 400)).foregroundStyle(Color.tinta).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color.fondo, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Campos

/// Campo con etiqueta adentro (.campo), con el borde en tinta cuando tiene foco.
struct Campo: View {
    let etiqueta: String
    @Binding var texto: String
    var placeholder = ""
    var teclado: UIKeyboardType = .default
    var prefijo: String? = nil
    var lineas: Int = 1
    var limite: Int? = nil
    var mayusculas: TextInputAutocapitalization = .sentences
    @FocusState private var foco: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(etiqueta.uppercased(with: Fecha.ar)).tipo(.texto(11, 700)).tracking(0.88).foregroundStyle(Color.gris)
                Spacer()
                if let limite { Text("\(texto.count)/\(limite)").tipo(.texto(12, 500)).foregroundStyle(Color.gris) }
            }
            HStack(spacing: 0) {
                if let prefijo { Text(prefijo).tipo(.texto(17, 500)).foregroundStyle(Color.gris) }
                TextField(placeholder, text: Binding(get: { texto }, set: { v in texto = limite.map { String(v.prefix($0)) } ?? v }),
                          axis: lineas > 1 ? .vertical : .horizontal)
                    .lineLimit(lineas > 1 ? lineas...(lineas + 4) : 1...1)
                    .font(Estilo.texto(17, 600).font())
                    .foregroundStyle(Color.tinta)
                    .keyboardType(teclado)
                    .textInputAutocapitalization(mayusculas)
                    .focused($foco)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .frame(minHeight: 60)
        .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.chico, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radio.chico, style: .continuous).strokeBorder(foco ? Color.tinta : Color.linea, lineWidth: foco ? 2 : 1.5))
        .contentShape(Rectangle())
        .onTapGesture { foco = true }
        .animation(.easeOut(duration: 0.15), value: foco)
    }
}

/// Campo de pesos: guarda un Int y muestra «$12.000».
struct CampoPlata: View {
    let etiqueta: String
    @Binding var monto: Int
    var body: some View {
        Campo(etiqueta: etiqueta, texto: Binding(get: { monto > 0 ? Plata.numero(monto) : "" }, set: { monto = Plata.leer($0) ?? 0 }),
              placeholder: "0", teclado: .numberPad, prefijo: "$")
    }
}

// MARK: - Estados: vacío, carga y error

/// Estado vacío con una acción (nunca una pantalla en blanco).
struct EstadoVacio: View {
    let icono: Icono
    let titulo: String
    let texto: String
    var accion: String? = nil
    var alTocar: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            IconoVista(icono, tamano: 28)
                .foregroundStyle(Color.esmeralda700)
                .frame(width: 64, height: 64)
                .background(Color.esmeralda100, in: Circle())
            Text(titulo).tipo(.titulo(20)).foregroundStyle(Color.tinta).multilineTextAlignment(.center)
            Text(texto).tipo(.texto(15, 400)).foregroundStyle(Color.gris).multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let accion, let alTocar {
                Boton(titulo: accion, variante: .prim, alto: .normal, accion: alTocar).padding(.top, 6)
            }
        }
        .padding(.horizontal, 24).padding(.vertical, 28)
        .frame(maxWidth: .infinity)
    }
}

/// Esqueleto que late mientras carga.
struct Esqueleto: View {
    var alto: CGFloat = 16
    var ancho: CGFloat? = nil
    var radio: CGFloat = 8
    @State private var fase = false

    var body: some View {
        RoundedRectangle(cornerRadius: radio, style: .continuous)
            .fill(Color.linea)
            .frame(width: ancho, height: alto)
            .opacity(fase ? 0.45 : 1)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: fase)
            .onAppear { fase = true }
            .accessibilityHidden(true)
    }
}

/// Error amable con «Probar de nuevo».
struct ErrorAmable: View {
    let texto: String
    var reintentar: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark").font(.system(size: 26, weight: .medium)).foregroundStyle(Color.alerta)
                .frame(width: 64, height: 64).background(Color.alerta100, in: Circle())
            Text("Uy, no cargó").tipo(.titulo(20)).foregroundStyle(Color.tinta)
            Text(texto).tipo(.texto(15, 400)).foregroundStyle(Color.gris).multilineTextAlignment(.center)
            Boton(titulo: "Probar de nuevo", variante: .blanco, alto: .normal, accion: reintentar)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Aviso (toast)

struct AvisoFlotante: View {
    let texto: String
    var body: some View {
        HStack(spacing: 10) {
            IconoVista(.tilde, tamano: 20).foregroundStyle(Color(hex: 0x7FD1AE))
            Text(texto).tipo(.texto(15, 600)).foregroundStyle(.white).multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(minHeight: 48)
        .background(Color.tinta, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.tinta.opacity(0.25), radius: 16, y: 10)
        .padding(.horizontal, 20)
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Volver con el gesto aunque la barra esté oculta

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

extension View {
    /// Para las pestañas apiladas: la que no está elegida no se ve, no se toca y no la lee VoiceOver.
    func visible(_ si: Bool) -> some View {
        self.opacity(si ? 1 : 0).allowsHitTesting(si).accessibilityHidden(!si)
    }
}
