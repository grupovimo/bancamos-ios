import SwiftUI

/// Íconos de Bancamos: trazo redondo de 1,8 en un viewBox de 24 (los `<symbol>` de pantallas/app.html y los
/// que se sumaron con la misma mano). Lo genérico del sistema (ajustes, QR) va con SF Symbols.
enum Icono: String, CaseIterable {
    case casa, gente, mas, bolsa, puntos, compartir, flecha, segura, candado, abierto, tilde, cruz, atras, der, abajo,
         corazon, corazonLleno, mensaje, grafico, plata, campana, lupa, pin, foto, audio, texto, reloj, cal, bandera,
         estrella, capas, copiar, lapiz, ojo, pausa, play, descarga, salir, enviar, link, recibo, chispa, mp, filtro,
         basura, sube, persona, mano

    fileprivate enum Elemento {
        case trazo(String)
        case relleno(String)
        case circulo(CGFloat, CGFloat, CGFloat)
        case circuloLleno(CGFloat, CGFloat, CGFloat)
        case rect(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
    }

    fileprivate var elementos: [Elemento] {
        switch self {
        case .casa: return [.trazo("M4 11l8-7 8 7v8a1 1 0 0 1-1 1h-4v-6h-6v6H5a1 1 0 0 1-1-1z")]
        case .gente: return [.circulo(9, 8, 3.2), .trazo("M3 19c.6-3.2 3-5 6-5s5.4 1.8 6 5"), .circulo(17, 9, 2.4), .trazo("M16.5 14c2.4 0 4 1.5 4.5 4")]
        case .mas: return [.trazo("M12 5v14M5 12h14")]
        case .bolsa: return [.trazo("M5 8h14l-1 12H6z"), .trazo("M9 8V6a3 3 0 0 1 6 0v2")]
        case .puntos: return [.circuloLleno(5, 12, 1.5), .circuloLleno(12, 12, 1.5), .circuloLleno(19, 12, 1.5)]
        case .compartir: return [.trazo("M12 15V4M8 8l4-4 4 4"), .trazo("M6 12v7h12v-7")]
        case .flecha: return [.trazo("M4 12h15M14 7l5 5-5 5")]
        case .segura: return [.trazo("M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z"), .trazo("M9 12l2 2 4-4")]
        case .candado: return [.rect(5, 11, 14, 10, 2), .trazo("M8 11V8a4 4 0 0 1 8 0v3")]
        case .abierto: return [.rect(5, 11, 14, 10, 2), .trazo("M8 11V8a4 4 0 0 1 7.6-1.7")]
        case .tilde: return [.trazo("M5 12.5l4.5 4.5L19 7.5")]
        case .cruz: return [.trazo("M7 7l10 10M17 7L7 17")]
        case .atras: return [.trazo("M15 18l-6-6 6-6")]
        case .der: return [.trazo("M9 6l6 6-6 6")]
        case .abajo: return [.trazo("M6 9l6 6 6-6")]
        case .corazon: return [.trazo("M12 20s-7.5-4.6-7.5-10.2A4.3 4.3 0 0 1 12 7.2a4.3 4.3 0 0 1 7.5 2.6C19.5 15.4 12 20 12 20z")]
        case .corazonLleno: return [.relleno("M12 20s-7.5-4.6-7.5-10.2A4.3 4.3 0 0 1 12 7.2a4.3 4.3 0 0 1 7.5 2.6C19.5 15.4 12 20 12 20z")]
        case .mensaje: return [.trazo("M4 6.5A2.5 2.5 0 0 1 6.5 4h11A2.5 2.5 0 0 1 20 6.5v8a2.5 2.5 0 0 1-2.5 2.5H10l-4.5 3.5V17h0A1.5 1.5 0 0 1 4 15.5z")]
        case .grafico: return [.trazo("M4 20h16"), .trazo("M7 16v-4M12 16V7M17 16v-6")]
        case .plata: return [.rect(3, 6, 18, 12.5, 2.5), .circulo(12, 12.25, 2.75), .trazo("M6.5 9.5v.01M17.5 15v.01")]
        case .campana: return [.trazo("M6 16.5V11a6 6 0 0 1 12 0v5.5l1.5 2h-15z"), .trazo("M10 20.5a2.2 2.2 0 0 0 4 0")]
        case .lupa: return [.circulo(11, 11, 6.5), .trazo("M16 16l4 4")]
        case .pin: return [.trazo("M12 21s-6.5-5.7-6.5-11a6.5 6.5 0 0 1 13 0c0 5.3-6.5 11-6.5 11z"), .circulo(12, 10, 2.3)]
        case .foto: return [.rect(3.5, 5, 17, 14, 2.5), .circulo(9, 10, 1.8), .trazo("M20.5 15.5l-4.5-4.5-8.5 8")]
        case .audio: return [.rect(9, 3.5, 6, 11, 3), .trazo("M6 11.5a6 6 0 0 0 12 0M12 17.5v3")]
        case .texto: return [.trazo("M5 6.5h14M5 11h14M5 15.5h9")]
        case .reloj: return [.circulo(12, 12, 8.5), .trazo("M12 7.5V12l3 2")]
        case .cal: return [.rect(3.5, 5, 17, 15.5, 2.5), .trazo("M3.5 9.5h17M8 3v4M16 3v4")]
        case .bandera: return [.trazo("M6 21V4"), .trazo("M6 4.5h11.5l-2.3 4 2.3 4H6")]
        case .estrella: return [.trazo("M12 3.3l2.6 5.4 5.9.8-4.3 4.1 1 5.9L12 16.7l-5.2 2.8 1-5.9-4.3-4.1 5.9-.8z")]
        case .capas: return [.trazo("M12 4l8.5 4.5L12 13 3.5 8.5z"), .trazo("M3.5 12.5L12 17l8.5-4.5"), .trazo("M3.5 16.5L12 21l8.5-4.5")]
        case .copiar: return [.rect(8.5, 8.5, 12, 12, 2.5), .trazo("M15.5 8.5V6a2.5 2.5 0 0 0-2.5-2.5H6A2.5 2.5 0 0 0 3.5 6v7A2.5 2.5 0 0 0 6 15.5h2.5")]
        case .lapiz: return [.trazo("M4 20l1-4.5L15.5 5a2.1 2.1 0 0 1 3 3L8 18.5z"), .trazo("M13.5 7l3 3")]
        case .ojo: return [.trazo("M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"), .circulo(12, 12, 3)]
        case .pausa: return [.trazo("M9 6v12M15 6v12")]
        case .play: return [.relleno("M8 5.5v13l10.5-6.5z")]
        case .descarga: return [.trazo("M12 4v11M8 11l4 4 4-4"), .trazo("M5 19h14")]
        case .salir: return [.trazo("M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4"), .trazo("M10 8l-4 4 4 4M6 12h10")]
        case .enviar: return [.trazo("M20.5 3.5L10 14M20.5 3.5l-6.5 17-4-6.5-6.5-4z")]
        case .link: return [.trazo("M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1"), .trazo("M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1")]
        case .recibo: return [.trazo("M6 3.5h12v17l-2-1.3-2 1.3-2-1.3-2 1.3-2-1.3-2 1.3z"), .trazo("M9 8h6M9 11.5h6M9 15h3.5")]
        case .chispa: return [.trazo("M12 3v4M12 17v4M3 12h4M17 12h4M5.6 5.6l2.8 2.8M15.6 15.6l2.8 2.8M5.6 18.4l2.8-2.8M15.6 8.4l2.8-2.8")]
        case .mp: return [.relleno("M11.115 16.479a.93.927 0 0 1-.939-.886c-.002-.042-.006-.155-.103-.155-.04 0-.074.023-.113.059-.112.103-.254.206-.46.206a.816.814 0 0 1-.305-.066c-.535-.214-.542-.578-.521-.725.006-.038.007-.08-.02-.11l-.032-.03h-.034c-.027 0-.055.012-.093.039a.788.786 0 0 1-.454.16.7.699 0 0 1-.253-.05c-.708-.27-.65-.928-.617-1.126.005-.041-.005-.072-.03-.092l-.05-.04-.047.043a.728.726 0 0 1-.505.203.73.728 0 0 1-.732-.725c0-.4.328-.722.732-.722.364 0 .675.27.721.63l.026.195.11-.165c.01-.018.307-.46.852-.46.102 0 .21.016.316.05.434.13.508.52.519.68.008.094.075.1.09.1.037 0 .064-.024.083-.045a.746.744 0 0 1 .54-.225c.128 0 .263.03.402.09.69.293.379 1.158.374 1.167-.058.144-.061.207-.005.244l.027.013h.02c.03 0 .07-.014.134-.035.093-.032.235-.08.367-.08a.944.942 0 0 1 .94.93.936.934 0 0 1-.94.928zm7.302-4.171c-1.138-.98-3.768-3.24-4.481-3.77-.406-.302-.685-.462-.928-.533a1.559 1.554 0 0 0-.456-.07c-.182 0-.376.032-.58.095-.46.145-.918.505-1.362.854l-.023.018c-.414.324-.84.66-1.164.73a1.986 1.98 0 0 1-.43.049c-.362 0-.687-.104-.81-.258-.02-.025-.007-.066.04-.125l.008-.008 1-1.067c.783-.774 1.525-1.506 3.23-1.545h.085c1.062 0 2.12.469 2.24.524a7.03 7.03 0 0 0 3.056.724c1.076 0 2.188-.263 3.354-.795a9.135 9.11 0 0 0-.405-.317c-1.025.44-2.003.66-2.946.66-.962 0-1.925-.229-2.858-.68-.05-.022-1.22-.567-2.44-.57-.032 0-.065 0-.096.002-1.434.033-2.24.536-2.782.976-.528.013-.982.138-1.388.25-.361.1-.673.186-.979.185-.125 0-.35-.01-.37-.012-.35-.01-2.115-.437-3.518-.962-.143.1-.28.203-.415.31 1.466.593 3.25 1.053 3.812 1.089.157.01.323.027.491.027.372 0 .744-.103 1.104-.203.213-.059.446-.123.692-.17l-.196.194-1.017 1.087c-.08.08-.254.294-.14.557a.705.703 0 0 0 .268.292c.243.162.677.27 1.08.271.152 0 .297-.015.43-.044.427-.095.874-.448 1.349-.82.377-.296.913-.672 1.323-.782a1.494 1.49 0 0 1 .37-.05.611.61 0 0 1 .095.005c.27.034.533.125 1.003.472.835.62 4.531 3.815 4.566 3.846.002.002.238.203.22.537-.007.186-.11.352-.294.466a.902.9 0 0 1-.484.15.804.802 0 0 1-.428-.124c-.014-.01-1.28-1.157-1.746-1.543-.074-.06-.146-.115-.22-.115a.122.122 0 0 0-.096.045c-.073.09.01.212.105.294l1.48 1.47c.002 0 .184.17.204.395.012.244-.106.447-.35.606a.957.955 0 0 1-.526.171.766.764 0 0 1-.42-.127l-.214-.206a21.035 20.978 0 0 0-1.08-1.009c-.072-.058-.148-.112-.221-.112a.127.127 0 0 0-.094.038c-.033.037-.056.103.028.212a.698.696 0 0 0 .075.083l1.078 1.198c.01.01.222.26.024.511l-.038.048a1.18 1.178 0 0 1-.1.096c-.184.15-.43.164-.527.164a.8.798 0 0 1-.147-.012c-.106-.018-.178-.048-.212-.089l-.013-.013c-.06-.06-.602-.609-1.054-.98-.059-.05-.133-.11-.21-.11a.128.128 0 0 0-.096.042c-.09.096.044.24.1.293l.92 1.003a.204.204 0 0 1-.033.062c-.033.044-.144.155-.479.196a.91.907 0 0 1-.122.007c-.345 0-.712-.164-.902-.264a1.343 1.34 0 0 0 .13-.576 1.368 1.365 0 0 0-1.42-1.357c.024-.342-.025-.99-.697-1.274a1.455 1.452 0 0 0-.575-.125c-.146 0-.287.025-.42.075a1.153 1.15 0 0 0-.671-.564 1.52 1.515 0 0 0-.494-.085c-.28 0-.537.08-.767.242a1.168 1.165 0 0 0-.903-.43 1.173 1.17 0 0 0-.82.335c-.287-.217-1.425-.93-4.467-1.613a17.39 17.344 0 0 1-.692-.189 4.822 4.82 0 0 0-.077.494l.67.157c3.108.682 4.136 1.391 4.309 1.525a1.145 1.142 0 0 0-.09.442 1.16 1.158 0 0 0 1.378 1.132c.096.467.406.821.879 1.003a1.165 1.162 0 0 0 .415.08c.09 0 .179-.012.266-.034.086.22.282.493.722.668a1.233 1.23 0 0 0 .457.094c.122 0 .241-.022.355-.063a1.373 1.37 0 0 0 1.269.841c.37.002.726-.147.985-.41.221.121.688.341 1.163.341.06 0 .118-.002.175-.01.47-.059.689-.24.789-.382a.571.57 0 0 0 .048-.078c.11.032.234.058.373.058.255 0 .501-.086.75-.265.244-.174.418-.424.444-.637v-.01c.083.017.167.026.251.026.265 0 .527-.082.773-.242.48-.31.562-.715.554-.98a1.28 1.279 0 0 0 .978-.194 1.04 1.04 0 0 0 .502-.808 1.088 1.085 0 0 0-.16-.653c.804-.342 2.636-1.003 4.795-1.483a4.734 4.721 0 0 0-.067-.492 27.742 27.667 0 0 0-5.049 1.62zm5.123-.763c0 4.027-5.166 7.293-11.537 7.293-6.372 0-11.538-3.266-11.538-7.293 0-4.028 5.165-7.293 11.539-7.293 6.371 0 11.537 3.265 11.537 7.293zm.46.004c0-4.272-5.374-7.755-12-7.755S.002 7.277.002 11.55L0 12.004c0 4.533 4.695 8.203 11.999 8.203 7.347 0 12-3.67 12-8.204z")]
        case .filtro: return [.trazo("M4 6h16M7 12h10M10 18h4")]
        case .basura: return [.trazo("M4.5 7h15M9.5 7V4.5h5V7M6.5 7l1 13h9l1-13")]
        case .sube: return [.trazo("M4 16.5l5.5-5.5 4 4 6.5-6.5"), .trazo("M15 8.5h5v5")]
        case .persona: return [.circulo(12, 8, 3.8), .trazo("M4.5 20.5c.8-4 3.8-6 7.5-6s6.7 2 7.5 6")]
        case .mano: return [.trazo("M8 13V5.5a1.5 1.5 0 0 1 3 0V11M11 10V4.5a1.5 1.5 0 0 1 3 0V11M14 10.5V6a1.5 1.5 0 0 1 3 0v7.5c0 4-2.5 7-6.5 7-2.5 0-4-1.2-5.5-3.5L3.3 14a1.5 1.5 0 0 1 2.4-1.8L8 15")]
        }
    }

    /// Partes trazadas y rellenas, en coordenadas del viewBox (24×24). Se calculan una sola vez.
    fileprivate var partes: (trazo: Path, relleno: Path) {
        Icono.candadoCache.lock(); defer { Icono.candadoCache.unlock() }
        if let p = Icono.cachePartes[self] { return p }
        var t = Path(), r = Path()
        for e in elementos {
            switch e {
            case .trazo(let d): t.addPath(SVGPath.path(d))
            case .relleno(let d): r.addPath(SVGPath.path(d))
            case .circulo(let x, let y, let rr): t.addEllipse(in: CGRect(x: x - rr, y: y - rr, width: rr * 2, height: rr * 2))
            case .circuloLleno(let x, let y, let rr): r.addEllipse(in: CGRect(x: x - rr, y: y - rr, width: rr * 2, height: rr * 2))
            case .rect(let x, let y, let w, let h, let rx):
                t.addRoundedRect(in: CGRect(x: x, y: y, width: w, height: h), cornerSize: CGSize(width: rx, height: rx))
            }
        }
        Icono.cachePartes[self] = (t, r)
        return (t, r)
    }
    nonisolated(unsafe) private static var cachePartes: [Icono: (trazo: Path, relleno: Path)] = [:]
    private static let candadoCache = NSLock()
}

/// Dibuja un ícono a 24 (navegación), 20 (botones) o 16 (junto a texto), con el grosor del CSS (1,8 · 2 · 2,2).
struct IconoVista: View {
    let icono: Icono
    var tamano: CGFloat = 24
    var grosor: CGFloat? = nil

    init(_ icono: Icono, tamano: CGFloat = 24, grosor: CGFloat? = nil) {
        self.icono = icono; self.tamano = tamano; self.grosor = grosor
    }

    var body: some View {
        let g = grosor ?? (tamano <= 16 ? 2.2 : tamano <= 20 ? 2 : 1.8)
        let partes = icono.partes
        Canvas { ctx, size in
            let s = size.width / 24
            let tr = CGAffineTransform(scaleX: s, y: s)
            ctx.stroke(partes.trazo.applying(tr), with: .foreground,
                       style: StrokeStyle(lineWidth: g * s, lineCap: .round, lineJoin: .round))
            ctx.fill(partes.relleno.applying(tr), with: .foreground)
        }
        .frame(width: tamano, height: tamano)
        .accessibilityHidden(true)
    }
}

/// Lector mínimo de `d` de SVG (M L H V C S Q T A Z, absolutos y relativos, con repetición implícita).
enum SVGPath {
    static func path(_ d: String) -> Path {
        var p = Path()
        var s = Escaner(Array(d.utf8))
        var actual = CGPoint.zero, inicio = CGPoint.zero
        var ultimoControl: CGPoint? = nil
        var comando: UInt8 = 0
        while true {
            s.saltarSeparadores()
            guard let c = s.mirar() else { break }
            if Escaner.esLetra(c) { comando = c; s.i += 1 } else if comando == 0 { break }
            let rel = comando >= 97
            let base = rel ? actual : .zero
            switch comando | 0x20 { // en minúscula
            case UInt8(ascii: "m"):
                guard let x = s.numero(), let y = s.numero() else { return p }
                actual = CGPoint(x: base.x + x, y: base.y + y); inicio = actual
                p.move(to: actual)
                comando = rel ? UInt8(ascii: "l") : UInt8(ascii: "L") // pares siguientes: lineto
                ultimoControl = nil
            case UInt8(ascii: "l"):
                guard let x = s.numero(), let y = s.numero() else { return p }
                actual = CGPoint(x: base.x + x, y: base.y + y); p.addLine(to: actual); ultimoControl = nil
            case UInt8(ascii: "h"):
                guard let x = s.numero() else { return p }
                actual = CGPoint(x: (rel ? actual.x : 0) + x, y: actual.y); p.addLine(to: actual); ultimoControl = nil
            case UInt8(ascii: "v"):
                guard let y = s.numero() else { return p }
                actual = CGPoint(x: actual.x, y: (rel ? actual.y : 0) + y); p.addLine(to: actual); ultimoControl = nil
            case UInt8(ascii: "c"):
                guard let x1 = s.numero(), let y1 = s.numero(), let x2 = s.numero(), let y2 = s.numero(),
                      let x = s.numero(), let y = s.numero() else { return p }
                let c1 = CGPoint(x: base.x + x1, y: base.y + y1), c2 = CGPoint(x: base.x + x2, y: base.y + y2)
                actual = CGPoint(x: base.x + x, y: base.y + y)
                p.addCurve(to: actual, control1: c1, control2: c2); ultimoControl = c2
            case UInt8(ascii: "s"):
                guard let x2 = s.numero(), let y2 = s.numero(), let x = s.numero(), let y = s.numero() else { return p }
                let c1 = ultimoControl.map { CGPoint(x: 2 * actual.x - $0.x, y: 2 * actual.y - $0.y) } ?? actual
                let c2 = CGPoint(x: base.x + x2, y: base.y + y2)
                actual = CGPoint(x: base.x + x, y: base.y + y)
                p.addCurve(to: actual, control1: c1, control2: c2); ultimoControl = c2
            case UInt8(ascii: "q"):
                guard let x1 = s.numero(), let y1 = s.numero(), let x = s.numero(), let y = s.numero() else { return p }
                let c = CGPoint(x: base.x + x1, y: base.y + y1)
                actual = CGPoint(x: base.x + x, y: base.y + y)
                p.addQuadCurve(to: actual, control: c); ultimoControl = c
            case UInt8(ascii: "t"):
                guard let x = s.numero(), let y = s.numero() else { return p }
                let c = ultimoControl.map { CGPoint(x: 2 * actual.x - $0.x, y: 2 * actual.y - $0.y) } ?? actual
                actual = CGPoint(x: base.x + x, y: base.y + y)
                p.addQuadCurve(to: actual, control: c); ultimoControl = c
            case UInt8(ascii: "a"):
                guard let rx = s.numero(), let ry = s.numero(), let rot = s.numero(),
                      let grande = s.bandera(), let barrido = s.bandera(),
                      let x = s.numero(), let y = s.numero() else { return p }
                let fin = CGPoint(x: base.x + x, y: base.y + y)
                arco(&p, desde: actual, hasta: fin, rx: rx, ry: ry, rotacion: rot, grande: grande, barrido: barrido)
                actual = fin; ultimoControl = nil
            case UInt8(ascii: "z"):
                p.closeSubpath(); actual = inicio; ultimoControl = nil
                comando = 0
                continue
            default:
                return p
            }
        }
        return p
    }

    /// Arco elíptico de SVG pasado a curvas de Bézier (parametrización por centro, W3C F.6).
    private static func arco(_ p: inout Path, desde p0: CGPoint, hasta p1: CGPoint, rx rx0: CGFloat, ry ry0: CGFloat,
                             rotacion: CGFloat, grande: Bool, barrido: Bool) {
        var rx = abs(rx0), ry = abs(ry0)
        if rx == 0 || ry == 0 || p0 == p1 { p.addLine(to: p1); return }
        let phi = rotacion * .pi / 180, cp = cos(phi), sp = sin(phi)
        let dx = (p0.x - p1.x) / 2, dy = (p0.y - p1.y) / 2
        let x1 = cp * dx + sp * dy, y1 = -sp * dx + cp * dy
        let lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry)
        if lambda > 1 { rx *= sqrt(lambda); ry *= sqrt(lambda) }
        let num = rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1
        let den = rx * rx * y1 * y1 + ry * ry * x1 * x1
        var coef = sqrt(max(0, num / den))
        if grande == barrido { coef = -coef }
        let cxp = coef * rx * y1 / ry, cyp = -coef * ry * x1 / rx
        let cx = cp * cxp - sp * cyp + (p0.x + p1.x) / 2
        let cy = sp * cxp + cp * cyp + (p0.y + p1.y) / 2
        func angulo(_ ux: CGFloat, _ uy: CGFloat, _ vx: CGFloat, _ vy: CGFloat) -> CGFloat {
            let a = atan2(ux * vy - uy * vx, ux * vx + uy * vy)
            return a
        }
        let t1 = angulo(1, 0, (x1 - cxp) / rx, (y1 - cyp) / ry)
        var dt = angulo((x1 - cxp) / rx, (y1 - cyp) / ry, (-x1 - cxp) / rx, (-y1 - cyp) / ry)
        if !barrido && dt > 0 { dt -= 2 * .pi } else if barrido && dt < 0 { dt += 2 * .pi }
        let n = max(1, Int(ceil(abs(dt) / (.pi / 2))))
        let paso = dt / CGFloat(n)
        let k = 4.0 / 3.0 * tan(paso / 4)
        func punto(_ t: CGFloat) -> CGPoint {
            CGPoint(x: cx + rx * cos(t) * cp - ry * sin(t) * sp, y: cy + rx * cos(t) * sp + ry * sin(t) * cp)
        }
        func derivada(_ t: CGFloat) -> CGPoint {
            CGPoint(x: -rx * sin(t) * cp - ry * cos(t) * sp, y: -rx * sin(t) * sp + ry * cos(t) * cp)
        }
        var t = t1
        for _ in 0..<n {
            let a = punto(t), b = punto(t + paso), da = derivada(t), db = derivada(t + paso)
            p.addCurve(to: b, control1: CGPoint(x: a.x + k * da.x, y: a.y + k * da.y),
                       control2: CGPoint(x: b.x - k * db.x, y: b.y - k * db.y))
            t += paso
        }
    }

    private struct Escaner {
        let b: [UInt8]
        var i = 0
        init(_ b: [UInt8]) { self.b = b }
        func mirar() -> UInt8? { i < b.count ? b[i] : nil }
        static func esLetra(_ c: UInt8) -> Bool { (c >= 65 && c <= 90) || (c >= 97 && c <= 122) && c != 101 }
        mutating func saltarSeparadores() {
            while i < b.count, b[i] == 32 || b[i] == 44 || b[i] == 10 || b[i] == 9 || b[i] == 13 { i += 1 }
        }
        mutating func bandera() -> Bool? {
            saltarSeparadores()
            guard i < b.count else { return nil }
            let c = b[i]
            if c == 48 || c == 49 { i += 1; return c == 49 }
            return nil
        }
        mutating func numero() -> CGFloat? {
            saltarSeparadores()
            let ini = i
            if i < b.count, b[i] == 43 || b[i] == 45 { i += 1 }
            var punto = false, digitos = false
            while i < b.count {
                let c = b[i]
                if c >= 48 && c <= 57 { digitos = true; i += 1 }
                else if c == 46 && !punto { punto = true; i += 1 }
                else if (c == 101 || c == 69) && digitos {
                    i += 1
                    if i < b.count, b[i] == 43 || b[i] == 45 { i += 1 }
                } else { break }
            }
            guard digitos, let s = String(bytes: b[ini..<i], encoding: .ascii), let v = Double(s) else { i = ini; return nil }
            return CGFloat(v)
        }
    }
}
