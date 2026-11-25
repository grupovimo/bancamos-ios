import SwiftUI

enum RutaFan: Hashable {
    case creador(String), posteo(String, String), membresia(String), recibos, recibo(String), categoria(Categoria), avisos, ajustes
}

/// El flujo de apoyo abierto (una vez o cada mes, con el nivel elegido).
struct PedidoFlujo: Identifiable, Hashable {
    var id: String { "\(creadorId)-\(tipo.rawValue)-\(nivelId ?? "")" }
    var creadorId: String
    var tipo: TipoApoyo
    var nivelId: String?
    /// Arranca directo en un paso (capturas): 0 elegir · 1 revisar · 2 gracias.
    var paso = 0
}

@MainActor
@Observable
final class NavFan {
    var pestana = "explorar"
    var caminos: [String: [RutaFan]] = [:]
    var flujo: PedidoFlujo?

    func ir(_ r: RutaFan) { caminos[pestana, default: []].append(r) }
    func camino(_ p: String) -> Binding<[RutaFan]> {
        Binding(get: { self.caminos[p] ?? [] }, set: { self.caminos[p] = $0 })
    }
    func bancar(_ creadorId: String, _ tipo: TipoApoyo, nivel: String? = nil) {
        Haptico.suave()
        flujo = PedidoFlujo(creadorId: creadorId, tipo: tipo, nivelId: nivel)
    }
}

/// La app del que banca: Explorar · Novedades · Bancás · Perfil.
struct RaizFan: View {
    @Environment(Estado.self) private var estado
    @State private var nav = NavFan()

    init(arranque: Arranque? = nil) {
        let n = NavFan()
        if let a = arranque { RaizFan.preparar(n, a) }
        _nav = State(initialValue: n)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            pila("explorar") { Explorar() }.visible(nav.pestana == "explorar")
            pila("novedades") { Novedades() }.visible(nav.pestana == "novedades")
            pila("bancas") { ABancas() }.visible(nav.pestana == "bancas")
            pila("perfil") { PerfilFan() }.visible(nav.pestana == "perfil")
            if (nav.caminos[nav.pestana] ?? []).isEmpty {
                BarraFlotante(items: items, elegido: $nav.pestana, alTocarActual: { p in withAnimation { nav.caminos[p] = [] } })
                    .padding(.bottom, 6)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.25), value: (nav.caminos[nav.pestana] ?? []).isEmpty)
        .environment(nav)
        .fullScreenCover(item: $nav.flujo) { f in FlujoApoyo(pedido: f).environment(nav).environment(estado) }
    }

    private var items: [ItemBarra] {
        [ItemBarra(id: "explorar", titulo: "Explorar", icono: .lupa),
         ItemBarra(id: "novedades", titulo: "Novedades", icono: .texto),
         ItemBarra(id: "bancas", titulo: "Bancás", icono: .corazon, badge: estado.porPagar.count),
         ItemBarra(id: "perfil", titulo: "Perfil", icono: .persona)]
    }

    private func pila<V: View>(_ p: String, @ViewBuilder raiz: () -> V) -> some View {
        NavigationStack(path: nav.camino(p)) {
            raiz().navigationDestination(for: RutaFan.self) { r in destino(r) }
        }
    }

    @ViewBuilder private func destino(_ r: RutaFan) -> some View {
        switch r {
        case .creador(let id): PaginaCreadorFan(creadorId: id)
        case .posteo(let c, let p): DetallePosteoFan(creadorId: c, posteoId: p)
        case .membresia(let id): DetalleMembresia(membresiaId: id)
        case .recibos: Recibos()
        case .recibo(let id): DetalleRecibo(reciboId: id)
        case .categoria(let c): ListaCategoria(categoria: c)
        case .avisos: AvisosVista(lado: .fan)
        case .ajustes: AjustesFan()
        }
    }

    static func preparar(_ n: NavFan, _ a: Arranque) {
        switch a {
        case .buscar: n.caminos["explorar"] = []
        case .categoria: n.caminos["explorar"] = [.categoria(.musica)]
        case .creador: n.caminos["explorar"] = [.creador("ana")]
        case .posteoFan: n.caminos["explorar"] = [.creador("ana"), .posteo("ana", "a2")]
        case .unaVez: n.caminos["explorar"] = [.creador("ana")]; n.flujo = PedidoFlujo(creadorId: "ana", tipo: .unaVez)
        case .cadaMes: n.caminos["explorar"] = [.creador("ana")]; n.flujo = PedidoFlujo(creadorId: "ana", tipo: .mensual, nivelId: "color")
        case .revisa, .checkout: n.caminos["explorar"] = [.creador("ana")]; n.flujo = PedidoFlujo(creadorId: "ana", tipo: .mensual, nivelId: "color", paso: 1)
        case .gracias: n.caminos["explorar"] = [.creador("ana")]; n.flujo = PedidoFlujo(creadorId: "ana", tipo: .unaVez, paso: 2)
        case .bancas, .bancasVacio: n.pestana = "bancas"
        case .membresia: n.pestana = "bancas"; n.caminos["bancas"] = [.membresia("mb1")]
        case .novedades: n.pestana = "novedades"
        case .perfilFan: n.pestana = "perfil"
        case .recibos: n.pestana = "perfil"; n.caminos["perfil"] = [.recibos]
        case .recibo: n.pestana = "perfil"; n.caminos["perfil"] = [.recibos, .recibo("rc1")]
        default: break
        }
    }
}
