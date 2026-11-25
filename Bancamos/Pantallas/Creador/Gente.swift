import SwiftUI

/// Tu gente: los apoyos (con mensaje y gracias) y los miembros (los que te bancan cada mes).
struct Gente: View {
    var soloApoyos = false
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @State private var vista = 0
    @State private var filtroApoyo = 0
    @State private var filtroNivel: String?
    @State private var busqueda = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !soloApoyos {
                    Picker("Ver", selection: $vista.animation(.snappy)) {
                        Text("Apoyos").tag(0)
                        Text("Miembros · \(Plata.numero(estado.yo.mensuales))").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 14)
                }
                if vista == 0 || soloApoyos { apoyos } else { miembros }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.top, 4)
            .padding(.bottom, Espacio.bajoBarra)
        }
        .background(Color.fondo)
        .navigationTitle(soloApoyos ? "Apoyos" : "Tu gente")
        .navigationBarTitleDisplayMode(soloApoyos ? .inline : .large)
        .searchable(text: $busqueda, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Buscar por nombre")
        .toolbar {
            if vista == 1 && !soloApoyos {
                ToolbarItem(placement: .topBarTrailing) {
                    CompartirBoton(generar: { estado.csvMiembros() }) {
                        IconoVista(.descarga, tamano: 22).foregroundStyle(Color.tinta).frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Exportar miembros a CSV")
                }
            }
        }
    }

    // MARK: Apoyos

    private var listaApoyos: [Apoyo] {
        estado.panel.apoyos.filter { a in
            let f: Bool
            switch filtroApoyo {
            case 1: f = !a.agradecido && !a.anonimo
            case 2: f = a.tipo == .unaVez
            case 3: f = a.tipo == .mensual
            default: f = true
            }
            return f && (busqueda.isEmpty || a.nombre.localizedCaseInsensitiveContains(busqueda))
        }
    }

    @ViewBuilder private var apoyos: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(["Todos", "Sin agradecer · \(estado.sinAgradecer.count)", "Una vez", "Cada mes"].enumerated()), id: \.offset) { i, t in
                    ChipOpcion(titulo: t, elegido: filtroApoyo == i) { withAnimation(.snappy) { filtroApoyo = i } }
                }
            }
        }
        .scrollClipDisabled()
        .padding(.bottom, 14)
        if filtroApoyo == 1 && estado.sinAgradecer.count > 1 {
            Boton(titulo: "Agradecer a todos", icono: .mano, variante: .prim, alto: .normal, ancho: true) { nav.abrir(.agradecerTodos) }
                .padding(.bottom, 12)
        }
        let lista = listaApoyos
        if lista.isEmpty {
            Tarjeta {
                if estado.panel.apoyos.isEmpty {
                    EstadoVacio(icono: .corazon, titulo: "Todavía no hay apoyos", texto: "Compartí tu link y acá vas a ver quién te banca y qué te dice.",
                                accion: "Compartir mi link") { nav.abrir(.qr) }
                } else {
                    EstadoVacio(icono: .tilde, titulo: filtroApoyo == 1 ? "Les agradeciste a todos" : "Nada por acá",
                                texto: filtroApoyo == 1 ? "Cuando llegue un apoyo nuevo, aparece acá." : "Probá con otro filtro.")
                }
            }
        } else {
            Tarjeta {
                ForEach(Array(lista.enumerated()), id: \.element.id) { i, a in
                    if i > 0 { Divisor() }
                    FilaApoyo(apoyo: a)
                }
            }
        }
    }

    // MARK: Miembros

    private var listaMiembros: [Miembro] {
        estado.miembros(nivel: filtroNivel).filter { busqueda.isEmpty || $0.nombre.localizedCaseInsensitiveContains(busqueda) }
    }

    @ViewBuilder private var miembros: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipOpcion(titulo: "Todos", elegido: filtroNivel == nil) { withAnimation(.snappy) { filtroNivel = nil } }
                ForEach(estado.yo.niveles) { n in
                    ChipOpcion(titulo: "\(n.nombre) · \(n.miembros)", elegido: filtroNivel == n.id) { withAnimation(.snappy) { filtroNivel = n.id } }
                }
            }
        }
        .scrollClipDisabled()
        .padding(.bottom, 14)
        let alertas = estado.panel.miembros.filter { $0.estado == .vencido || $0.estado == .porVencer }
        if !alertas.isEmpty && filtroNivel == nil && busqueda.isEmpty {
            NotaSegura(texto: "\(Texto.plural(alertas.count, "persona tiene", "personas tienen")) la cuota por vencer o sin pagar. Les avisamos solos: no tenés que cobrar vos.",
                       icono: .campana)
                .padding(.bottom, 12)
        }
        let lista = listaMiembros
        if lista.isEmpty {
            Tarjeta {
                EstadoVacio(icono: .gente, titulo: estado.panel.miembros.isEmpty ? "Todavía nadie te banca cada mes" : "Nadie con ese filtro",
                            texto: estado.panel.miembros.isEmpty ? "Con niveles claros y algo exclusivo, la gente se suma. Revisá tus niveles." : "Probá con otro nivel.",
                            accion: estado.panel.miembros.isEmpty ? "Ver mis niveles" : nil) { nav.ir(.niveles) }
            }
        } else {
            Tarjeta {
                ForEach(Array(lista.enumerated()), id: \.element.id) { i, m in
                    if i > 0 { Divisor(izquierda: 68) }
                    Button { nav.ir(.miembro(m.id)) } label: { FilaMiembro(miembro: m, nivel: estado.yo.nivel(m.nivelId)?.nombre ?? "") }
                        .buttonStyle(Apretable())
                }
            }
            if estado.yo.mensuales > lista.count && filtroNivel == nil && busqueda.isEmpty {
                Text("Se ven los últimos \(lista.count) de \(Plata.numero(estado.yo.mensuales)). Buscá por nombre o exportá la lista completa.")
                    .tipo(.texto(13, 400)).foregroundStyle(Color.gris).padding(.top, 10).padding(.horizontal, 4)
            }
        }
    }
}

struct FilaMiembro: View {
    let miembro: Miembro
    let nivel: String

    var body: some View {
        HStack(spacing: 12) {
            Avatar(imagen: nil, iniciales: miembro.iniciales, tamano: 40)
            VStack(alignment: .leading, spacing: 1) {
                Text(miembro.nombre).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                Text("\(nivel) · hace \(Texto.plural(miembro.meses, "mes", "meses"))").tipo(.texto(13, 400)).foregroundStyle(Color.gris)
            }
            Spacer(minLength: 8)
            switch miembro.estado {
            case .alDia: Chip(texto: "Al día", tono: .ok)
            case .porVencer: Chip(texto: "Vence \(Fecha.cuando(miembro.proximoPago))", tono: .alerta)
            case .vencido: Chip(texto: "No pagó", tono: .error)
            case .baja: Chip(texto: "Baja", tono: .gris)
            }
        }
        .padding(.horizontal, 16).frame(minHeight: 64)
        .contentShape(Rectangle())
    }
}

/// La ficha de alguien que te banca: nivel, desde cuándo, cuánto aportó, sus mensajes y una nota.
struct FichaMiembro: View {
    let miembroId: String
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @State private var nota = ""

    var body: some View {
        if let m = estado.miembro(miembroId) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 8) {
                        Avatar(imagen: nil, iniciales: m.iniciales, tamano: 80)
                        Titulo(m.nombre, tamano: 28)
                        HStack(spacing: 8) {
                            Chip(texto: estado.yo.nivel(m.nivelId)?.nombre ?? "", tono: .marca)
                            Chip(texto: m.estado.nombre, tono: m.estado == .alDia ? .ok : m.estado == .baja ? .gris : .alerta)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    HStack(spacing: 10) {
                        Boton(titulo: "Escribirle", icono: .mensaje, variante: .osc, alto: .normal, ancho: true) {
                            nav.ir(.conversacion(estado.conversacionCon(m.nombre, nivel: estado.yo.nivel(m.nivelId)?.nombre)))
                        }
                        if let a = estado.apoyosDe(m.nombre).first(where: { !$0.agradecido }) {
                            Boton(titulo: "Agradecer", icono: .corazon, variante: .suave, alto: .normal, ancho: true) { nav.abrir(.agradecer(a.id)) }
                        }
                    }
                    .padding(.top, 20)
                    Tarjeta(relleno: 16) {
                        FilaDato(etiqueta: "Te banca desde", valor: Fecha.dia(m.desde))
                        Divisor()
                        FilaDato(etiqueta: "Cada mes", valor: Plata.texto(estado.yo.nivel(m.nivelId)?.precio ?? 0))
                        Divisor()
                        FilaDato(etiqueta: "Próximo pago", valor: m.estado == .baja ? "—" : Fecha.dia(m.proximoPago))
                        Divisor()
                        FilaDato(etiqueta: "Te aportó en total", valor: Plata.texto(m.aportado))
                        Divisor()
                        FilaDato(etiqueta: "Mail", valor: m.email, fuerte: false)
                    }
                    .padding(.top, 16)
                    let mensajes = estado.apoyosDe(m.nombre).filter { !$0.mensaje.isEmpty }
                    if !mensajes.isEmpty {
                        TituloSeccion(texto: "Sus mensajes")
                        Tarjeta {
                            ForEach(Array(mensajes.enumerated()), id: \.element.id) { i, a in
                                if i > 0 { Divisor() }
                                FilaApoyo(apoyo: a)
                            }
                        }
                    }
                    TituloSeccion(texto: "Tu nota")
                    Campo(etiqueta: "Sólo la ves vos", texto: $nota, placeholder: "Ej.: quiere un gato con su perro", lineas: 3)
                        .onChange(of: nota) { _, v in estado.guardarNota(v, miembroId: m.id) }
                    if m.estado == .vencido {
                        NotaSegura(texto: "No pudo pagar este mes. Le mandamos un aviso para que pague con otro medio. Si no paga en 7 días, deja de ver lo exclusivo.",
                                   icono: .campana)
                            .padding(.top, 16)
                    }
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.bottom, 40)
            }
            .background(Color.fondo)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { nota = m.nota }
        } else {
            EstadoVacio(icono: .persona, titulo: "No encontramos a esta persona", texto: "Puede que se haya dado de baja.")
        }
    }
}

/// Agradecer: un mensaje que se puede cambiar, a una persona o a varias.
struct HojaAgradecer: View {
    let apoyoIds: [String]
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var texto = ""

    private var apoyos: [Apoyo] { estado.panel.apoyos.filter { apoyoIds.contains($0.id) } }
    private var plantillas: [String] {
        let n = apoyos.count == 1 ? (apoyos.first?.nombre.split(separator: " ").first.map(String.init) ?? "") : ""
        let a = n.isEmpty ? "" : ", \(n)"
        return ["¡Gracias\(a)! Me ayuda un montón a seguir.",
                "Gracias por bancarme\(a). Esto me acerca a la meta.",
                "¡Qué lindo mensaje\(a)! Gracias de verdad."]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if apoyos.count == 1, let a = apoyos.first {
                        Borde { FilaApoyo(apoyo: a, conAgradecer: false) }
                    } else {
                        Text("A \(Texto.plural(apoyos.count, "persona", "personas")): \(apoyos.prefix(3).map { $0.nombre.split(separator: " ").first.map(String.init) ?? "" }.joined(separator: ", "))\(apoyos.count > 3 ? " y más" : "").")
                            .tipo(.texto(15, 500)).foregroundStyle(Color.gris)
                    }
                    Campo(etiqueta: "Tu mensaje", texto: $texto, lineas: 3, limite: 280)
                    Etiqueta("Ideas")
                    ForEach(plantillas, id: \.self) { p in
                        Button { Haptico.seleccion(); texto = p } label: {
                            Text(p).tipo(.texto(15, 500)).foregroundStyle(Color.tinta).multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(texto == p ? Color.esmeralda50 : Color.fondo, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(texto == p ? Color.tinta : .clear, lineWidth: 1.5))
                        }
                        .buttonStyle(Apretable())
                    }
                    Sec("Le llega por mail y en la app, con tu foto.")
                }
                .padding(Espacio.margen)
            }
            .navigationTitle(apoyos.count == 1 ? "Agradecer" : "Agradecer a todos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
            }
            .safeAreaInset(edge: .bottom) {
                Boton(titulo: "Enviar gracias", icono: .enviar, alto: .alto, ancho: true, habilitado: !texto.limpio.isEmpty) {
                    if apoyoIds.count == 1 { estado.agradecer(apoyoIds[0], texto: texto) } else { estado.agradecerTodos(texto: texto) }
                    cerrar()
                }
                .padding(.horizontal, Espacio.margen).padding(.bottom, 8).background(Color.white)
            }
            .onAppear { if texto.isEmpty { texto = plantillas[0] } }
        }
    }
}
