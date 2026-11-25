import SwiftUI
import UIKit

/// Lo que la interfaz lee y las acciones que hace. Todo pasa en memoria al instante (con animación) y
/// después se avisa a `datos`; cuando haya API, `datos` es la que persiste.
@MainActor
@Observable
final class Estado {
    @ObservationIgnored let datos: Datos
    /// Lo que se respondió en el onboarding (nil: todavía no se hizo).
    var perfil: Perfil?
    /// El panel del creador (su página, su gente y su plata).
    var panel: PanelCreador
    /// El que banca: sus membresías, recibos y a quién sigue.
    var fan: PanelFan
    /// Los creadores que se ven al explorar.
    var creadores: [Creador]
    /// Aviso corto que se muestra arriba (toast).
    var aviso: String?
    /// La meta que se acaba de cumplir (abre la celebración).
    var celebrar: Meta?
    /// Error amable para mostrar en una hoja (pago rechazado, sin conexión).
    var error: String?

    init(datos: Datos = DatosDeMuestra()) {
        self.datos = datos
        let p = Perfil.guardado()
        perfil = p
        creadores = DatosDeMuestra.creadores
        if let p, !p.conEjemplos {
            panel = p.lado == .creador ? DatosDeMuestra.panelNuevo(p) : DatosDeMuestra.panelCreador
            fan = p.lado == .fan ? DatosDeMuestra.fanNuevo(p) : DatosDeMuestra.panelFan
        } else {
            panel = DatosDeMuestra.panelCreador
            fan = DatosDeMuestra.panelFan
        }
    }

    /// Trae lo último de `datos`. Secuencial a propósito: nunca `async let` (cerraba la app en Release).
    func cargar() async {
        // La maqueta ya arranca con todo en memoria: recargarla pisaría lo que se hizo al abrir.
        if datos is DatosDeMuestra { return }
        if let c = try? await datos.creadores() { creadores = c }
        if perfil?.lado == .creador, let p = try? await datos.panelCreador() { panel = p }
        if perfil?.lado == .fan, let f = try? await datos.panelFan() { fan = f }
    }

    // MARK: - Perfil

    var lado: Lado? { perfil?.lado }

    /// Termina el onboarding: guarda el perfil y arma la cuenta (vacía, o con los ejemplos si se eligió).
    func terminarOnboarding(_ p: Perfil) {
        perfil = p
        p.guardar()
        if p.lado == .creador {
            panel = p.conEjemplos ? DatosDeMuestra.panelCreador : DatosDeMuestra.panelNuevo(p)
        } else {
            fan = p.conEjemplos ? DatosDeMuestra.panelFan : DatosDeMuestra.fanNuevo(p)
        }
        let datos = self.datos
        Task { try? await datos.guardarPerfil(p) }
    }

    /// Pasa la maqueta a los datos de ejemplo (o la deja como cuenta nueva).
    func usarEjemplos(_ si: Bool) {
        guard var p = perfil else { return }
        p.conEjemplos = si
        perfil = p
        p.guardar()
        withAnimation(.snappy) {
            if p.lado == .creador {
                panel = si ? DatosDeMuestra.panelCreador : DatosDeMuestra.panelNuevo(p)
            } else {
                fan = si ? DatosDeMuestra.panelFan : DatosDeMuestra.fanNuevo(p)
            }
        }
        avisar(si ? "Listo: ves la app con datos de ejemplo." : "Listo: ves tu cuenta tal cual está.")
    }

    func cambiarLado(_ l: Lado) {
        guard var p = perfil else { return }
        p.lado = l
        if !p.conEjemplos {
            // Cuenta propia: el otro lado arranca vacío y con su nombre, nunca con los datos de la maqueta.
            if l == .creador {
                if p.usuario.isEmpty { p.usuario = Texto.usuario(p.nombre.replacingOccurrences(of: " ", with: "")) }
                if panel.yo.id != "yo" { panel = DatosDeMuestra.panelNuevo(p) }
            } else if fan.email != p.email || fan.nombre != p.nombre {
                fan = DatosDeMuestra.fanNuevo(p)
            }
        }
        perfil = p
        p.guardar()
        Haptico.suave()
    }

    func cerrarSesion() {
        Perfil.borrar()
        let datos = self.datos
        Task { try? await datos.cerrarSesion() }
        withAnimation(.easeInOut(duration: 0.35)) {
            perfil = nil
            panel = DatosDeMuestra.panelCreador
            fan = DatosDeMuestra.panelFan
            creadores = DatosDeMuestra.creadores
        }
    }

    func avisar(_ texto: String) {
        withAnimation(.spring(duration: 0.35)) { aviso = texto }
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.6))
            guard let self, self.aviso == texto else { return }
            withAnimation(.easeOut(duration: 0.25)) { self.aviso = nil }
        }
    }

    // MARK: - Creadores (lo que ve el que banca)

    func creador(_ id: String) -> Creador? { creadores.first { $0.id == id } }

    var destacados: [Creador] { creadores.filter(\.destacado) }
    var cercaTuyo: [Creador] { creadores.filter { ($0.distanciaKm ?? 999) < 20 }.sorted { ($0.distanciaKm ?? 0) < ($1.distanciaKm ?? 0) } }
    func deCategoria(_ c: Categoria) -> [Creador] { creadores.filter { $0.categoria == c } }

    func buscar(_ q: String) -> [Creador] {
        let t = q.limpio.folding(options: .diacriticInsensitive, locale: Fecha.ar).lowercased()
        guard !t.isEmpty else { return [] }
        return creadores.filter { c in
            [c.nombre, c.usuario, c.frase, c.ciudad, c.categoria.nombre].contains {
                $0.folding(options: .diacriticInsensitive, locale: Fecha.ar).lowercased().contains(t)
            }
        }
    }

    /// Sugeridos para seguir (onboarding): primero los de sus intereses.
    func sugeridos(para intereses: [Categoria]) -> [Creador] {
        creadores.sorted { a, b in
            let ia = intereses.contains(a.categoria), ib = intereses.contains(b.categoria)
            return ia != ib ? ia : a.mensuales > b.mensuales
        }
    }

    // MARK: - El que banca

    func membresia(de creadorId: String) -> Membresia? { fan.membresias.first { $0.creadorId == creadorId } }
    func nivelDelFan(en creadorId: String) -> String? { membresia(de: creadorId)?.nivelId }
    func sigue(_ creadorId: String) -> Bool { fan.siguiendo.contains(creadorId) }

    var totalMensual: Int { fan.membresias.reduce(0) { $0 + $1.monto } }
    var porPagar: [Membresia] { fan.membresias.filter { $0.estado == .porPagar } }

    /// Posteos de a quién banca o sigue, del más nuevo al más viejo (sin los programados).
    var novedades: [(creador: Creador, posteo: Posteo)] {
        let ids = Set(fan.siguiendo + fan.membresias.map(\.creadorId))
        return creadores.filter { ids.contains($0.id) }
            .flatMap { c in c.posteos.filter { !$0.esProgramado }.map { (c, $0) } }
            .sorted { $0.1.fecha > $1.1.fecha }
    }

    func seguir(_ creadorId: String) {
        let ahora = !sigue(creadorId)
        Haptico.seleccion()
        withAnimation(.snappy) {
            if ahora { fan.siguiendo.append(creadorId) } else { fan.siguiendo.removeAll { $0 == creadorId } }
        }
        let datos = self.datos
        Task { try? await datos.seguir(creadorId: creadorId, siguiendo: ahora) }
    }

    func meGusta(_ posteoId: String, creadorId: String) {
        guard let c = creadores.firstIndex(where: { $0.id == creadorId }),
              let p = creadores[c].posteos.firstIndex(where: { $0.id == posteoId }) else { return }
        Haptico.suave()
        let nuevo = !creadores[c].posteos[p].leGusta
        withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
            creadores[c].posteos[p].leGusta = nuevo
            creadores[c].posteos[p].meGusta += nuevo ? 1 : -1
        }
        let datos = self.datos
        Task { try? await datos.meGusta(posteoId: posteoId, valor: nuevo) }
    }

    /// Paga (con el checkout de Mercado Pago ya aprobado) y actualiza la meta, la membresía y los recibos.
    func apoyar(_ pedido: PedidoApoyo) async throws -> Recibo {
        let recibo = try await datos.apoyar(pedido)
        aplicar(pedido, recibo: recibo)
        return recibo
    }

    /// Lo que cambia en memoria con un pago aprobado (separado para poder probarlo).
    func aplicar(_ pedido: PedidoApoyo, recibo: Recibo) {
        Haptico.exito()
        var r = recibo
        if let i = creadores.firstIndex(where: { $0.id == pedido.creadorId }) {
            if pedido.tipo == .mensual, let n = pedido.nivelId {
                r.concepto = "Cuota mensual · " + (creadores[i].nivel(n)?.nombre ?? "")
            }
            withAnimation(.spring(duration: 0.8)) {
                creadores[i].bancadas += 1
                if let m = creadores[i].metas.firstIndex(where: { !$0.cerrada }) { creadores[i].metas[m].recaudado += pedido.monto }
                if pedido.tipo == .mensual, let n = pedido.nivelId {
                    let anterior = membresia(de: pedido.creadorId)
                    if anterior == nil { creadores[i].mensuales += 1 }
                    if let a = anterior?.nivelId, a != n, let k = creadores[i].niveles.firstIndex(where: { $0.id == a }) {
                        creadores[i].niveles[k].miembros -= 1
                    }
                    if anterior?.nivelId != n, let k = creadores[i].niveles.firstIndex(where: { $0.id == n }) {
                        creadores[i].niveles[k].miembros += 1
                    }
                }
            }
        }
        withAnimation(.snappy) {
            if pedido.tipo == .mensual, let n = pedido.nivelId {
                let nueva = Membresia(id: membresia(de: pedido.creadorId)?.id ?? UUID().uuidString, creadorId: pedido.creadorId, nivelId: n,
                                      monto: pedido.monto, desde: membresia(de: pedido.creadorId)?.desde ?? Date(),
                                      proximoPago: Fecha.proximoMes(), estado: .alDia)
                if let k = fan.membresias.firstIndex(where: { $0.creadorId == pedido.creadorId }) { fan.membresias[k] = nueva } else { fan.membresias.insert(nueva, at: 0) }
            }
            fan.recibos.insert(r, at: 0)
            if !fan.siguiendo.contains(pedido.creadorId) { fan.siguiendo.append(pedido.creadorId) }
        }
    }

    func cambiarNivel(membresiaId: String, a nivelId: String) {
        guard let k = fan.membresias.firstIndex(where: { $0.id == membresiaId }),
              let i = creadores.firstIndex(where: { $0.id == fan.membresias[k].creadorId }),
              let nuevo = creadores[i].nivel(nivelId) else { return }
        let viejo = fan.membresias[k].nivelId
        Haptico.exito()
        withAnimation(.snappy) {
            fan.membresias[k].nivelId = nivelId
            fan.membresias[k].monto = nuevo.precio
            if let a = creadores[i].niveles.firstIndex(where: { $0.id == viejo }) { creadores[i].niveles[a].miembros -= 1 }
            if let b = creadores[i].niveles.firstIndex(where: { $0.id == nivelId }) { creadores[i].niveles[b].miembros += 1 }
        }
        avisar("Listo. Desde el próximo pago, \(nuevo.nombre) a \(Plata.texto(nuevo.precio)).")
        let datos = self.datos
        Task { try? await datos.cambiarNivel(membresiaId: membresiaId, nivelId: nivelId) }
    }

    func cancelar(membresiaId: String) {
        guard let k = fan.membresias.firstIndex(where: { $0.id == membresiaId }) else { return }
        let m = fan.membresias[k]
        Haptico.exito()
        withAnimation(.snappy) {
            fan.membresias.remove(at: k)
            if let i = creadores.firstIndex(where: { $0.id == m.creadorId }) {
                creadores[i].mensuales = max(0, creadores[i].mensuales - 1)
                if let n = creadores[i].niveles.firstIndex(where: { $0.id == m.nivelId }) { creadores[i].niveles[n].miembros -= 1 }
            }
        }
        avisar("Listo. No se te cobra más.")
        let datos = self.datos
        Task { try? await datos.cancelar(membresiaId: membresiaId) }
    }

    func guardarAvisosFan(_ a: AjustesAvisos) {
        fan.avisos = a
        let datos = self.datos
        Task { try? await datos.guardarAvisos(a) }
    }
}

// MARK: - Hápticos

enum Haptico {
    static func suave() { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
    static func exito() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func aviso() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func seleccion() { UISelectionFeedbackGenerator().selectionChanged() }
}
