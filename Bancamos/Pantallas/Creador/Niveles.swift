import SwiftUI

/// Los niveles (membresías): cuántos hay en cada uno, y crear, editar o pausar.
struct Niveles: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Sec("Lo que paga cada mes quien te banca y lo que recibe. Cambiás el precio y vale desde el próximo pago.", tamano: 15)
                    .padding(.bottom, 6)
                let niveles = estado.yo.niveles.sorted { $0.precio < $1.precio }
                if niveles.isEmpty {
                    Tarjeta {
                        EstadoVacio(icono: .capas, titulo: "Todavía no tenés niveles", texto: "Con dos o tres niveles claros, la gente elige cuánto bancarte cada mes.",
                                    accion: "Crear un nivel") { nav.abrir(.nivel(nil)) }
                    }
                }
                ForEach(niveles) { n in TarjetaNivel(nivel: n) }
                if !niveles.isEmpty {
                    Boton(titulo: "Nivel nuevo", icono: .mas, variante: .blanco, alto: .normal, ancho: true) { nav.abrir(.nivel(nil)) }
                        .padding(.top, 6)
                    Text("Por cada cuota, Bancamos se queda con el 3 % y Mercado Pago cobra lo suyo aparte. Lo demás llega directo a tu cuenta.")
                        .tipo(.texto(13, 400)).foregroundStyle(Color.gris).padding(.top, 6)
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Niveles")
    }
}

private struct TarjetaNivel: View {
    let nivel: Nivel
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @State private var borrar = false

    var body: some View {
        Tarjeta(relleno: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(nivel.nombre).tipo(.titulo(22)).foregroundStyle(nivel.pausado ? Color.gris : Color.tinta)
                Spacer()
                Text(Plata.texto(nivel.precio)).tipo(.numero(22)).foregroundStyle(Color.tinta)
                Text("por mes").tipo(.texto(13, 600)).foregroundStyle(Color.gris)
            }
            Text(nivel.descripcion).tipo(.texto(14, 400)).foregroundStyle(Color.gris).padding(.top, 4)
            HStack(spacing: 8) {
                Chip(texto: Texto.plural(nivel.miembros, "persona", "personas"), tono: .marca, icono: .gente)
                if let q = nivel.quedan { Chip(texto: q == 0 ? "Cupo lleno" : "Quedan \(q) de \(nivel.cupo!)", tono: q == 0 ? .alerta : .gris) }
                if nivel.pausado { Chip(texto: "Pausado", tono: .alerta, icono: .pausa) }
            }
            .padding(.top, 10)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(nivel.incluye, id: \.self) { i in
                    HStack(spacing: 8) {
                        IconoVista(.tilde, tamano: 16).foregroundStyle(Color.ok)
                        Text(i).tipo(.texto(14, 400)).foregroundStyle(Color.tinta)
                    }
                }
            }
            .padding(.top, 12)
            Divisor().padding(.vertical, 12)
            HStack(spacing: 8) {
                Boton(titulo: "Editar", icono: .lapiz, variante: .blanco, alto: .chico, ancho: true) { nav.abrir(.nivel(nivel)) }
                Boton(titulo: nivel.pausado ? "Activar" : "Pausar", icono: nivel.pausado ? .play : .pausa, variante: .blanco, alto: .chico, ancho: true) {
                    estado.pausar(nivelId: nivel.id)
                }
                if nivel.miembros == 0 {
                    Button { borrar = true } label: {
                        IconoVista(.basura, tamano: 20).foregroundStyle(Color.error).frame(width: 44, height: 44)
                            .background(Color.error100, in: RoundedRectangle(cornerRadius: Radio.control))
                    }
                    .accessibilityLabel("Borrar \(nivel.nombre)")
                }
            }
        }
        .opacity(nivel.pausado ? 0.8 : 1)
        .confirmationDialog("¿Borrar \(nivel.nombre)?", isPresented: $borrar, titleVisibility: .visible) {
            Button("Borrar", role: .destructive) { estado.borrar(nivelId: nivel.id) }
        }
    }
}

/// Nivel nuevo (pantalla 7): vista previa, nombre, precio, qué incluye, cupo y la cuenta de lo que llega.
struct EditorNivel: View {
    var original: Nivel?
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var n: Nivel
    @State private var conCupo: Bool
    @State private var nuevoItem = ""

    init(original: Nivel?) {
        self.original = original
        var base = original ?? Nivel(id: UUID().uuidString, nombre: "", precio: 0, descripcion: "", incluye: [], cupo: nil, miembros: 0)
        if original == nil && Arranque.actual == .nivelNuevo {
            base = Nivel(id: "nuevo", nombre: "Mecenas", precio: 20000, descripcion: "Todo lo anterior y tu nombre en la tapa del libro.",
                         incluye: ["Todo lo de Original", "Tu nombre en la tapa del libro"], cupo: 10, miembros: 0)
        }
        _n = State(initialValue: base)
        _conCupo = State(initialValue: base.cupo != nil)
    }

    private var listo: Bool { !n.nombre.limpio.isEmpty && n.precio >= 500 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    vistaPrevia
                    HStack(spacing: 10) {
                        Campo(etiqueta: "Nombre", texto: $n.nombre, placeholder: "Original", limite: 20)
                        CampoPlata(etiqueta: "Por mes", monto: $n.precio)
                    }
                    .padding(.top, 16)
                    Campo(etiqueta: "En una línea", texto: $n.descripcion, placeholder: "Todo lo anterior y un dibujo tuyo por año.", limite: 90)
                        .padding(.top, 10)
                    Etiqueta("Qué incluye").padding(.top, 18).padding(.bottom, 8)
                    incluye
                    Borde(relleno: 14, radio: 16) {
                        FilaInterruptor(titulo: conCupo ? "Cupo de \(n.cupo ?? 25) personas" : "Sin cupo", sub: "Para que te den los tiempos", valor: $conCupo)
                        if conCupo {
                            Stepper(value: Binding(get: { n.cupo ?? 25 }, set: { n.cupo = $0 }), in: max(1, n.miembros)...500, step: 5) {
                                Text("Cupo").tipo(.texto(15, 500)).foregroundStyle(Color.gris)
                            }
                        }
                    }
                    .padding(.top, 12)
                    (Text("Por cada persona te llegan ") + Text(Plata.texto(n.neto)).foregroundColor(.tinta).bold()
                     + Text(". Bancamos se queda con el 3 % y Mercado Pago cobra lo suyo aparte."))
                        .tipo(.texto(13, 400)).foregroundStyle(Color.gris).padding(.top, 10)
                    if let o = original, o.miembros > 0, o.precio != n.precio {
                        NotaSegura(texto: "Las \(o.miembros) personas de \(o.nombre) pagan el precio nuevo desde su próximo pago. Les avisamos antes, con la opción de darse de baja.",
                                   icono: .campana)
                            .padding(.top, 12)
                    }
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(original == nil ? "Nivel nuevo" : "Editar nivel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } } }
            .safeAreaInset(edge: .bottom) {
                Boton(titulo: original == nil ? "Publicar nivel" : "Guardar", alto: .alto, ancho: true, habilitado: listo) {
                    var final = n
                    final.cupo = conCupo ? (n.cupo ?? 25) : nil
                    if !nuevoItem.limpio.isEmpty { final.incluye.append(nuevoItem.limpio) }
                    estado.guardarNivel(final)
                    cerrar()
                }
                .padding(.horizontal, Espacio.margen).padding(.vertical, 8).background(Color.white)
            }
            .onChange(of: conCupo) { _, v in if v && n.cupo == nil { n.cupo = 25 } }
        }
    }

    private var vistaPrevia: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(n.nombre.isEmpty ? "Nombre del nivel" : n.nombre).tipo(.titulo(22)).foregroundStyle(n.nombre.isEmpty ? Color.gris : Color.tinta)
                Spacer()
                Text(Plata.texto(n.precio)).tipo(.numero(22)).foregroundStyle(Color.tinta)
            }
            Text("Así lo ve tu gente").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color.esmeralda50, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous).strokeBorder(Color.tinta, lineWidth: 2))
        .padding(.top, 10)
    }

    private var incluye: some View {
        Borde(radio: 16) {
            ForEach(Array(n.incluye.enumerated()), id: \.offset) { i, t in
                if i > 0 { Divisor() }
                HStack(spacing: 10) {
                    IconoVista(.tilde, tamano: 20).foregroundStyle(Color.ok)
                    Text(t).tipo(.texto(15, 400)).foregroundStyle(Color.tinta)
                    Spacer()
                    Button { withAnimation(.snappy) { _ = n.incluye.remove(at: i) } } label: {
                        IconoVista(.cruz, tamano: 16).foregroundStyle(Color.gris).frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Sacar \(t)")
                }
                .padding(.leading, 14)
            }
            if !n.incluye.isEmpty { Divisor() }
            HStack(spacing: 10) {
                IconoVista(.mas, tamano: 20).foregroundStyle(Color.esmeralda700)
                TextField("Agregar", text: $nuevoItem)
                    .font(Estilo.texto(15, 700).font())
                    .foregroundStyle(Color.tinta)
                    .submitLabel(.done)
                    .onSubmit {
                        guard !nuevoItem.limpio.isEmpty else { return }
                        withAnimation(.snappy) { n.incluye.append(nuevoItem.limpio) }
                        nuevoItem = ""
                    }
            }
            .padding(.horizontal, 14).frame(minHeight: 48)
        }
    }
}
