import SwiftUI

/// Se achica un poco al apretar (todo lo tocable).
struct Apretable: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

/// Botones del sistema (.btn): prim (esmeralda), osc (tinta), blanco (con borde), mp (el de Mercado Pago),
/// suave (esmeralda clara) y peligro. Alto 44 · 52 · 56.
struct Boton: View {
    enum Variante { case prim, osc, blanco, mp, suave, peligro }
    enum Alto { case chico, normal, alto }

    let titulo: String
    var icono: Icono? = nil
    var variante: Variante = .prim
    var alto: Alto = .normal
    var ancho = false
    var cargando = false
    var habilitado = true
    var accion: () -> Void

    var body: some View {
        Button {
            guard habilitado, !cargando else { return }
            accion()
        } label: {
            HStack(spacing: 8) {
                if cargando {
                    ProgressView().tint(frente)
                } else {
                    if variante == .mp {
                        IconoVista(.mp, tamano: 28)
                    } else if let icono {
                        IconoVista(icono, tamano: 20)
                    }
                    Text(titulo).tipo(.texto(alto == .chico ? 15 : 16, 700)).lineLimit(1).minimumScaleFactor(0.8)
                }
            }
            .foregroundStyle(frente)
            .padding(.horizontal, alto == .chico ? 14 : 18)
            .frame(maxWidth: ancho ? .infinity : nil)
            .frame(height: altura)
            .background(fondo, in: RoundedRectangle(cornerRadius: Radio.control, style: .continuous))
            .overlay {
                if variante == .blanco {
                    RoundedRectangle(cornerRadius: Radio.control, style: .continuous).strokeBorder(Color.linea, lineWidth: 1.5)
                }
            }
            .opacity(habilitado ? 1 : 0.4)
            .contentShape(RoundedRectangle(cornerRadius: Radio.control))
        }
        .buttonStyle(Apretable())
        .disabled(!habilitado)
        .accessibilityLabel(titulo)
    }

    private var altura: CGFloat {
        switch alto { case .chico: return 44; case .normal: return 52; case .alto: return 56 }
    }
    private var fondo: Color {
        switch variante {
        case .prim: return .esmeralda700
        case .osc: return .tinta
        case .blanco: return .white
        case .mp: return .mp
        case .suave: return .esmeralda100
        case .peligro: return .error100
        }
    }
    private var frente: Color {
        switch variante {
        case .prim, .osc, .mp: return .white
        case .blanco: return .tinta
        case .suave: return .esmeralda700
        case .peligro: return .error
        }
    }
}

/// Botón de texto verde (Ver todo, Editar…) con área de 44.
struct BotonTexto: View {
    let titulo: String
    var color: Color = .esmeralda700
    var accion: () -> Void
    var body: some View {
        Button(action: accion) {
            Text(titulo).tipo(.texto(15, 700)).foregroundStyle(color)
                .frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
        }
        .buttonStyle(Apretable())
    }
}

/// Botón redondo de 44 con un ícono (cerrar, compartir, más).
struct BotonRedondo: View {
    let icono: Icono
    var etiqueta: String
    var fondo: Color = .white
    var frente: Color = .tinta
    var sombra = true
    var accion: () -> Void

    var body: some View {
        Button(action: accion) {
            IconoVista(icono, tamano: 20)
                .foregroundStyle(frente)
                .frame(width: 44, height: 44)
                .background(fondo, in: Circle())
                .shadow(color: sombra ? Color.black.opacity(0.12) : .clear, radius: 8, y: 2)
        }
        .buttonStyle(Apretable())
        .accessibilityLabel(etiqueta)
    }
}

/// La hoja de abajo con «Hoy pagás» y el botón (.ticket): como un carrito.
struct Ticket<Arriba: View>: View {
    let hoy: Int
    let despues: String
    let boton: String
    var variante: Boton.Variante = .mp
    var habilitado = true
    var cargando = false
    @ViewBuilder var arriba: () -> Arriba
    var accion: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            arriba()
            HStack(alignment: .firstTextBaseline) {
                Text("Hoy pagás").tipo(.texto(16, 700)).foregroundStyle(Color.tinta)
                Spacer()
                Text(Plata.texto(hoy)).tipo(.numero(32)).foregroundStyle(Color.tinta)
                    .contentTransition(.numericText(value: Double(hoy)))
                    .animation(.snappy, value: hoy)
            }
            Text(despues).tipo(.texto(14, 400)).foregroundStyle(Color.gris).padding(.top, 4).padding(.bottom, 14)
                .fixedSize(horizontal: false, vertical: true)
            Boton(titulo: boton, variante: variante, alto: .alto, ancho: true, cargando: cargando, habilitado: habilitado, accion: accion)
        }
        .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 12)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.tinta.opacity(0.08), radius: 15, y: -10)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

extension Ticket where Arriba == EmptyView {
    init(hoy: Int, despues: String, boton: String, variante: Boton.Variante = .mp, habilitado: Bool = true, cargando: Bool = false,
         accion: @escaping () -> Void) {
        self.init(hoy: hoy, despues: despues, boton: boton, variante: variante, habilitado: habilitado, cargando: cargando,
                  arriba: { EmptyView() }, accion: accion)
    }
}
