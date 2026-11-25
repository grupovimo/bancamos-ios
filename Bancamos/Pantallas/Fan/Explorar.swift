import SwiftUI

/// Explorar: buscar, categorías, destacados, cerca tuyo y lo de tus intereses.
struct Explorar: View {
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav
    @State private var busqueda = Arranque.actual == .buscar ? "cocina" : ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if busqueda.limpio.isEmpty { portada } else { resultados }
            }
            .padding(.bottom, Espacio.bajoBarra)
        }
        .background(Color.fondo)
        .navigationTitle("Explorar")
        .searchable(text: $busqueda, placement: .navigationBarDrawer(displayMode: .always), prompt: "Buscar personas, rubros o ciudades")
    }

    @ViewBuilder private var portada: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Categoria.allCases) { c in
                    ChipOpcion(titulo: c.nombre, simbolo: c.simbolo, elegido: false) { nav.ir(.categoria(c)) }
                }
            }
            .padding(.horizontal, Espacio.margen)
        }
        .padding(.top, 4)
        TituloSeccion(texto: "Destacados", arriba: 22).padding(.horizontal, Espacio.margen)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(estado.destacados) { c in
                    Button { nav.ir(.creador(c.id)) } label: { TarjetaCreador(creador: c) }.buttonStyle(Apretable())
                }
            }
            .padding(.horizontal, Espacio.margen).padding(.bottom, 16)
        }
        .scrollTargetBehavior(.viewAligned)
        if !estado.cercaTuyo.isEmpty {
            TituloSeccion(texto: "Cerca tuyo", arriba: 10).padding(.horizontal, Espacio.margen)
            lista(estado.cercaTuyo, distancia: true)
        }
        let gusto = estado.creadores.filter { estado.fan.intereses.contains($0.categoria) }
        if !gusto.isEmpty {
            TituloSeccion(texto: "Por lo que te gusta").padding(.horizontal, Espacio.margen)
            lista(gusto, distancia: false)
        }
        TituloSeccion(texto: "Todos").padding(.horizontal, Espacio.margen)
        lista(estado.creadores.sorted { $0.mensuales > $1.mensuales }, distancia: false)
    }

    @ViewBuilder private var resultados: some View {
        let r = estado.buscar(busqueda)
        if r.isEmpty {
            EstadoVacio(icono: .lupa, titulo: "No encontramos a nadie", texto: "Probá con otro nombre, un rubro («música», «cocina») o una ciudad.")
                .padding(.top, 30)
        } else {
            Text(Texto.plural(r.count, "resultado", "resultados")).tipo(.texto(14, 600)).foregroundStyle(Color.gris)
                .padding(.horizontal, Espacio.margen).padding(.top, 8).padding(.bottom, 10)
            lista(r, distancia: false)
        }
    }

    private func lista(_ cs: [Creador], distancia: Bool) -> some View {
        Tarjeta {
            ForEach(Array(cs.enumerated()), id: \.element.id) { i, c in
                if i > 0 { Divisor(izquierda: 80) }
                Button { nav.ir(.creador(c.id)) } label: { FilaCreador(creador: c, distancia: distancia) }.buttonStyle(Apretable())
            }
        }
        .padding(.horizontal, Espacio.margen)
    }
}

/// Tarjeta grande de un creador (destacados): portada, foto, nombre y su meta.
struct TarjetaCreador: View {
    let creador: Creador
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FotoRecortada(imagen: creador.portada, zoom: 1.1).frame(height: 150)
            VStack(alignment: .leading, spacing: 0) {
                Avatar(creador, tamano: 52, aro: 3).padding(.top, -26)
                Text(creador.nombre).tipo(.texto(17, 700)).foregroundStyle(Color.tinta).padding(.top, 6)
                Text(creador.frase).tipo(.texto(14, 400)).foregroundStyle(Color.gris).lineLimit(1)
                if let m = creador.metaActiva {
                    BarraMeta(fraccion: m.fraccion, alto: 8).padding(.top, 12)
                    Text("\(m.porcentaje) % · \(m.titulo)").tipo(.texto(13, 500)).foregroundStyle(Color.gris).lineLimit(1).padding(.top, 6)
                }
            }
            .padding(.horizontal, 14).padding(.bottom, 14)
        }
        .frame(width: 270)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .sombra()
        .accessibilityElement(children: .combine)
    }
}

struct FilaCreador: View {
    let creador: Creador
    var distancia = false
    var body: some View {
        HStack(spacing: 12) {
            Avatar(creador, tamano: 52)
            VStack(alignment: .leading, spacing: 3) {
                Text(creador.nombre).tipo(.texto(16, 700)).foregroundStyle(Color.tinta)
                Text(distancia ? "\(creador.categoria.nombre) · a \(String(format: "%.1f", creador.distanciaKm ?? 0).replacingOccurrences(of: ".", with: ",")) km"
                               : "\(creador.categoria.nombre) · \(creador.ciudad)")
                    .tipo(.texto(13, 400)).foregroundStyle(Color.gris).lineLimit(1)
                if let m = creador.metaActiva { BarraMeta(fraccion: m.fraccion, alto: 6).frame(maxWidth: 160).padding(.top, 3) }
            }
            Spacer(minLength: 6)
            if let d = creador.desde {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("desde").tipo(.texto(11, 500)).foregroundStyle(Color.gris)
                    Text(Plata.texto(d)).tipo(.texto(14, 700)).foregroundStyle(Color.tinta)
                }
            }
        }
        .padding(.horizontal, 16).frame(minHeight: 76).contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

struct ListaCategoria: View {
    let categoria: Categoria
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav

    var body: some View {
        let cs = estado.deCategoria(categoria)
        ScrollView {
            VStack(spacing: 12) {
                if cs.isEmpty {
                    EstadoVacio(icono: .lupa, titulo: "Todavía no hay nadie en \(categoria.nombre.lowercased())",
                                texto: "¿Conocés a alguien que haga esto? Contale de Bancamos.")
                }
                ForEach(cs) { c in
                    Button { nav.ir(.creador(c.id)) } label: { TarjetaCreador(creador: c).frame(maxWidth: .infinity) }
                        .buttonStyle(Apretable())
                }
            }
            .padding(.horizontal, Espacio.margen).padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle(categoria.nombre)
    }
}

/// La página de un creador para el que banca (con seguir, bancar y abrir posteos).
struct PaginaCreadorFan: View {
    let creadorId: String
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav
    @Environment(\.dismiss) private var volver

    var body: some View {
        if let c = estado.creador(creadorId) {
            PaginaPublica(creador: c, nivelVisitante: estado.nivelDelFan(en: c.id), sigue: estado.sigue(c.id), volver: { volver() },
                          bancar: { tipo, nivel in nav.bancar(c.id, tipo, nivel: nivel) },
                          abrirPosteo: { p in nav.ir(.posteo(c.id, p.id)) },
                          seguir: { estado.seguir(c.id) },
                          gestionar: { if let m = estado.membresia(de: c.id) { nav.ir(.membresia(m.id)) } })
                .toolbar(.hidden, for: .navigationBar)
        } else {
            EstadoVacio(icono: .persona, titulo: "Esta página no existe", texto: "Puede que haya cambiado su link.")
        }
    }
}

/// Un posteo abierto (o con candado si no alcanza el nivel).
struct DetallePosteoFan: View {
    let creadorId: String
    let posteoId: String
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav

    var body: some View {
        if let c = estado.creador(creadorId), let p = c.posteos.first(where: { $0.id == posteoId }) {
            let abierto = c.puedeVer(p, nivelId: estado.nivelDelFan(en: c.id))
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    TarjetaPosteo(creador: c, posteo: p, bloqueado: !abierto,
                                  meGusta: { estado.meGusta(p.id, creadorId: c.id) },
                                  desbloquear: { nav.bancar(c.id, .mensual) })
                    if abierto {
                        Text(p.texto).tipo(.texto(16, 400)).foregroundStyle(Color.tinta).lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, Espacio.margen).padding(.bottom, 40)
            }
            .background(Color.fondo)
            .navigationTitle(c.primerNombre)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
