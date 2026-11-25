import SwiftUI

/// El inicio del creador (pantalla 6): lo que entró en el mes, la meta, lo último que llegó y qué hacer.
struct Inicio: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Saludo()
                if estado.cuentaNueva { PrimerosPasos().padding(.top, 16) }
                if !estado.panel.cuentaMP.conectada { AvisoConectarMP().padding(.top, 16) }
                TarjetaEntro().padding(.top, 16)
                if let m = estado.yo.metaActiva {
                    Button { nav.ir(.metas) } label: {
                        TarjetaMeta(meta: m, pie: pieMeta(m), sombra: true)
                    }
                    .buttonStyle(Apretable())
                    .padding(.top, 12)
                }
                Recien()
                if !estado.cuentaNueva { ResumenNiveles() }
                if [.bienestar, .educacion].contains(estado.yo.categoria) {
                    BannerGrupo(.otraMas).padding(.top, 20)
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, Espacio.bajoBarra)
        }
        .background(Color.fondo)
        .toolbar(.hidden, for: .navigationBar)
        .refreshable { await estado.cargar() }
    }

    private func pieMeta(_ m: Meta) -> String {
        if m.lograda { return "¡Llegaste! Cerrala para festejar con tu gente." }
        return "Faltan \(Plata.texto(m.falta)) · \(Texto.plural(estado.yo.mensuales, "te banca", "te bancan")) cada mes"
    }
}

private struct Saludo: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Fecha.encabezado()).tipo(.texto(14, 600)).foregroundStyle(Color.gris)
                Titulo("Hola, \(estado.yo.primerNombre)", tamano: 32)
            }
            Spacer(minLength: 8)
            Button { nav.ir(.notificaciones) } label: {
                IconoVista(.campana, tamano: 22).foregroundStyle(Color.tinta)
                    .frame(width: 44, height: 44)
                    .background(Color.white, in: Circle())
                    .overlay(alignment: .topTrailing) {
                        if estado.avisosSinLeer > 0 {
                            Circle().fill(Color.esmeralda).frame(width: 10, height: 10).overlay(Circle().stroke(.white, lineWidth: 2)).offset(x: -6, y: 6)
                        }
                    }
            }
            .buttonStyle(Apretable())
            .accessibilityLabel(estado.avisosSinLeer > 0 ? "Avisos, \(estado.avisosSinLeer) sin leer" : "Avisos")
            Button { nav.ir(.miPagina) } label: { Avatar(estado.yo, tamano: 48) }
                .buttonStyle(Apretable())
                .accessibilityLabel("Mi página")
        }
        .padding(.top, 8)
    }
}

/// La tarjeta verde (.entro): lo que entró en el mes, directo a su Mercado Pago.
private struct TarjetaEntro: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        Button { nav.ir(.cobros) } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("ENTRÓ EN \(Fecha.mes().uppercased(with: Fecha.ar))").tipo(.etiqueta).foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    if let c = estado.crecimiento, c > 0 {
                        Text("+\(c) %").tipo(.texto(13, 700)).foregroundStyle(.white)
                            .padding(.horizontal, 10).frame(height: 26).background(.white.opacity(0.16), in: Capsule())
                    }
                }
                Text(Plata.texto(estado.entroEsteMes)).tipo(.numero(48)).foregroundStyle(.white)
                    .minimumScaleFactor(0.7).lineLimit(1).padding(.top, 6)
                Text("Directo a tu Mercado Pago").tipo(.texto(14, 400)).foregroundStyle(.white.opacity(0.85)).padding(.top, 2)
                HStack(spacing: 8) {
                    cifra(estado.yo.mensuales, estado.yo.mensuales == 1 ? "te banca cada mes" : "te bancan cada mes")
                    cifra(estado.sueltasEsteMes, estado.sueltasEsteMes == 1 ? "bancada suelta" : "bancadas sueltas")
                }
                .padding(.top, 14)
            }
            .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.esmeralda700, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(Apretable())
        .accessibilityLabel("Entró en \(Fecha.mes()): \(Plata.texto(estado.entroEsteMes)). Ver cobros.")
    }

    private func cifra(_ n: Int, _ t: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Plata.numero(n)).tipo(.numero(22)).foregroundStyle(.white)
            Text(t).tipo(.texto(13, 400)).foregroundStyle(.white)
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// «Recién»: los últimos apoyos con su mensaje.
private struct Recien: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TituloSeccion(texto: "Recién", accion: estado.panel.apoyos.isEmpty ? nil : "Ver todo", arriba: 20) { nav.ir(.apoyos) }
            if estado.panel.apoyos.isEmpty {
                Tarjeta {
                    EstadoVacio(icono: .corazon, titulo: "Todavía no te bancó nadie",
                                texto: "Cuando alguien te banque, aparece acá con su mensaje. El primer paso es compartir tu link.",
                                accion: "Compartir mi link") { nav.abrir(.qr) }
                }
            } else {
                Tarjeta {
                    ForEach(Array(estado.panel.apoyos.prefix(3).enumerated()), id: \.element.id) { i, a in
                        if i > 0 { Divisor() }
                        FilaApoyo(apoyo: a)
                    }
                }
                if estado.sinAgradecer.count > 1 {
                    Button { nav.abrir(.agradecerTodos) } label: {
                        HStack(spacing: 10) {
                            IconoVista(.mano, tamano: 20).foregroundStyle(Color.esmeralda700)
                            Text("Agradecer a \(Texto.plural(estado.sinAgradecer.count, "persona", "personas")) de una vez")
                                .tipo(.texto(15, 700)).foregroundStyle(Color.esmeralda700)
                            Spacer()
                            IconoVista(.der, tamano: 16).foregroundStyle(Color.esmeralda700)
                        }
                        .padding(.horizontal, 16).frame(minHeight: 52)
                        .background(Color.esmeralda100, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(Apretable())
                    .padding(.top, 10)
                }
            }
        }
    }
}

/// Un apoyo (.apoyo): iniciales, nombre, monto, cuándo y el mensaje en globo.
struct FilaApoyo: View {
    let apoyo: Apoyo
    var conAgradecer = true
    @Environment(NavCreador.self) private var nav

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Avatar(imagen: nil, iniciales: apoyo.iniciales, tamano: 40, gris: apoyo.tipo == .unaVez)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(apoyo.nombreVisible).tipo(.texto(15, 700)).foregroundStyle(Color.tinta).lineLimit(1)
                    Spacer(minLength: 8)
                    Text(Plata.texto(apoyo.monto)).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                }
                Text("\(apoyo.tipo == .mensual ? "Te banca cada mes" : "Te bancó una vez") · \(Fecha.hace(apoyo.fecha))")
                    .tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                if !apoyo.mensaje.isEmpty {
                    Text(apoyo.mensaje).tipo(.texto(14, 400)).foregroundStyle(Color.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.fondo, in: UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 14, bottomTrailingRadius: 14, topTrailingRadius: 14))
                        .padding(.top, 6)
                }
                if conAgradecer && !apoyo.anonimo {
                    if apoyo.agradecido {
                        HStack(spacing: 4) {
                            IconoVista(.tilde, tamano: 14)
                            Text("Agradecido").tipo(.texto(13, 600))
                        }
                        .foregroundStyle(Color.gris).padding(.top, 8)
                    } else {
                        Button { nav.abrir(.agradecer(apoyo.id)) } label: {
                            HStack(spacing: 6) {
                                IconoVista(.corazon, tamano: 16)
                                Text("Agradecer").tipo(.texto(14, 700))
                            }
                            .foregroundStyle(Color.esmeralda700)
                            .padding(.horizontal, 12).frame(height: 36)
                            .background(Color.esmeralda100, in: Capsule())
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(Apretable())
                        .padding(.top, 2)
                    }
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

/// Primeros pasos de una cuenta nueva (el «para hacer» que guía).
private struct PrimerosPasos: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        let pasos = estado.primerosPasos
        let hechos = pasos.filter(\.hecho).count
        Tarjeta(relleno: 16) {
            HStack {
                Text("Primeros pasos").tipo(.titulo(20)).foregroundStyle(Color.tinta)
                Spacer()
                Text("\(hechos) de \(pasos.count)").tipo(.texto(14, 700)).foregroundStyle(Color.esmeralda700)
            }
            BarraMeta(fraccion: Double(hechos) / Double(pasos.count), alto: 8).padding(.top, 10).padding(.bottom, 4)
            ForEach(pasos.indices, id: \.self) { i in
                let p = pasos[i]
                Button { ir(i) } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(p.hecho ? Color.esmeralda : Color.white)
                            Circle().strokeBorder(p.hecho ? Color.clear : Color.linea, lineWidth: 2)
                            if p.hecho { IconoVista(.tilde, tamano: 14, grosor: 2.6).foregroundStyle(.white) }
                        }
                        .frame(width: 26, height: 26)
                        Text(p.titulo).tipo(.texto(15, p.hecho ? 400 : 600))
                            .foregroundStyle(p.hecho ? Color.gris : Color.tinta)
                            .strikethrough(p.hecho, color: .gris)
                        Spacer()
                        if !p.hecho { IconoVista(.der, tamano: 16).foregroundStyle(Color.gris) }
                    }
                    .frame(minHeight: 44).contentShape(Rectangle())
                }
                .buttonStyle(Apretable())
                .disabled(p.hecho)
            }
        }
    }

    private func ir(_ i: Int) {
        switch i {
        case 0: nav.ir(.cuentaMP)
        case 1: nav.abrir(.editar(.fotos))
        case 2: nav.ir(.niveles)
        case 3: nav.abrir(.posteo(nil))
        default: nav.abrir(.qr)
        }
    }
}

/// Sin Mercado Pago no entra nada: se avisa arriba de todo.
private struct AvisoConectarMP: View {
    @Environment(NavCreador.self) private var nav
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill").font(.system(size: 20)).foregroundStyle(Color.alerta)
            VStack(alignment: .leading, spacing: 8) {
                Text("Conectá Mercado Pago para recibir apoyos").tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                Text("Hasta que lo hagas, tu página se ve pero el botón de bancar está apagado.").tipo(.texto(14, 400)).foregroundStyle(Color.tinta)
                    .fixedSize(horizontal: false, vertical: true)
                Boton(titulo: "Conectar", variante: .mp, alto: .chico) { nav.ir(.cuentaMP) }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.alerta100, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
    }
}

/// Cuántos hay en cada nivel, con el cupo.
private struct ResumenNiveles: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        let niveles = estado.yo.nivelesActivos
        let maximo = max(1, niveles.map(\.miembros).max() ?? 1)
        VStack(alignment: .leading, spacing: 0) {
            TituloSeccion(texto: "Te bancan cada mes", accion: "Niveles", arriba: 24) { nav.ir(.niveles) }
            Tarjeta(relleno: 16) {
                VStack(spacing: 14) {
                    ForEach(niveles) { n in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(n.nombre).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                                Text(Plata.texto(n.precio)).tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                                Spacer()
                                Text(n.cupo.map { "\(n.miembros) de \($0)" } ?? Plata.numero(n.miembros)).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                            }
                            BarraMeta(fraccion: n.cupo.map { Double(n.miembros) / Double($0) } ?? Double(n.miembros) / Double(maximo), alto: 8,
                                      color: n.lleno ? .alerta : .esmeralda)
                        }
                    }
                    Divisor()
                    HStack {
                        Text("Por mes, con las cuotas de hoy").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                        Spacer()
                        Text(Plata.texto(estado.mensualEsperado)).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                    }
                }
            }
        }
    }
}
