import SwiftUI

/// Las acciones y los derivados del creador.
extension Estado {
    var yo: Creador { panel.yo }

    // MARK: - Derivados

    var mesActual: MesCobros? { panel.meses.last }
    var entroEsteMes: Int { mesActual?.bruto ?? 0 }
    var sueltasEsteMes: Int { mesActual?.apoyos ?? 0 }
    var sinAgradecer: [Apoyo] { panel.apoyos.filter { !$0.agradecido && !$0.anonimo } }
    var mensajesSinLeer: Int { panel.conversaciones.reduce(0) { $0 + $1.noLeidos } }
    var avisosSinLeer: Int { panel.notificaciones.filter { !$0.leida }.count }
    var cuentaNueva: Bool { panel.apoyos.isEmpty && panel.miembros.isEmpty }

    /// Variación contra el mes anterior, en %.
    var crecimiento: Int? {
        let m = panel.meses
        guard m.count >= 2, m[m.count - 2].bruto > 0 else { return nil }
        let actual = Double(m[m.count - 1].bruto)
        let anterior = Double(m[m.count - 2].bruto)
        let cambio: Double = (actual / anterior - 1) * 100
        return Int(cambio)
    }

    /// Primeros pasos de una cuenta nueva (el «para hacer» del inicio).
    var primerosPasos: [(titulo: String, hecho: Bool, icono: Icono)] {
        [
            ("Conectá tu Mercado Pago", panel.cuentaMP.conectada, .mp),
            ("Poné tu foto y tu portada", yo.foto.existe && yo.portada.existe, .foto),
            ("Armá tus niveles", !yo.nivelesActivos.isEmpty, .capas),
            ("Publicá tu primer posteo", !yo.posteos.isEmpty, .texto),
            ("Compartí tu link", UserDefaults.standard.bool(forKey: "compartioLink"), .compartir),
        ]
    }

    func miembros(nivel: String?) -> [Miembro] {
        panel.miembros.filter { nivel == nil || $0.nivelId == nivel }
    }
    func miembro(_ id: String) -> Miembro? { panel.miembros.first { $0.id == id } }
    func apoyosDe(_ nombre: String) -> [Apoyo] { panel.apoyos.filter { $0.nombre == nombre } }

    /// Cuántas personas ven un posteo con ese público.
    func alcance(_ p: PublicoPosteo) -> Int {
        switch p {
        case .todos: return yo.mensuales + max(400, yo.bancadas / 2)
        case .quienesTeBancan: return yo.niveles.reduce(0) { $0 + $1.miembros }
        case .desde(let id):
            guard let min = yo.nivel(id) else { return 0 }
            return yo.niveles.filter { $0.precio >= min.precio }.reduce(0) { $0 + $1.miembros }
        }
    }

    /// Lo que se espera que entre por mes con las cuotas de hoy.
    var mensualEsperado: Int { yo.niveles.reduce(0) { $0 + $1.precio * $1.miembros } }

    // MARK: - Página

    func guardar(creador c: Creador, aviso: String? = "Cambios guardados.") {
        withAnimation(.snappy) { panel.yo = c }
        let datos = self.datos
        Task { try? await datos.guardarCreador(c) }
        if let aviso { Haptico.exito(); avisar(aviso) }
    }

    func marcarLinkCompartido() { UserDefaults.standard.set(true, forKey: "compartioLink") }

    // MARK: - Niveles

    func guardarNivel(_ n: Nivel) {
        let nuevo = !panel.yo.niveles.contains { $0.id == n.id }
        withAnimation(.snappy) {
            if let i = panel.yo.niveles.firstIndex(where: { $0.id == n.id }) { panel.yo.niveles[i] = n } else { panel.yo.niveles.append(n) }
        }
        Haptico.exito()
        avisar(nuevo ? "Nivel publicado. Ya lo ve tu gente." : "Nivel guardado.")
        let datos = self.datos, id = panel.yo.id
        Task { try? await datos.guardarNivel(n, creadorId: id) }
    }

    func pausar(nivelId: String) {
        guard let i = panel.yo.niveles.firstIndex(where: { $0.id == nivelId }) else { return }
        withAnimation(.snappy) { panel.yo.niveles[i].pausado.toggle() }
        let n = panel.yo.niveles[i]
        Haptico.seleccion()
        avisar(n.pausado ? "Pausado: nadie nuevo puede sumarse. Los de hoy siguen." : "\(n.nombre) está activo de nuevo.")
        let datos = self.datos, id = panel.yo.id
        Task { try? await datos.guardarNivel(n, creadorId: id) }
    }

    func borrar(nivelId: String) {
        guard let n = panel.yo.niveles.first(where: { $0.id == nivelId }), n.miembros == 0 else { return }
        withAnimation(.snappy) { panel.yo.niveles.removeAll { $0.id == nivelId } }
        avisar("Nivel borrado.")
    }

    // MARK: - Metas

    func guardarMeta(_ m: Meta) {
        let nueva = !panel.yo.metas.contains { $0.id == m.id }
        withAnimation(.snappy) {
            if let i = panel.yo.metas.firstIndex(where: { $0.id == m.id }) { panel.yo.metas[i] = m } else { panel.yo.metas.insert(m, at: 0) }
        }
        Haptico.exito()
        avisar(nueva ? "Meta publicada. Ya aparece en tu página." : "Meta guardada.")
        let datos = self.datos, id = panel.yo.id
        Task { try? await datos.guardarMeta(m, creadorId: id) }
    }

    /// Cierra la meta. Si se llegó, se festeja.
    func cerrar(metaId: String) {
        guard let i = panel.yo.metas.firstIndex(where: { $0.id == metaId }) else { return }
        withAnimation(.snappy) {
            panel.yo.metas[i].cerrada = true
            if panel.yo.metas[i].lograda { panel.yo.metas[i].cumplida = Date() }
        }
        let m = panel.yo.metas[i]
        if m.lograda { Haptico.exito(); celebrar = m } else { avisar("Meta cerrada. Lo que juntaste queda en tu historial.") }
        let datos = self.datos, id = panel.yo.id
        Task { try? await datos.guardarMeta(m, creadorId: id) }
    }

    // MARK: - Posteos

    func publicar(_ p: Posteo) {
        withAnimation(.snappy) {
            if let i = panel.yo.posteos.firstIndex(where: { $0.id == p.id }) { panel.yo.posteos[i] = p } else { panel.yo.posteos.insert(p, at: 0) }
            panel.yo.posteos.sort { ($0.programado ?? $0.fecha) > ($1.programado ?? $1.fecha) }
        }
        Haptico.exito()
        if p.esProgramado {
            avisar("Programado para el \(Fecha.dia(p.programado!)) a las \(Fecha.hora(p.programado!)).")
        } else {
            avisar(p.avisarPorMail ? "Publicado. Les avisamos a \(Plata.numero(alcance(p.publico))) personas." : "Publicado.")
        }
        let datos = self.datos
        Task { try? await datos.publicar(p) }
    }

    func borrar(posteoId: String) {
        withAnimation(.snappy) { panel.yo.posteos.removeAll { $0.id == posteoId } }
        avisar("Posteo borrado.")
        let datos = self.datos
        Task { try? await datos.borrarPosteo(id: posteoId) }
    }

    // MARK: - Gente

    func agradecer(_ apoyoId: String, texto: String) {
        guard let i = panel.apoyos.firstIndex(where: { $0.id == apoyoId }) else { return }
        withAnimation(.snappy) { panel.apoyos[i].agradecido = true }
        Haptico.exito()
        avisar("Le llegó tu gracias a \(panel.apoyos[i].nombre.split(separator: " ").first ?? "").")
        let datos = self.datos
        Task { try? await datos.agradecer(apoyoId: apoyoId, texto: texto) }
    }

    func agradecerTodos(texto: String) {
        let ids = sinAgradecer.map(\.id)
        withAnimation(.snappy) {
            for i in panel.apoyos.indices where ids.contains(panel.apoyos[i].id) { panel.apoyos[i].agradecido = true }
        }
        Haptico.exito()
        avisar("Les llegó tu gracias a \(Texto.plural(ids.count, "persona", "personas")).")
        let datos = self.datos
        Task { for id in ids { try? await datos.agradecer(apoyoId: id, texto: texto) } }
    }

    func guardarNota(_ nota: String, miembroId: String) {
        guard let i = panel.miembros.firstIndex(where: { $0.id == miembroId }) else { return }
        panel.miembros[i].nota = nota
    }

    func conversacion(_ id: String) -> Conversacion? { panel.conversaciones.first { $0.id == id } }

    /// La conversación con alguien (la crea si no existe).
    func conversacionCon(_ nombre: String, nivel: String?) -> String {
        if let c = panel.conversaciones.first(where: { $0.nombre == nombre }) { return c.id }
        let c = Conversacion(id: UUID().uuidString, nombre: nombre, nivel: nivel, mensajes: [], noLeidos: 0)
        panel.conversaciones.insert(c, at: 0)
        return c.id
    }

    func leer(conversacionId: String) {
        guard let i = panel.conversaciones.firstIndex(where: { $0.id == conversacionId }) else { return }
        panel.conversaciones[i].noLeidos = 0
    }

    func enviar(_ texto: String, a conversacionId: String) {
        let t = texto.limpio
        guard !t.isEmpty, let i = panel.conversaciones.firstIndex(where: { $0.id == conversacionId }) else { return }
        Haptico.suave()
        withAnimation(.snappy) {
            panel.conversaciones[i].mensajes.append(Mensaje(id: UUID().uuidString, deMi: true, texto: t, fecha: Date()))
            let c = panel.conversaciones.remove(at: i)
            panel.conversaciones.insert(c, at: 0)
        }
        let datos = self.datos
        Task { try? await datos.enviarMensaje(conversacionId: conversacionId, texto: t) }
    }

    func leerNotificaciones() {
        for i in panel.notificaciones.indices { panel.notificaciones[i].leida = true }
    }

    // MARK: - Mercado Pago, fiscal y ajustes

    func conectarMercadoPago() async -> Bool {
        do {
            let c = try await datos.conectarMercadoPago()
            withAnimation(.snappy) { panel.cuentaMP = c }
            if var p = perfil { p.mpConectado = true; perfil = p; p.guardar() }
            Haptico.exito()
            return true
        } catch {
            Haptico.aviso()
            self.error = (error as? LocalizedError)?.errorDescription ?? ErrorDatos.desconocido.errorDescription
            return false
        }
    }

    func desconectarMercadoPago() {
        withAnimation(.snappy) { panel.cuentaMP = CuentaMP(conectada: false, email: "", nombre: panel.yo.nombre, desde: nil) }
        if var p = perfil { p.mpConectado = false; perfil = p; p.guardar() }
        avisar("Desconectado. Tu página no recibe apoyos hasta que conectes otra cuenta.")
        let datos = self.datos
        Task { try? await datos.desconectarMercadoPago() }
    }

    func guardar(fiscal f: DatosFiscales) {
        panel.fiscal = f
        Haptico.exito(); avisar("Datos fiscales guardados.")
        let datos = self.datos
        Task { try? await datos.guardarFiscal(f) }
    }

    func guardar(privacidad p: Privacidad) {
        panel.privacidad = p
        let datos = self.datos
        Task { try? await datos.guardarPrivacidad(p) }
    }

    func guardar(avisos a: AjustesAvisos) {
        panel.avisos = a
        let datos = self.datos
        Task { try? await datos.guardarAvisos(a) }
    }

    // MARK: - Exportar

    /// CSV de lo que acreditó Mercado Pago (separado con «;», como lo abre Excel en castellano).
    func csvCobros() -> URL {
        var filas = ["Fecha;Nombre;Tipo;Bruto;Bancamos 3 %;Mercado Pago;Neto;Operación MP"]
        for a in panel.acreditaciones {
            filas.append([Fecha.isoDia(a.fecha), a.nombre, a.tipo == .mensual ? "Cada mes" : "Una vez", "\(a.bruto)", "\(a.comision)",
                          "\(a.cargoMP)", "\(a.neto)", a.operacionMP].joined(separator: ";"))
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("bancamos-cobros-\(Fecha.isoMes(Date())).csv")
        try? ("\u{FEFF}" + filas.joined(separator: "\n")).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    /// CSV de la gente que banca cada mes.
    func csvMiembros() -> URL {
        var filas = ["Nombre;Email;Nivel;Desde;Estado;Aportado"]
        for m in panel.miembros {
            filas.append([m.nombre, m.email, yo.nivel(m.nivelId)?.nombre ?? "", Fecha.isoDia(m.desde), m.estado.nombre, "\(m.aportado)"].joined(separator: ";"))
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("bancamos-miembros.csv")
        try? ("\u{FEFF}" + filas.joined(separator: "\n")).write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
