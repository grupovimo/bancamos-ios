import SwiftUI

/// Las metas: la activa, crear una nueva, cerrarla y el historial con las cumplidas.
struct Metas: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @State private var cerrarMeta: Meta?

    private var activas: [Meta] { estado.yo.metas.filter { !$0.cerrada } }
    private var cerradas: [Meta] { estado.yo.metas.filter(\.cerrada) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if activas.isEmpty {
                    Tarjeta {
                        EstadoVacio(icono: .bandera, titulo: "No tenés una meta activa",
                                    texto: "Una meta con un número claro hace que la gente empuje: ven cuánto falta y lo comparten.",
                                    accion: "Crear una meta") { nav.abrir(.meta(nil)) }
                    }
                } else {
                    ForEach(activas) { m in activa(m) }
                }
                if !cerradas.isEmpty {
                    TituloSeccion(texto: "Historial")
                    Tarjeta {
                        ForEach(Array(cerradas.enumerated()), id: \.element.id) { i, m in
                            if i > 0 { Divisor() }
                            Button { if m.lograda { estado.celebrar = m } } label: { filaCerrada(m) }
                                .buttonStyle(Apretable())
                        }
                    }
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Metas")
        .toolbar {
            if !activas.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { nav.abrir(.meta(nil)) } label: { IconoVista(.mas, tamano: 22).foregroundStyle(Color.tinta).frame(width: 44, height: 44) }
                        .accessibilityLabel("Meta nueva")
                }
            }
        }
        .confirmationDialog(cerrarMeta.map { $0.lograda ? "¿Cerrar «\($0.titulo)»?" : "¿Cerrar la meta sin llegar?" } ?? "",
                            isPresented: Binding(get: { cerrarMeta != nil }, set: { if !$0 { cerrarMeta = nil } }), titleVisibility: .visible) {
            Button(cerrarMeta?.lograda == true ? "Cerrar y festejar" : "Cerrar meta", role: cerrarMeta?.lograda == true ? nil : .destructive) {
                if let m = cerrarMeta { estado.cerrar(metaId: m.id) }
            }
        } message: {
            Text(cerrarMeta?.lograda == true ? "Les avisamos a todos los que te bancaron." : "Lo que juntaste ya está en tu Mercado Pago. La meta deja de verse en tu página.")
        }
    }

    private func activa(_ m: Meta) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TarjetaMeta(meta: m, pie: m.lograda ? "¡Llegaste! Cerrala para festejar." : "Faltan \(Plata.texto(m.falta))", sombra: true)
            if !m.descripcion.isEmpty { Sec(m.descripcion, tamano: 15).padding(.horizontal, 4) }
            HStack(spacing: 8) {
                Boton(titulo: "Editar", icono: .lapiz, variante: .blanco, alto: .chico, ancho: true) { nav.abrir(.meta(m)) }
                Boton(titulo: "Compartir", icono: .compartir, variante: .blanco, alto: .chico, ancho: true) { nav.abrir(.qr) }
                Boton(titulo: m.lograda ? "Cerrar y festejar" : "Cerrar", variante: m.lograda ? .prim : .blanco, alto: .chico, ancho: true) { cerrarMeta = m }
            }
            Text("Abierta desde el \(Fecha.dia(m.creada)).").tipo(.texto(13, 400)).foregroundStyle(Color.gris).padding(.horizontal, 4)
        }
        .padding(.bottom, 12)
    }

    private func filaCerrada(_ m: Meta) -> some View {
        HStack(spacing: 12) {
            IconoVista(m.lograda ? .bandera : .cruz, tamano: 20).foregroundStyle(m.lograda ? Color.esmeralda700 : Color.gris)
                .frame(width: 40, height: 40).background(m.lograda ? Color.esmeralda100 : Color.fondo, in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(m.titulo).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                Text(m.lograda ? "Cumplida el \(Fecha.dia(m.cumplida ?? m.creada)) · \(Plata.texto(m.recaudado))" : "Cerrada en \(m.porcentaje) % · \(Plata.texto(m.recaudado))")
                    .tipo(.texto(13, 400)).foregroundStyle(Color.gris)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).frame(minHeight: 64).contentShape(Rectangle())
    }
}

/// Crear o editar una meta, con la vista previa.
struct EditorMeta: View {
    var original: Meta?
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var m: Meta

    init(original: Meta?) {
        self.original = original
        var base = original ?? Meta(id: UUID().uuidString, titulo: "", descripcion: "", objetivo: 0, recaudado: 0, creada: Date())
        if original == nil && Arranque.actual == .metaNueva {
            base.titulo = "Presentar el libro en la Feria"; base.descripcion = "Un stand chico en la Feria del Libro, con firma de ejemplares."; base.objetivo = 600_000
        }
        _m = State(initialValue: base)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    TarjetaMeta(meta: Meta(id: "p", titulo: m.titulo.isEmpty ? "Tu meta" : m.titulo, descripcion: "", objetivo: max(m.objetivo, 1),
                                           recaudado: m.recaudado, creada: Date()),
                                pie: original == nil ? "Arranca en cero. Cada aporte la llena." : nil)
                    Campo(etiqueta: "¿Para qué es?", texto: $m.titulo, placeholder: "Imprimir mi primer libro", limite: 50)
                    CampoPlata(etiqueta: "¿Cuánto necesitás?", monto: $m.objetivo)
                    Campo(etiqueta: "Contalo un poco más", texto: $m.descripcion, placeholder: "Qué vas a hacer con la plata", lineas: 3, limite: 240)
                    if original == nil && estado.yo.metaActiva != nil {
                        NotaSegura(texto: "Ya tenés una meta abierta. Las dos se ven en tu página; los apoyos suman a la más vieja.", icono: .bandera)
                    }
                    Sec("Una meta concreta («300 libros», «la sala de grabación») junta más que una genérica.")
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.top, 10).padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(original == nil ? "Meta nueva" : "Editar meta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } } }
            .safeAreaInset(edge: .bottom) {
                Boton(titulo: original == nil ? "Publicar meta" : "Guardar", alto: .alto, ancho: true,
                      habilitado: !m.titulo.limpio.isEmpty && m.objetivo >= 1000) {
                    estado.guardarMeta(m)
                    cerrar()
                }
                .padding(.horizontal, Espacio.margen).padding(.vertical, 8).background(Color.white)
            }
        }
    }
}

/// «¡Meta cumplida!»: papelitos, la barra llena y para avisarle a la gente.
struct MetaCumplida: View {
    let meta: Meta
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var lleno = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Papelitos()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    BotonRedondo(icono: .cruz, etiqueta: "Cerrar", sombra: false) { cerrar() }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 8)
                IconoVista(.bandera, tamano: 40).foregroundStyle(.white)
                    .frame(width: 104, height: 104).background(Color.esmeralda, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 5))
                    .shadow(color: .black.opacity(0.14), radius: 13, y: 12)
                    .scaleEffect(lleno ? 1 : 0.6)
                Titulo("¡Meta cumplida!", tamano: 40).padding(.top, 22)
                Sec("Llegaste a \(meta.titulo.lowercased()). Gracias a \(Texto.plural(max(estado.yo.bancadas, 1), "persona", "personas")) que te bancaron.", tamano: 17)
                    .multilineTextAlignment(.center).padding(.top, 8).padding(.horizontal, 24)
                Tarjeta(relleno: 16) {
                    Etiqueta(meta.titulo)
                    HStack(alignment: .firstTextBaseline) {
                        Text(Plata.texto(meta.recaudado)).tipo(.numero(28)).foregroundStyle(Color.tinta)
                        Spacer()
                        Text("de \(Plata.texto(meta.objetivo))").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                    }
                    .padding(.top, 8)
                    BarraMeta(fraccion: lleno ? 1 : 0.85).padding(.top, 10)
                }
                .padding(.horizontal, Espacio.margen).padding(.top, 26)
                Spacer(minLength: 8)
                VStack(spacing: 10) {
                    Boton(titulo: "Avisarle a mi gente", icono: .enviar, alto: .alto, ancho: true) {
                        estado.avisar("Les avisamos a todos los que te bancaron.")
                        cerrar()
                    }
                    CompartirBoton(generar: { "¡Llegué a la meta «\(meta.titulo)» gracias a los que me bancan! \(estado.yo.url.absoluteString)" }) {
                        HStack(spacing: 8) {
                            IconoVista(.compartir, tamano: 20)
                            Text("Compartir").tipo(.texto(16, 700))
                        }
                        .foregroundStyle(Color.tinta).frame(maxWidth: .infinity).frame(height: 52)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.control))
                        .overlay(RoundedRectangle(cornerRadius: Radio.control).strokeBorder(Color.linea, lineWidth: 1.5))
                    }
                }
                .padding(.horizontal, Espacio.margen).padding(.bottom, 12)
            }
        }
        .onAppear {
            Haptico.exito()
            withAnimation(.spring(duration: 0.9, bounce: 0.35).delay(0.2)) { lleno = true }
        }
    }
}
