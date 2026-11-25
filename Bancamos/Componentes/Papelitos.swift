import SwiftUI

/// Los papelitos de la celebración (el `data-papelitos` del diseño), que caen despacio una vez.
struct Papelitos: View {
    var cantidad = 46
    var animar = true
    @State private var inicio = Date()

    private struct Papel {
        let x: CGFloat, y0: CGFloat, w: CGFloat, h: CGFloat, giro: Double, vel: CGFloat, color: Color, oscila: CGFloat
    }

    private var papeles: [Papel] {
        var s: UInt64 = 11
        func r() -> CGFloat { s = (s &* 9301 &+ 49297) % 233280; return CGFloat(s) / 233280 }
        return (0..<cantidad).map { i in
            Papel(x: r(), y0: r() * 1.1 - 0.15, w: 6 + r() * 8, h: 10 + r() * 10, giro: Double(r() * 360), vel: 0.04 + r() * 0.08,
                  color: Color.papelitos[i % Color.papelitos.count].opacity(0.55 + r() * 0.45), oscila: r() * 16)
        }
    }

    var body: some View {
        let lista = papeles
        TimelineView(.animation(paused: !animar)) { tl in
            let t = animar ? CGFloat(tl.date.timeIntervalSince(inicio)) : 0
            Canvas { ctx, size in
                for p in lista {
                    var y = (p.y0 + p.vel * t).truncatingRemainder(dividingBy: 1.15)
                    if y < -0.1 { y += 1.15 }
                    let x = p.x * size.width + sin(Double(t) * 1.3 + p.giro) * p.oscila
                    var c = ctx
                    c.translateBy(x: x, y: y * size.height)
                    c.rotate(by: .degrees(p.giro + Double(t) * 40))
                    c.fill(Path(roundedRect: CGRect(x: -p.w / 2, y: -p.h / 2, width: p.w, height: p.h), cornerRadius: 2), with: .color(p.color))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
