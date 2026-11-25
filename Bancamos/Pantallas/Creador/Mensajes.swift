import SwiftUI

/// Las conversaciones con los que te bancan.
struct Mensajes: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Te escriben \(estado.panel.privacidad.mensajesDe == .todos ? "todos" : estado.panel.privacidad.mensajesDe.nombre.lowercased()). Lo cambiás en Privacidad.")
                    .tipo(.texto(14, 400)).foregroundStyle(Color.gris).padding(.bottom, 12)
                if estado.panel.conversaciones.isEmpty {
                    Tarjeta {
                        EstadoVacio(icono: .mensaje, titulo: "Sin mensajes por ahora",
                                    texto: "Cuando alguien que te banca te escriba, la charla aparece acá. También podés escribirle desde su ficha.")
                    }
                } else {
                    Tarjeta {
                        ForEach(Array(estado.panel.conversaciones.enumerated()), id: \.element.id) { i, c in
                            if i > 0 { Divisor(izquierda: 72) }
                            Button { nav.ir(.conversacion(c.id)) } label: { fila(c) }.buttonStyle(Apretable())
                        }
                    }
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Mensajes")
    }

    private func fila(_ c: Conversacion) -> some View {
        HStack(spacing: 12) {
            Avatar(imagen: nil, iniciales: c.iniciales, tamano: 44)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(c.nombre).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                    if let n = c.nivel { Text(n).tipo(.texto(12, 700)).foregroundStyle(Color.esmeralda700) }
                    Spacer()
                    if let u = c.ultimo { Text(Fecha.hace(u.fecha)).tipo(.texto(12, 500)).foregroundStyle(Color.gris) }
                }
                Text(c.ultimo.map { ($0.deMi ? "Vos: " : "") + $0.texto } ?? "Escribile")
                    .tipo(.texto(14, c.noLeidos > 0 ? 600 : 400)).foregroundStyle(c.noLeidos > 0 ? Color.tinta : Color.gris).lineLimit(1)
            }
            if c.noLeidos > 0 {
                Text("\(c.noLeidos)").tipo(.texto(12, 700)).foregroundStyle(.white)
                    .frame(minWidth: 22, minHeight: 22).background(Color.esmeralda700, in: Circle())
            }
        }
        .padding(.horizontal, 16).frame(minHeight: 72).contentShape(Rectangle())
    }
}

/// Una conversación: globos y el campo para escribir.
struct ConversacionVista: View {
    let conversacionId: String
    @Environment(Estado.self) private var estado
    @State private var texto = ""
    @FocusState private var foco: Bool

    var body: some View {
        if let c = estado.conversacion(conversacionId) {
            ScrollViewReader { lector in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if c.mensajes.isEmpty {
                            EstadoVacio(icono: .mensaje, titulo: "Escribile a \(c.nombre.split(separator: " ").first ?? "")",
                                        texto: "Un gracias personal hace que la gente se quede.")
                        }
                        ForEach(c.mensajes) { m in globo(m).id(m.id) }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    estado.leer(conversacionId: c.id)
                    if let u = c.mensajes.last { lector.scrollTo(u.id, anchor: .bottom) }
                }
                .onChange(of: c.mensajes.count) { if let u = c.mensajes.last { withAnimation { lector.scrollTo(u.id, anchor: .bottom) } } }
            }
            .background(Color.fondo)
            .navigationTitle(c.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { escribir(c) }
        }
    }

    private func globo(_ m: Mensaje) -> some View {
        HStack {
            if m.deMi { Spacer(minLength: 50) }
            VStack(alignment: m.deMi ? .trailing : .leading, spacing: 2) {
                Text(m.texto).tipo(.texto(15, 400)).foregroundStyle(m.deMi ? .white : Color.tinta)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(m.deMi ? Color.esmeralda700 : Color.white,
                                in: UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: m.deMi ? 18 : 4,
                                                           bottomTrailingRadius: m.deMi ? 4 : 18, topTrailingRadius: 18))
                Text(Fecha.hora(m.fecha)).tipo(.texto(11, 500)).foregroundStyle(Color.gris)
            }
            if !m.deMi { Spacer(minLength: 50) }
        }
    }

    private func escribir(_ c: Conversacion) -> some View {
        HStack(spacing: 8) {
            TextField("Escribí un mensaje", text: $texto, axis: .vertical)
                .lineLimit(1...4)
                .font(Estilo.texto(16, 500).font())
                .focused($foco)
                .padding(.horizontal, 14).padding(.vertical, 11)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Color.linea, lineWidth: 1.5))
            Button {
                estado.enviar(texto, a: c.id)
                texto = ""
            } label: {
                IconoVista(.enviar, tamano: 20).foregroundStyle(.white).frame(width: 44, height: 44)
                    .background(texto.limpio.isEmpty ? Color.linea : Color.esmeralda700, in: Circle())
            }
            .disabled(texto.limpio.isEmpty)
            .accessibilityLabel("Enviar")
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(.bar)
    }
}

/// Los avisos del creador (apoyos, bajas, mensajes, metas).
struct Notificaciones: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if estado.panel.notificaciones.isEmpty {
                    EstadoVacio(icono: .campana, titulo: "Sin avisos", texto: "Cuando alguien te banque o te escriba, te avisamos acá.")
                } else {
                    Tarjeta {
                        ForEach(Array(estado.panel.notificaciones.enumerated()), id: \.element.id) { i, n in
                            if i > 0 { Divisor(izquierda: 68) }
                            Button { abrir(n) } label: { fila(n) }.buttonStyle(Apretable())
                        }
                    }
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Avisos")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { nav.ir(.avisos) } label: { Image(systemName: "gearshape").font(.system(size: 18, weight: .medium)).foregroundStyle(Color.tinta).frame(width: 44, height: 44) }
                    .accessibilityLabel("Qué avisos recibir")
            }
        }
        .onDisappear { estado.leerNotificaciones() }
    }

    private func fila(_ n: Notificacion) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconoVista(n.tipo.icono, tamano: 20).foregroundStyle(Color.esmeralda700)
                .frame(width: 40, height: 40).background(Color.esmeralda100, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(n.titulo).tipo(.texto(15, n.leida ? 600 : 700)).foregroundStyle(Color.tinta)
                    Spacer()
                    Text(Fecha.hace(n.fecha)).tipo(.texto(12, 500)).foregroundStyle(Color.gris)
                }
                Text(n.texto).tipo(.texto(14, 400)).foregroundStyle(Color.gris).multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !n.leida { Circle().fill(Color.esmeralda).frame(width: 8, height: 8).padding(.top, 6) }
        }
        .padding(.horizontal, 16).padding(.vertical, 12).contentShape(Rectangle())
    }

    private func abrir(_ n: Notificacion) {
        switch n.tipo {
        case .apoyo, .miembro, .baja: nav.ir(.apoyos)
        case .mensaje: nav.ir(.mensajes)
        case .meta: nav.ir(.metas)
        case .cobro, .sistema: nav.ir(.cobros)
        case .posteo: break
        }
    }
}
