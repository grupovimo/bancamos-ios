import SwiftUI

/// «A quién bancás» (pantalla 10): las membresías, lo que hay que pagar y a quién seguís.
struct ABancas: View {
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Etiqueta(estado.fan.nombre)
                Titulo("A quién bancás", tamano: 34).padding(.top, 4)
                if estado.fan.membresias.isEmpty {
                    Sec("Cuando bancás a alguien cada mes, lo ves acá.", tamano: 15).padding(.top, 6)
                    Tarjeta {
                        EstadoVacio(icono: .corazon, titulo: "Todavía no bancás a nadie",
                                    texto: "Encontrá a quien te alegra el día y bancalo con un mensaje, una vez o cada mes.",
                                    accion: "Explorar") { withAnimation { nav.pestana = "explorar" } }
                    }
                    .padding(.top, 18)
                } else {
                    Sec("Este mes, \(Plata.texto(estado.totalMensual)) entre \(Texto.plural(estado.fan.membresias.count, "persona", "personas")).", tamano: 15)
                        .padding(.top, 6)
                    VStack(spacing: 10) {
                        ForEach(estado.fan.membresias) { m in
                            if let c = estado.creador(m.creadorId) {
                                TarjetaMembresia(membresia: m, creador: c)
                            }
                        }
                    }
                    .padding(.top, 18)
                }
                let siguiendo = estado.fan.siguiendo.compactMap { estado.creador($0) }.filter { estado.membresia(de: $0.id) == nil }
                if !siguiendo.isEmpty {
                    TituloSeccion(texto: "Seguís")
                    Tarjeta {
                        ForEach(Array(siguiendo.enumerated()), id: \.element.id) { i, c in
                            if i > 0 { Divisor(izquierda: 80) }
                            Button { nav.ir(.creador(c.id)) } label: { FilaCreador(creador: c) }.buttonStyle(Apretable())
                        }
                    }
                }
                BannerGrupo(.laColumna).padding(.top, 18)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.top, 12)
            .padding(.bottom, Espacio.bajoBarra)
        }
        .background(Color.fondo)
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// Una membresía (.banc): quién, nivel, si está al día o hay que pagar, y su meta.
private struct TarjetaMembresia: View {
    let membresia: Membresia
    let creador: Creador
    @Environment(NavFan.self) private var nav

    var body: some View {
        Button { nav.ir(.membresia(membresia.id)) } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Avatar(creador, tamano: 48)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(creador.nombre).tipo(.texto(16, 700)).foregroundStyle(Color.tinta)
                        Text(membresia.estado == .porPagar ? "Vence el \(Fecha.corta(membresia.proximoPago)) · \(Plata.texto(membresia.monto))"
                                                           : "\(creador.nivel(membresia.nivelId)?.nombre ?? "") · \(Plata.texto(membresia.monto)) por mes")
                            .tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                    }
                    Spacer(minLength: 6)
                    if membresia.estado == .porPagar {
                        Button {
                            Haptico.suave()
                            nav.flujo = PedidoFlujo(creadorId: creador.id, tipo: .mensual, nivelId: membresia.nivelId, paso: 1)
                        } label: {
                            Text("Pagar").tipo(.texto(15, 700)).foregroundStyle(.white)
                                .padding(.horizontal, 14).frame(height: 40)
                                .background(Color.esmeralda700, in: RoundedRectangle(cornerRadius: 12))
                                .frame(minHeight: 44).contentShape(Rectangle())
                        }
                        .buttonStyle(Apretable())
                        .accessibilityLabel("Pagar la cuota de \(creador.nombre)")
                    } else {
                        Chip(texto: "Al día", tono: .ok)
                    }
                }
                if let m = creador.metaActiva {
                    VStack(alignment: .leading, spacing: 6) {
                        BarraMeta(fraccion: m.fraccion)
                        Text("\(m.titulo) · \(m.porcentaje) %").tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
            .sombra()
        }
        .buttonStyle(Apretable())
    }
}

/// Una membresía: cambiar de nivel, pagar, ver los pagos y darse de baja con un toque.
struct DetalleMembresia: View {
    let membresiaId: String
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav
    @Environment(\.dismiss) private var volver
    @State private var nivel: String?
    @State private var baja = false

    var body: some View {
        if let m = estado.fan.membresias.first(where: { $0.id == membresiaId }), let c = estado.creador(m.creadorId) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Button { nav.ir(.creador(c.id)) } label: {
                        HStack(spacing: 12) {
                            Avatar(c, tamano: 56)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(c.nombre).tipo(.titulo(22)).foregroundStyle(Color.tinta)
                                Text("\(c.lo.capitalizedPrimera) bancás desde el \(Fecha.dia(m.desde))").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                            }
                            Spacer()
                            IconoVista(.der, tamano: 16).foregroundStyle(Color.gris)
                        }
                    }
                    .buttonStyle(Apretable())
                    Tarjeta(relleno: 16) {
                        FilaDato(etiqueta: "Nivel", valor: c.nivel(m.nivelId)?.nombre ?? "")
                        Divisor()
                        FilaDato(etiqueta: "Cada mes", valor: Plata.texto(m.monto))
                        Divisor()
                        FilaDato(etiqueta: "Próximo pago", valor: Fecha.dia(m.proximoPago),
                                 colorValor: m.estado == .porPagar ? .alerta : .tinta)
                        Divisor()
                        FilaDato(etiqueta: "Cómo se paga", valor: "Te avisamos 3 días antes")
                    }
                    .padding(.top, 18)
                    if m.estado == .porPagar {
                        Boton(titulo: "Pagar \(Plata.texto(m.monto))", variante: .mp, alto: .alto, ancho: true) {
                            nav.flujo = PedidoFlujo(creadorId: c.id, tipo: .mensual, nivelId: m.nivelId, paso: 1)
                        }
                        .padding(.top, 12)
                    }
                    TituloSeccion(texto: "Cambiar de nivel")
                    VStack(spacing: 10) {
                        ForEach(c.nivelesActivos) { n in
                            Button {
                                Haptico.seleccion()
                                withAnimation(.snappy) { nivel = n.id }
                            } label: { TarjetaElegirNivel(nivel: n, elegido: (nivel ?? m.nivelId) == n.id) }
                                .buttonStyle(Apretable())
                                .disabled(n.lleno && n.id != m.nivelId)
                        }
                    }
                    if let nuevo = nivel, nuevo != m.nivelId, let n = c.nivel(nuevo) {
                        Boton(titulo: "Pasar a \(n.nombre) · \(Plata.texto(n.precio))", alto: .alto, ancho: true) {
                            estado.cambiarNivel(membresiaId: m.id, a: nuevo)
                            nivel = nil
                        }
                        .padding(.top, 12)
                        .transition(.opacity)
                    }
                    let pagos = estado.fan.recibos.filter { $0.creadorId == c.id }
                    if !pagos.isEmpty {
                        TituloSeccion(texto: "Tus pagos")
                        Tarjeta {
                            ForEach(Array(pagos.enumerated()), id: \.element.id) { i, r in
                                if i > 0 { Divisor(izquierda: 16) }
                                Button { nav.ir(.recibo(r.id)) } label: { FilaRecibo(recibo: r, creador: c) }.buttonStyle(Apretable())
                            }
                        }
                    }
                    Boton(titulo: "Darme de baja", variante: .peligro, alto: .normal, ancho: true) { baja = true }
                        .padding(.top, 24)
                    Text("Sin vueltas: dejás de pagar desde el próximo mes y seguís viendo lo de tu nivel hasta el \(Fecha.corta(m.proximoPago)).")
                        .tipo(.texto(13, 400)).foregroundStyle(Color.gris).padding(.top, 8)
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.bottom, 40)
            }
            .background(Color.fondo)
            .navigationTitle("Tu membresía")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("¿Te das de baja de \(c.nivel(m.nivelId)?.nombre ?? "")?", isPresented: $baja, titleVisibility: .visible) {
                Button("Darme de baja", role: .destructive) { estado.cancelar(membresiaId: m.id); volver() }
                Button("Mejor no", role: .cancel) {}
            } message: { Text("No se te cobra más. \(c.primerNombre) no se entera de por qué, y podés volver cuando quieras.") }
        } else {
            EstadoVacio(icono: .corazon, titulo: "Ya no bancás a esta persona", texto: "Te diste de baja. Podés volver cuando quieras desde su página.")
        }
    }
}

/// Lo nuevo de quienes bancás y seguís.
struct Novedades: View {
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                let lista = estado.novedades
                if lista.isEmpty {
                    Tarjeta {
                        EstadoVacio(icono: .texto, titulo: "Acá van a estar las novedades",
                                    texto: "Seguí o bancá a alguien y lo que publique te aparece acá.",
                                    accion: "Explorar") { withAnimation { nav.pestana = "explorar" } }
                    }
                }
                ForEach(lista, id: \.posteo.id) { item in
                    let abierto = item.creador.puedeVer(item.posteo, nivelId: estado.nivelDelFan(en: item.creador.id))
                    TarjetaPosteo(creador: item.creador, posteo: item.posteo, bloqueado: !abierto,
                                  meGusta: { estado.meGusta(item.posteo.id, creadorId: item.creador.id) },
                                  desbloquear: { nav.bancar(item.creador.id, .mensual) })
                        .onTapGesture { if abierto { nav.ir(.posteo(item.creador.id, item.posteo.id)) } }
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.top, 4)
            .padding(.bottom, Espacio.bajoBarra)
        }
        .background(Color.fondo)
        .navigationTitle("Novedades")
        .refreshable { await estado.cargar() }
    }
}
