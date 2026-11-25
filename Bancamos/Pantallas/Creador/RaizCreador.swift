import SwiftUI

enum RutaCreador: Hashable {
    case apoyos, miembro(String), posteo(String), niveles, metas, miPagina, asiTeVen, mensajes, conversacion(String)
    case estadisticas, cobros, notificaciones, ajustes, cuentaMP, fiscal, privacidad, avisos, plan, ayuda
}

enum HojaCreador: Identifiable, Hashable {
    case crear, posteo(Posteo?), nivel(Nivel?), meta(Meta?), qr, agradecer(String), agradecerTodos, editar(SeccionPagina)
    var id: String {
        switch self {
        case .crear: return "crear"
        case .posteo(let p): return "posteo-\(p?.id ?? "nuevo")"
        case .nivel(let n): return "nivel-\(n?.id ?? "nuevo")"
        case .meta(let m): return "meta-\(m?.id ?? "nueva")"
        case .qr: return "qr"
        case .agradecer(let a): return "agradecer-\(a)"
        case .agradecerTodos: return "agradecer-todos"
        case .editar(let s): return "editar-\(s.rawValue)"
        }
    }
}

/// Lo que navega el creador: la pestaña, el camino de cada pestaña y la hoja abierta.
@MainActor
@Observable
final class NavCreador {
    var pestana = "inicio"
    var caminos: [String: [RutaCreador]] = [:]
    var hoja: HojaCreador?

    func ir(_ r: RutaCreador) { caminos[pestana, default: []].append(r) }
    func camino(_ p: String) -> Binding<[RutaCreador]> {
        Binding(get: { self.caminos[p] ?? [] }, set: { self.caminos[p] = $0 })
    }
    func abrir(_ h: HojaCreador) { Haptico.suave(); hoja = h }
}

/// La app del creador: Inicio · Gente · + · Posteos · Más.
struct RaizCreador: View {
    @Environment(Estado.self) private var estado
    @State private var nav = NavCreador()

    init(arranque: Arranque? = nil) {
        let n = NavCreador()
        if let a = arranque { RaizCreador.preparar(n, a) }
        _nav = State(initialValue: n)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            pila("inicio") { Inicio() }.visible(nav.pestana == "inicio")
            pila("gente") { Gente() }.visible(nav.pestana == "gente")
            pila("posteos") { Posteos() }.visible(nav.pestana == "posteos")
            pila("mas") { MasCreador() }.visible(nav.pestana == "mas")
            if (nav.caminos[nav.pestana] ?? []).isEmpty {
                BarraFlotante(items: items, elegido: $nav.pestana, posicionMas: 2, alTocarMas: { nav.abrir(.crear) },
                              alTocarActual: { p in withAnimation { nav.caminos[p] = [] } })
                    .padding(.bottom, 6)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.25), value: (nav.caminos[nav.pestana] ?? []).isEmpty)
        .environment(nav)
        .sheet(item: $nav.hoja) { h in hoja(h).environment(nav).environment(estado) }
    }

    private var items: [ItemBarra] {
        [ItemBarra(id: "inicio", titulo: "Inicio", icono: .casa, badge: estado.avisosSinLeer),
         ItemBarra(id: "gente", titulo: "Gente", icono: .gente, badge: estado.sinAgradecer.count),
         ItemBarra(id: "posteos", titulo: "Posteos", icono: .texto),
         ItemBarra(id: "mas", titulo: "Más", icono: .puntos, badge: estado.mensajesSinLeer)]
    }

    private func pila<V: View>(_ p: String, @ViewBuilder raiz: () -> V) -> some View {
        NavigationStack(path: nav.camino(p)) {
            raiz().navigationDestination(for: RutaCreador.self) { r in destino(r) }
        }
    }

    @ViewBuilder private func destino(_ r: RutaCreador) -> some View {
        switch r {
        case .apoyos: Gente(soloApoyos: true)
        case .miembro(let id): FichaMiembro(miembroId: id)
        case .posteo(let id): DetallePosteoCreador(posteoId: id)
        case .niveles: Niveles()
        case .metas: Metas()
        case .miPagina: MiPagina()
        case .asiTeVen: AsiTeVen()
        case .mensajes: Mensajes()
        case .conversacion(let id): ConversacionVista(conversacionId: id)
        case .estadisticas: Estadisticas()
        case .cobros: Cobros()
        case .notificaciones: Notificaciones()
        case .ajustes: AjustesCreador()
        case .cuentaMP: CuentaMercadoPago()
        case .fiscal: DatosFiscalesVista()
        case .privacidad: PrivacidadVista()
        case .avisos: AvisosVista(lado: .creador)
        case .plan: PlanComision()
        case .ayuda: Ayuda()
        }
    }

    @ViewBuilder private func hoja(_ h: HojaCreador) -> some View {
        switch h {
        case .crear: MenuCrear().presentationDetents([.height(430)]).presentationCornerRadius(28)
        case .posteo(let p): EditorPosteo(original: p)
        case .nivel(let n): EditorNivel(original: n)
        case .meta(let m): EditorMeta(original: m)
        case .qr: HojaQR()
        case .agradecer(let id): HojaAgradecer(apoyoIds: [id]).presentationDetents([.medium, .large])
        case .agradecerTodos: HojaAgradecer(apoyoIds: estado.sinAgradecer.map(\.id)).presentationDetents([.medium, .large])
        case .editar(let s): EditarSeccion(seccion: s)
        }
    }

    /// Acomoda la navegación para abrir una pantalla directo (capturas).
    static func preparar(_ n: NavCreador, _ a: Arranque) {
        switch a {
        case .gente, .agradecer: n.pestana = "gente"
        case .apoyos: n.pestana = "gente"; n.caminos["gente"] = [.apoyos]
        case .miembro: n.pestana = "gente"; n.caminos["gente"] = [.miembro("m2")]
        case .posteos: n.pestana = "posteos"
        case .posteo: n.pestana = "posteos"; n.caminos["posteos"] = [.posteo("a2")]
        case .mas: n.pestana = "mas"
        case .niveles, .nivelNuevo: n.pestana = "mas"; n.caminos["mas"] = [.niveles]
        case .metas, .metaNueva: n.pestana = "mas"; n.caminos["mas"] = [.metas]
        case .miPagina, .editarPagina, .qr: n.pestana = "mas"; n.caminos["mas"] = [.miPagina]
        case .asiTeVen: n.pestana = "mas"; n.caminos["mas"] = [.miPagina, .asiTeVen]
        case .mensajes: n.pestana = "mas"; n.caminos["mas"] = [.mensajes]
        case .conversacion: n.pestana = "mas"; n.caminos["mas"] = [.mensajes, .conversacion("c1")]
        case .estadisticas: n.pestana = "mas"; n.caminos["mas"] = [.estadisticas]
        case .cobros: n.pestana = "mas"; n.caminos["mas"] = [.cobros]
        case .notificaciones: n.caminos["inicio"] = [.notificaciones]
        case .ajustes: n.pestana = "mas"; n.caminos["mas"] = [.ajustes]
        case .cuentaMP: n.pestana = "mas"; n.caminos["mas"] = [.ajustes, .cuentaMP]
        case .fiscal: n.pestana = "mas"; n.caminos["mas"] = [.ajustes, .fiscal]
        case .privacidad: n.pestana = "mas"; n.caminos["mas"] = [.ajustes, .privacidad]
        case .plan: n.pestana = "mas"; n.caminos["mas"] = [.plan]
        case .ayuda: n.pestana = "mas"; n.caminos["mas"] = [.ayuda]
        default: break
        }
        switch a {
        case .crear: n.hoja = .crear
        case .posteoNuevo: n.hoja = .posteo(nil)
        case .nivelNuevo: n.hoja = .nivel(nil)
        case .metaNueva: n.hoja = .meta(nil)
        case .editarPagina: n.hoja = .editar(.datos)
        case .qr: n.hoja = .qr
        case .agradecer: n.hoja = .agradecer("ap1")
        default: break
        }
    }
}

/// El menú del +: lo que se crea.
struct MenuCrear: View {
    @Environment(NavCreador.self) private var nav
    @Environment(Estado.self) private var estado

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Titulo("Crear", tamano: 28).padding(.horizontal, 20).padding(.top, 26).padding(.bottom, 12)
            opcion(.texto, "Posteo", "Texto, fotos o audio, para todos o para los que te bancan") { nav.hoja = .posteo(nil) }
            opcion(.capas, "Nivel", "Una cuota mensual con lo que incluye") { nav.hoja = .nivel(nil) }
            opcion(.bandera, "Meta", "Para qué estás juntando y cuánto falta") { nav.hoja = .meta(nil) }
            opcion(.compartir, "Compartir mi link", estado.yo.link) { nav.hoja = .qr }
            Spacer(minLength: 0)
        }
    }

    private func opcion(_ i: Icono, _ t: String, _ s: String, accion: @escaping () -> Void) -> some View {
        Button {
            nav.hoja = nil
            Task { try? await Task.sleep(for: .seconds(0.45)); accion() }
        } label: {
            FilaMenu(icono: i, titulo: t, sub: s).padding(.horizontal, 4)
        }
        .buttonStyle(Apretable())
    }
}
