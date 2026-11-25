import SwiftUI

/// Bancar: elegir monto o nivel (pantallas 2 y 3), revisar y pagar (4), el checkout de Mercado Pago y las gracias (5).
struct FlujoApoyo: View {
    let pedido: PedidoFlujo
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var tipo: TipoApoyo
    @State private var nivelId: String?
    @State private var monto: Int
    @State private var otro = false
    @State private var mensaje = ""
    @State private var mostrarNombre = true
    @State private var revisar: Bool
    @State private var checkout: PedidoApoyo?
    @State private var listo: (PedidoApoyo, Recibo)?

    init(pedido: PedidoFlujo) {
        self.pedido = pedido
        _tipo = State(initialValue: pedido.tipo)
        _nivelId = State(initialValue: pedido.nivelId)
        _monto = State(initialValue: 2000)
        _revisar = State(initialValue: pedido.paso == 1)
        if Arranque.actual == .unaVez { _mensaje = State(initialValue: "Para los lápices. Tu gato de la tormenta es mi fondo de pantalla.") }
    }

    var body: some View {
        if let c = estado.creador(pedido.creadorId) {
            Group {
                if let l = listo {
                    Gracias(creador: c, pedido: l.0, recibo: l.1) { cerrar() }
                        .transition(.opacity)
                } else {
                    NavigationStack {
                        elegir(c)
                            .navigationDestination(isPresented: $revisar) { revisa(c) }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.35), value: listo != nil)
            .sheet(item: $checkout) { p in
                CheckoutMP(creador: c, pedido: p) { r in
                    Task {
                        try? await Task.sleep(for: .seconds(0.45))
                        withAnimation { listo = (p, r) }
                    }
                }
                .presentationDetents([.large])
            }
            .onAppear(perform: prepararCaptura)
        }
    }

    private var pedidoActual: PedidoApoyo {
        let n = nivelId.flatMap { estado.creador(pedido.creadorId)?.nivel($0) }
        return PedidoApoyo(creadorId: pedido.creadorId, tipo: tipo, monto: tipo == .mensual ? (n?.precio ?? 0) : monto,
                           nivelId: tipo == .mensual ? nivelId : nil, mensaje: mensaje, mostrarNombre: mostrarNombre)
    }

    // MARK: Elegir

    private func elegir(_ c: Creador) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Titulo(tipo == .unaVez ? "Banc\(c.femenino ? "ala" : "alo") una vez" : "Banc\(c.femenino ? "ala" : "alo") cada mes", tamano: 32)
                Sec(tipo == .unaVez ? "Lo que quieras. Le llega con tu mensaje." : "Elegí cuánto y qué recibís. Cambiás o te das de baja cuando quieras.", tamano: 15)
                    .padding(.top, 6)
                if !c.nivelesActivos.isEmpty {
                    Picker("Cómo", selection: $tipo.animation(.snappy)) {
                        Text("Una vez").tag(TipoApoyo.unaVez)
                        Text("Cada mes").tag(TipoApoyo.mensual)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 16)
                }
                if tipo == .unaVez { unaVez(c) } else { cadaMes(c) }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.top, 6).padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { ticket(c) }
        .toolbar { barra(c) }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if tipo == .mensual && nivelId == nil { nivelId = c.nivelesActivos.first(where: { !$0.lleno })?.id } }
    }

    @ToolbarContentBuilder private func barra(_ c: Creador) -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { cerrar() } label: {
                HStack(spacing: 2) { IconoVista(.atras, tamano: 24); Text(c.primerNombre).tipo(.texto(16, 600)) }
                    .foregroundStyle(Color.tinta)
            }
            .accessibilityLabel("Volver a \(c.nombre)")
        }
        ToolbarItem(placement: .topBarTrailing) { Avatar(c, tamano: 32) }
    }

    private func unaVez(_ c: Creador) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(c.montosSugeridos, id: \.self) { m in
                    BotonMonto(texto: Plata.texto(m), elegido: !otro && monto == m) { otro = false; monto = m }
                }
                BotonMonto(texto: "Otro monto", elegido: otro, chico: true) { otro = true; monto = 0 }
            }
            .padding(.top, 16)
            if otro {
                CampoPlata(etiqueta: "¿Cuánto?", monto: $monto).padding(.top, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            mensajeYNombre(c)
        }
    }

    private func cadaMes(_ c: Creador) -> some View {
        VStack(spacing: 10) {
            ForEach(c.nivelesActivos) { n in
                Button {
                    Haptico.seleccion()
                    withAnimation(.snappy) { nivelId = n.id }
                } label: { TarjetaElegirNivel(nivel: n, elegido: nivelId == n.id) }
                    .buttonStyle(Apretable())
                    .disabled(n.lleno)
            }
        }
        .padding(.top, 18)
    }

    private func mensajeYNombre(_ c: Creador) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Etiqueta("Tu mensaje").padding(.top, 16)
            Campo(etiqueta: "Opcional", texto: $mensaje, placeholder: "Para los lápices.", lineas: 3, limite: 200)
            FilaInterruptor(titulo: "Mostrar mi nombre", sub: mostrarNombre ? nil : "\(c.primerNombre) va a ver «Alguien te bancó».", valor: $mostrarNombre)
                .padding(.top, 4)
        }
    }

    private func ticket(_ c: Creador) -> some View {
        let p = pedidoActual
        let meta = c.metaActiva
        return Ticket(hoy: p.monto,
                      despues: tipo == .unaVez ? "Una sola vez. Va directo al Mercado Pago de \(c.primerNombre)."
                                               : "Después, \(Plata.texto(p.monto)) el \(Fecha.diaDelMes()) de cada mes.",
                      boton: tipo == .unaVez ? "Pagar con Mercado Pago" : "Seguir",
                      variante: tipo == .unaVez ? .mp : .prim,
                      habilitado: p.monto >= 100) {
            if let meta, tipo == .unaVez {
                VStack(alignment: .leading, spacing: 6) {
                    BarraMeta(fraccion: meta.fraccion, vos: Double(p.monto) / Double(max(meta.objetivo, 1)))
                    Text("Suma a «\(meta.titulo)»").tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                }
                .padding(.bottom, 14)
            }
        } accion: {
            Haptico.suave()
            if tipo == .unaVez { checkout = p } else { revisar = true }
        }
    }

    // MARK: Revisá y pagá

    private func revisa(_ c: Creador) -> some View {
        let p = pedidoActual
        let n = c.nivel(nivelId)
        return ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Titulo("Revisá y pagá", tamano: 32)
                Borde(relleno: 16) {
                    HStack(spacing: 12) {
                        Avatar(c, tamano: 48)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(c.nombre).tipo(.texto(16, 700)).foregroundStyle(Color.tinta)
                            Text("\(n?.nombre ?? "") · cada mes").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                        }
                    }
                    .padding(.bottom, 4)
                    FilaDato(etiqueta: "Cada mes", valor: Plata.texto(p.monto))
                    Divisor()
                    FilaDato(etiqueta: "Próximo pago", valor: Fecha.dia(Fecha.proximoMes()))
                    Divisor()
                    FilaDato(etiqueta: "Cómo se paga", valor: "Te avisamos 3 días antes")
                }
                if let actual = estado.membresia(de: c.id), actual.nivelId != nivelId {
                    NotaSegura(texto: "Hoy estás en \(c.nivel(actual.nivelId)?.nombre ?? "otro nivel"). Pasás a \(n?.nombre ?? "") desde este pago.", icono: .capas)
                }
                NotaSegura(texto: "La plata va directo al Mercado Pago de \(c.primerNombre). Bancamos no la toca.")
                Campo(etiqueta: "Un mensaje (opcional)", texto: $mensaje, placeholder: "¡Vamos ese libro!", lineas: 2, limite: 200)
                    .padding(.top, 4)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Ticket(hoy: p.monto, despues: "Te das de baja cuando quieras, con un toque.", boton: "Pagar con Mercado Pago") {
                Haptico.suave()
                checkout = pedidoActual
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { revisar = false } label: {
                    HStack(spacing: 2) { IconoVista(.atras, tamano: 24); Text("Niveles").tipo(.texto(16, 600)) }.foregroundStyle(Color.tinta)
                }
                .accessibilityLabel("Volver a los niveles")
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func prepararCaptura() {
        guard pedido.paso == 2, listo == nil else { return }
        let p = PedidoApoyo(creadorId: pedido.creadorId, tipo: .unaVez, monto: 5000, nivelId: nil, mensaje: "Para los lápices.", mostrarNombre: true)
        let r = Recibo(id: "cap", numero: "BC-418230", creadorId: p.creadorId, concepto: "Bancada", monto: p.monto, fecha: Date(), medio: "Visa •••• 4242", tipo: .unaVez)
        estado.aplicar(p, recibo: r)
        listo = (p, r)
    }
}

/// Un monto para elegir (.monto).
private struct BotonMonto: View {
    let texto: String
    var elegido: Bool
    var chico = false
    var accion: () -> Void

    var body: some View {
        Button {
            Haptico.seleccion()
            withAnimation(.snappy) { accion() }
        } label: {
            Text(texto).tipo(chico ? .texto(16, 700) : .numero(24))
                .foregroundStyle(elegido ? .white : (chico ? Color.gris : Color.tinta))
                .frame(maxWidth: .infinity).frame(height: 64)
                .background(elegido ? Color.tinta : Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(elegido ? .clear : Color.linea, lineWidth: 1.5))
        }
        .buttonStyle(Apretable())
        .accessibilityAddTraits(elegido ? .isSelected : [])
    }
}

/// ¡Gracias! (pantalla 5): papelitos, la meta con lo tuyo y qué sigue.
private struct Gracias: View {
    let creador: Creador
    let pedido: PedidoApoyo
    let recibo: Recibo
    var listo: () -> Void
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav
    @State private var ver = false

    var body: some View {
        let c = estado.creador(creador.id) ?? creador
        let meta = c.metaActiva
        ZStack {
            Color.white.ignoresSafeArea()
            Papelitos()
            ScrollView {
                VStack(spacing: 0) {
                    Avatar(c, tamano: 104, aro: 5)
                        .shadow(color: .black.opacity(0.14), radius: 13, y: 12)
                        .padding(.top, 30)
                        .scaleEffect(ver ? 1 : 0.7)
                    Titulo(meta?.lograda == true ? "¡Llegaron a la meta!" : "¡Gracias, \(estado.fan.nombre.split(separator: " ").first.map(String.init) ?? "")!", tamano: 40)
                        .multilineTextAlignment(.center).padding(.top, 22)
                    Text("\(c.primerNombre) ya se enteró.").tipo(.texto(17, 400)).foregroundStyle(Color.gris).padding(.top, 8)
                    VStack(spacing: 10) {
                        if let meta {
                            Tarjeta(relleno: 16) {
                                Etiqueta(meta.titulo)
                                HStack(alignment: .firstTextBaseline) {
                                    Text(Plata.texto(meta.recaudado)).tipo(.numero(28)).foregroundStyle(Color.tinta)
                                    Spacer()
                                    Text("de \(Plata.texto(meta.objetivo))").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                                }
                                .padding(.top, 8)
                                BarraMeta(fraccion: Double(meta.recaudado - pedido.monto) / Double(max(meta.objetivo, 1)),
                                          vos: ver ? Double(pedido.monto) / Double(max(meta.objetivo, 1)) : 0)
                                    .padding(.top, 10)
                                Text(meta.lograda ? "Con lo tuyo, llegaron al 100 %." : "Con lo tuyo, llegaron al \(meta.porcentaje) %.")
                                    .tipo(.texto(14, 400)).foregroundStyle(Color.gris).padding(.top, 8)
                            }
                        }
                        if pedido.tipo == .mensual, let n = c.nivel(pedido.nivelId) {
                            Tarjeta(relleno: 14) {
                                HStack(spacing: 12) {
                                    Chip(texto: n.nombre, tono: .ok, icono: .tilde)
                                    Text("Ya ves todo lo de \(n.nombre). Próximo pago, el \(Fecha.corta(Fecha.proximoMes())).")
                                        .tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                                }
                            }
                        }
                        Tarjeta(relleno: 16) {
                            HStack(alignment: .top, spacing: 10) {
                                Avatar(c, tamano: 32)
                                Text("«\(c.agradecimiento)»").tipo(.texto(15, 500)).foregroundStyle(Color.tinta).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Text("Recibo \(recibo.numero) · te lo mandamos por mail.").tipo(.texto(13, 500)).foregroundStyle(Color.gris)
                    }
                    .padding(.horizontal, Espacio.margen).padding(.top, 26)
                }
                .padding(.bottom, 24)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Boton(titulo: pedido.tipo == .mensual ? "Ver lo de \(c.nivel(pedido.nivelId)?.nombre ?? "")" : "Volver a \(c.primerNombre)", alto: .alto, ancho: true) {
                    listo()
                }
                ShareLink(item: c.url, message: Text("Yo banco a \(c.nombre) en Bancamos. ¡Sumate!")) {
                    HStack(spacing: 8) { IconoVista(.compartir, tamano: 20); Text("Compartir la meta").tipo(.texto(16, 700)) }
                        .foregroundStyle(Color.tinta).frame(maxWidth: .infinity).frame(height: 52)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.control))
                        .overlay(RoundedRectangle(cornerRadius: Radio.control).strokeBorder(Color.linea, lineWidth: 1.5))
                }
            }
            .padding(.horizontal, Espacio.margen).padding(.bottom, 8)
        }
        .onAppear {
            Haptico.exito()
            withAnimation(.spring(duration: 0.9, bounce: 0.3).delay(0.2)) { ver = true }
        }
    }
}
