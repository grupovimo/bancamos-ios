import SwiftUI

/// La página de un creador como la ve la gente (pantalla 1). La usan el que banca y el creador en «Así te ven».
struct PaginaPublica: View {
    let creador: Creador
    /// El nivel del que mira (nil si no banca).
    var nivelVisitante: String? = nil
    var sigue = false
    var vistaPrevia = false
    var recibePagos = true
    var volver: (() -> Void)? = nil
    var bancar: (TipoApoyo, String?) -> Void = { _, _ in }
    var abrirPosteo: (Posteo) -> Void = { _ in }
    var seguir: () -> Void = {}
    var gestionar: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Portada(creador: creador)
                Encabezado(creador: creador, sigue: sigue, vistaPrevia: vistaPrevia, seguir: seguir)
                VStack(alignment: .leading, spacing: 0) {
                    if let m = creador.metaActiva {
                        TarjetaMeta(meta: m, pie: "\(Plata.numero(creador.mensuales)) \(creador.lo) bancan cada mes · \(Plata.numero(creador.bancadas)) bancadas")
                            .padding(.top, 16)
                    }
                    botones.padding(.top, 12)
                    if !recibePagos {
                        Text("Todavía no recibe apoyos: falta conectar Mercado Pago.").tipo(.texto(13, 500)).foregroundStyle(Color.alerta).padding(.top, 8)
                    }
                    SeccionExclusivo(creador: creador, nivelVisitante: nivelVisitante, abrir: abrirPosteo, bancar: { bancar(.mensual, nil) })
                    SeccionNiveles(creador: creador, nivelVisitante: nivelVisitante, habilitado: recibePagos) { bancar(.mensual, $0) }
                    if !creador.sobreMi.isEmpty {
                        TituloSeccion(texto: "Sobre \(creador.primerNombre)", arriba: 26)
                        Text(creador.sobreMi).tipo(.texto(16, 400)).foregroundStyle(Color.tinta).lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(creador.redes, id: \.self) { r in
                            HStack(spacing: 8) {
                                IconoVista(.link, tamano: 16).foregroundStyle(Color.esmeralda700)
                                Text(r).tipo(.texto(15, 600)).foregroundStyle(Color.esmeralda700)
                            }
                            .padding(.top, 10)
                        }
                    }
                    NotaSegura(texto: "La plata va directo al Mercado Pago de \(creador.primerNombre). Bancamos no la toca.").padding(.top, 26)
                    if !vistaPrevia {
                        Button { } label: {
                            Text("Denunciar esta página").tipo(.texto(13, 600)).foregroundStyle(Color.gris).frame(minHeight: 44)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.bottom, vistaPrevia ? 40 : Espacio.bajoBarra)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.white)
        .overlay(alignment: .top) { barraArriba }
    }

    @ViewBuilder private var botones: some View {
        if let n = nivelVisitante, let nivel = creador.nivel(n) {
            HStack(spacing: 10) {
                Boton(titulo: "Banc\(creador.femenino ? "ala" : "alo") una vez", variante: .prim, alto: .normal, ancho: true, habilitado: recibePagos) { bancar(.unaVez, nil) }
                Button(action: gestionar) {
                    HStack(spacing: 6) {
                        IconoVista(.tilde, tamano: 16)
                        Text(nivel.nombre).tipo(.texto(16, 700))
                    }
                    .foregroundStyle(Color.esmeralda700)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color.esmeralda100, in: RoundedRectangle(cornerRadius: Radio.control))
                }
                .buttonStyle(Apretable())
                .accessibilityLabel("Ya \(creador.lo) bancás en \(nivel.nombre). Cambiar o dar de baja.")
            }
        } else {
            HStack(spacing: 10) {
                Boton(titulo: "Banc\(creador.femenino ? "ala" : "alo") una vez", variante: .prim, alto: .normal, ancho: true, habilitado: recibePagos) { bancar(.unaVez, nil) }
                Boton(titulo: "Cada mes", variante: .osc, alto: .normal, ancho: true, habilitado: recibePagos && !creador.nivelesActivos.isEmpty) { bancar(.mensual, nil) }
            }
        }
    }

    private var barraArriba: some View {
        HStack {
            if let volver { BotonRedondo(icono: .atras, etiqueta: "Volver", accion: volver) }
            Spacer()
            if !vistaPrevia {
                ShareLink(item: creador.url, subject: Text(creador.nombre), message: Text("Mirá a \(creador.nombre) en Bancamos")) {
                    IconoVista(.compartir, tamano: 20).foregroundStyle(Color.tinta)
                        .frame(width: 44, height: 44).background(Color.white, in: Circle())
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 2)
                }
                .accessibilityLabel("Compartir la página")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

private struct Portada: View {
    let creador: Creador
    var body: some View {
        FotoRecortada(imagen: creador.portada, zoom: 1)
            .frame(height: 290)
            .overlay(alignment: .top) {
                LinearGradient(colors: [.white.opacity(0.7), .white.opacity(0)], startPoint: .top, endPoint: .bottom).frame(height: 110)
            }
    }
}

private struct Encabezado: View {
    let creador: Creador
    var sigue: Bool
    var vistaPrevia: Bool
    var seguir: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom) {
                Avatar(creador, tamano: 88, aro: 4)
                    .shadow(color: .black.opacity(0.12), radius: 9, y: 8)
                Spacer()
                if !vistaPrevia {
                    Button(action: seguir) {
                        Text(sigue ? "Siguiendo" : "Seguir").tipo(.texto(15, 700))
                            .foregroundStyle(sigue ? Color.tinta : .white)
                            .padding(.horizontal, 18).frame(height: 40)
                            .background(sigue ? Color.fondo : Color.tinta, in: Capsule())
                            .frame(minHeight: 44).contentShape(Rectangle())
                    }
                    .buttonStyle(Apretable())
                    .accessibilityLabel(sigue ? "Dejar de seguir" : "Seguir a \(creador.nombre)")
                }
            }
            .padding(.top, -44)
            Text(creador.nombre).tipo(.titulo(30)).foregroundStyle(Color.tinta).padding(.top, 10)
            Text([creador.frase, creador.ciudad.isEmpty ? nil : "\(creador.ciudad)."].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " "))
                .tipo(.texto(15, 400)).foregroundStyle(Color.gris).padding(.top, 4)
            HStack(spacing: 8) {
                Chip(texto: creador.categoria.nombre, tono: .gris)
                Text(creador.link).tipo(.texto(13, 500)).foregroundStyle(Color.gris)
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, Espacio.margen)
    }
}

/// «Para los que la bancan»: los posteos, abiertos o con candado.
private struct SeccionExclusivo: View {
    let creador: Creador
    var nivelVisitante: String?
    var abrir: (Posteo) -> Void
    var bancar: () -> Void

    var body: some View {
        let posteos = creador.posteos.filter { !$0.esProgramado }
        if !posteos.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                TituloSeccion(texto: "Para los que \(creador.lo) bancan", arriba: 24)
                ForEach(posteos.prefix(4)) { p in
                    let abierto = creador.puedeVer(p, nivelId: nivelVisitante)
                    Button { if abierto { abrir(p) } else { bancar() } } label: { fila(p, abierto: abierto) }
                        .buttonStyle(Apretable())
                        .accessibilityLabel(abierto ? p.titulo : "\(p.titulo). Bloqueado: para \(creador.publicoTexto(p.publico)).")
                }
            }
        }
    }

    private func fila(_ p: Posteo, abierto: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                if let f = p.fotos.first {
                    FotoRecortada(imagen: f, zoom: f.zoom / 1.4).blur(radius: abierto ? 0 : 6)
                        .overlay(abierto ? Color.clear : Color.tinta.opacity(0.3))
                } else {
                    Color.esmeralda100
                }
                if !abierto { IconoVista(.candado, tamano: 20).foregroundStyle(p.fotos.isEmpty ? Color.esmeralda700 : .white) }
                else if p.fotos.isEmpty { IconoVista(p.tipo.icono, tamano: 22).foregroundStyle(Color.esmeralda700) }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(p.titulo).tipo(.texto(15, 700)).foregroundStyle(Color.tinta).lineLimit(2).multilineTextAlignment(.leading)
                Text(detalle(p)).tipo(.texto(14, 400)).foregroundStyle(Color.gris)
            }
            Spacer(minLength: 4)
            if !abierto, case .desde(let id) = p.publico, let n = creador.nivel(id) {
                Chip(texto: n.nombre, tono: .gris, icono: .candado)
            } else if !abierto {
                Chip(texto: "Socios", tono: .gris, icono: .candado)
            }
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous).strokeBorder(Color.linea, lineWidth: 1.5))
    }

    private func detalle(_ p: Posteo) -> String {
        switch p.tipo {
        case .fotos: return p.fotos.count > 1 ? "Paso a paso · \(p.fotos.count) fotos" : "Foto · \(Fecha.hace(p.fecha))"
        case .audio: return "Audio · \(p.audioSegundos / 60) min"
        case .texto: return "Texto · \(Fecha.hace(p.fecha))"
        }
    }
}

/// Los niveles para elegir (.nivel).
private struct SeccionNiveles: View {
    let creador: Creador
    var nivelVisitante: String?
    var habilitado: Bool
    var elegir: (String) -> Void

    var body: some View {
        let niveles = creador.nivelesActivos
        if !niveles.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                TituloSeccion(texto: "Banc\(creador.femenino ? "ala" : "alo") cada mes", arriba: 24)
                ForEach(niveles) { n in
                    Button { elegir(n.id) } label: { TarjetaElegirNivel(nivel: n, elegido: n.id == nivelVisitante, conRadio: false) }
                        .buttonStyle(Apretable())
                        .disabled(!habilitado || (n.lleno && n.id != nivelVisitante))
                }
            }
        }
    }
}

/// Un nivel para elegir (.nivel / .nivel.on): radio, nombre, precio, qué incluye y el cupo.
struct TarjetaElegirNivel: View {
    let nivel: Nivel
    var elegido: Bool
    var conRadio = true

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if conRadio {
                Circle().strokeBorder(elegido ? Color.tinta : Color.linea, lineWidth: elegido ? 7 : 2)
                    .frame(width: 24, height: 24).padding(.top, 2)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(nivel.nombre).tipo(.titulo(20)).foregroundStyle(Color.tinta)
                    Spacer(minLength: 4)
                    Text(Plata.texto(nivel.precio)).tipo(.texto(16, 600)).foregroundStyle(Color.tinta)
                    Text("por mes").tipo(.texto(13, 600)).foregroundStyle(Color.gris)
                }
                Text(nivel.descripcion).tipo(.texto(14, 400)).foregroundStyle(Color.gris).multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                if let q = nivel.quedan, q <= 10 {
                    Chip(texto: q == 0 ? "Cupo lleno" : "Quedan \(q) de \(nivel.cupo ?? 0)", tono: .alerta).padding(.top, 4)
                }
                if !conRadio && elegido { Chip(texto: "Tu nivel", tono: .ok, icono: .tilde).padding(.top, 4) }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(elegido ? Color.esmeralda50 : Color.white, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous).strokeBorder(elegido ? Color.tinta : Color.linea, lineWidth: elegido ? 2 : 1.5))
        .opacity(nivel.lleno && !elegido ? 0.55 : 1)
        .accessibilityAddTraits(elegido ? .isSelected : [])
    }
}
