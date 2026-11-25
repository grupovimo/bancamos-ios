import SwiftUI

/// Una pestaña de la barra flotante.
struct ItemBarra: Identifiable, Hashable {
    let id: String
    let titulo: String
    let icono: Icono
    var badge = 0
}

/// La barra flotante (.flota): tinta al 95 %, 64 de alto, la pestaña elegida en una píldora blanca con su nombre
/// y, si hay, el + esmeralda en el medio.
struct BarraFlotante: View {
    let items: [ItemBarra]
    @Binding var elegido: String
    /// Dónde va el + (índice). nil: sin +.
    var posicionMas: Int? = nil
    var alTocarMas: () -> Void = {}
    var alTocarActual: (String) -> Void = { _ in }
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { i, item in
                if i == posicionMas { botonMas }
                boton(item)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 64)
        .background(Color.tinta.opacity(0.95), in: Capsule())
        .shadow(color: Color.tinta.opacity(0.25), radius: 17, y: 16)
        .padding(.horizontal, 20)
    }

    private var botonMas: some View {
        Button {
            Haptico.suave()
            alTocarMas()
        } label: {
            IconoVista(.mas, tamano: 24, grosor: 2.2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Color.esmeralda, in: Circle())
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(Apretable())
        .accessibilityLabel("Crear: posteo, nivel o meta")
    }

    private func boton(_ item: ItemBarra) -> some View {
        let on = item.id == elegido
        return Button {
            if on { alTocarActual(item.id) } else {
                Haptico.seleccion()
                withAnimation(.spring(duration: 0.35, bounce: 0.15)) { elegido = item.id }
            }
        } label: {
            HStack(spacing: 6) {
                IconoVista(item.icono, tamano: 24)
                    .overlay(alignment: .topTrailing) {
                        if item.badge > 0 && !on {
                            Circle().fill(Color(hex: 0x3DD69B)).frame(width: 9, height: 9)
                                .overlay(Circle().stroke(Color.tinta, lineWidth: 2)).offset(x: 3, y: -1)
                        }
                    }
                if on {
                    Text(item.titulo).tipo(.texto(14, 700)).lineLimit(1).fixedSize()
                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                }
            }
            .foregroundStyle(on ? Color.tinta : Color.white.opacity(0.72))
            .padding(.leading, on ? 12 : 0).padding(.trailing, on ? 14 : 0)
            .frame(height: 48)
            .frame(minWidth: 48)
            .background {
                if on { Capsule().fill(Color.white).matchedGeometryEffect(id: "pildora", in: ns) }
            }
            .frame(maxWidth: on ? nil : .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(Apretable())
        .layoutPriority(on ? 1 : 0)
        .accessibilityLabel(item.badge > 0 ? "\(item.titulo), \(item.badge) nuevos" : item.titulo)
        .accessibilityAddTraits(on ? [.isSelected, .isButton] : .isButton)
    }
}
