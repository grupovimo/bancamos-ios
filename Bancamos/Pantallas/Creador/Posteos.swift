import SwiftUI
import PhotosUI

/// Los posteos del creador: publicados y programados.
struct Posteos: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @State private var vista = 0

    private var publicados: [Posteo] { estado.yo.posteos.filter { !$0.esProgramado } }
    private var programados: [Posteo] { estado.yo.posteos.filter(\.esProgramado) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Ver", selection: $vista.animation(.snappy)) {
                    Text("Publicados").tag(0)
                    Text("Programados · \(programados.count)").tag(1)
                }
                .pickerStyle(.segmented)
                let lista = vista == 0 ? publicados : programados
                if lista.isEmpty {
                    Tarjeta {
                        EstadoVacio(icono: vista == 0 ? .texto : .reloj,
                                    titulo: vista == 0 ? "Publicá tu primer posteo" : "Nada programado",
                                    texto: vista == 0 ? "Un boceto, un audio o una novedad. Lo exclusivo es lo que hace que la gente se sume cada mes."
                                                      : "Podés dejar un posteo listo para que salga solo el día que quieras.",
                                    accion: "Crear posteo") { nav.abrir(.posteo(nil)) }
                    }
                } else {
                    ForEach(lista) { p in
                        Button { nav.ir(.posteo(p.id)) } label: { FilaPosteo(creador: estado.yo, posteo: p) }
                            .buttonStyle(Apretable())
                    }
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.top, 4)
            .padding(.bottom, Espacio.bajoBarra)
        }
        .background(Color.fondo)
        .navigationTitle("Posteos")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { nav.abrir(.posteo(nil)) } label: {
                    IconoVista(.mas, tamano: 22).foregroundStyle(Color.tinta).frame(width: 44, height: 44)
                }
                .accessibilityLabel("Posteo nuevo")
            }
        }
    }
}

/// Un posteo en la lista del creador: miniatura, título, a quién y cómo le fue.
struct FilaPosteo: View {
    let creador: Creador
    let posteo: Posteo

    var body: some View {
        HStack(spacing: 12) {
            miniatura
            VStack(alignment: .leading, spacing: 4) {
                Text(posteo.titulo).tipo(.texto(15, 700)).foregroundStyle(Color.tinta).lineLimit(2).multilineTextAlignment(.leading)
                if posteo.esProgramado, let f = posteo.programado {
                    Text("Sale el \(Fecha.dia(f)) a las \(Fecha.hora(f))").tipo(.texto(13, 600)).foregroundStyle(Color.alerta)
                } else {
                    Text("\(Fecha.hace(posteo.fecha)) · \(posteo.meGusta) me gusta · \(posteo.comentarios) comentarios")
                        .tipo(.texto(13, 400)).foregroundStyle(Color.gris).lineLimit(1)
                }
                ChipPublico(creador: creador, publico: posteo.publico)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .sombra()
    }

    @ViewBuilder private var miniatura: some View {
        Group {
            if let f = posteo.fotos.first {
                FotoRecortada(imagen: f, zoom: f.datos != nil ? 1 : f.zoom / 1.2)
            } else {
                IconoVista(posteo.tipo.icono, tamano: 24).foregroundStyle(Color.esmeralda700)
                    .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.esmeralda100)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// El posteo como lo ve el creador, con quién lo vio y para editarlo o borrarlo.
struct DetallePosteoCreador: View {
    let posteoId: String
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @Environment(\.dismiss) private var volver
    @State private var borrar = false

    var body: some View {
        if let p = estado.yo.posteos.first(where: { $0.id == posteoId }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    TarjetaPosteo(creador: estado.yo, posteo: p)
                    Tarjeta(relleno: 16) {
                        FilaDato(etiqueta: "Lo ve", valor: estado.yo.publicoTexto(p.publico))
                        Divisor()
                        FilaDato(etiqueta: "Personas que pueden verlo", valor: Plata.numero(estado.alcance(p.publico)))
                        Divisor()
                        FilaDato(etiqueta: p.esProgramado ? "Sale" : "Publicado", valor: Fecha.dia(p.programado ?? p.fecha))
                        Divisor()
                        FilaDato(etiqueta: "Aviso por mail", valor: p.avisarPorMail ? "Sí" : "No")
                    }
                    HStack(spacing: 10) {
                        Boton(titulo: "Editar", icono: .lapiz, variante: .blanco, alto: .normal, ancho: true) { nav.abrir(.posteo(p)) }
                        Boton(titulo: "Borrar", icono: .basura, variante: .peligro, alto: .normal, ancho: true) { borrar = true }
                    }
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.bottom, 40)
            }
            .background(Color.fondo)
            .navigationTitle(p.esProgramado ? "Programado" : "Posteo")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("¿Borrar este posteo?", isPresented: $borrar, titleVisibility: .visible) {
                Button("Borrar", role: .destructive) { estado.borrar(posteoId: p.id); volver() }
            } message: { Text("Deja de verse en tu página. No se puede deshacer.") }
        } else {
            EstadoVacio(icono: .texto, titulo: "Este posteo ya no está", texto: "Puede que lo hayas borrado.")
        }
    }
}

/// Posteo nuevo (pantalla 8): texto, fotos o audio; quién lo ve; avisar por mail; programar.
struct EditorPosteo: View {
    var original: Posteo?
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var p: Posteo
    @State private var items: [PhotosPickerItem] = []
    @State private var programar = false
    @State private var grabando = false
    @State private var descartar = false

    init(original: Posteo?) {
        self.original = original
        var base = original ?? Posteo(id: UUID().uuidString, creadorId: "ana", titulo: "", texto: "", tipo: .fotos, publico: .quienesTeBancan, fecha: Date())
        if original == nil && Arranque.actual == .posteoNuevo {
            base.titulo = "El gato de la tormenta, paso a paso"
            base.texto = "Del boceto en lápiz al color final. Abajo, el pincel que usé para la lluvia."
            base.fotos = DatosDeMuestra.ana.posteos[2].fotos + [.asset("foto-ilustradora", 0.2, 0.8)]
            base.publico = .desde("color")
        }
        _p = State(initialValue: base)
        _programar = State(initialValue: original?.programado != nil)
    }

    private var listo: Bool {
        !p.titulo.limpio.isEmpty && (p.tipo != .fotos || !p.fotos.isEmpty) && (p.tipo != .audio || p.audioSegundos > 0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TiposPosteo(tipo: $p.tipo)
                    contenidoTipo.padding(.top, 14)
                    Campo(etiqueta: "Título", texto: $p.titulo, placeholder: "El gato de la tormenta, paso a paso", limite: 80).padding(.top, 14)
                    Campo(etiqueta: "Texto", texto: $p.texto, placeholder: "Contá de qué se trata", lineas: 4).padding(.top, 10)
                    QuienLoVe(publico: $p.publico).padding(.top, 20)
                    VStack(spacing: 4) {
                        FilaInterruptor(titulo: "Avisar por mail", sub: "A \(Texto.plural(estado.alcance(p.publico), "persona", "las \(Plata.numero(estado.alcance(p.publico))) personas")) de \(estado.yo.publicoTexto(p.publico))",
                                        valor: $p.avisarPorMail)
                        FilaInterruptor(titulo: "Programar", sub: "Sale solo el día y la hora que elijas", valor: $programar)
                        if programar {
                            DatePicker("Sale el", selection: Binding(get: { p.programado ?? Fecha.en(dias: 1, horas: 2) }, set: { p.programado = $0 }),
                                       in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .font(Estilo.texto(15, 600).font())
                                .tint(Color.esmeralda700)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(original == nil ? "Posteo nuevo" : "Editar posteo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { if p.titulo.isEmpty && p.fotos.isEmpty { cerrar() } else { descartar = true } }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Boton(titulo: programar ? "Programar" : (original == nil ? "Publicar" : "Guardar"), alto: .alto, ancho: true, habilitado: listo) {
                    var final = p
                    final.creadorId = estado.yo.id
                    final.programado = programar ? (p.programado ?? Fecha.en(dias: 1, horas: 2)) : nil
                    if original == nil { final.fecha = final.programado ?? Date() }
                    estado.publicar(final)
                    cerrar()
                }
                .padding(.horizontal, Espacio.margen).padding(.vertical, 8).background(Color.white)
            }
            .confirmationDialog("¿Descartar el posteo?", isPresented: $descartar, titleVisibility: .visible) {
                Button("Descartar", role: .destructive) { cerrar() }
                Button("Seguir editando", role: .cancel) {}
            }
            .interactiveDismissDisabled(!p.titulo.isEmpty)
            .onChange(of: items) { _, nuevos in cargar(nuevos) }
        }
    }

    @ViewBuilder private var contenidoTipo: some View {
        switch p.tipo {
        case .fotos:
            if p.fotos.isEmpty {
                PhotosPicker(selection: $items, maxSelectionCount: 10, matching: .images) {
                    VStack(spacing: 8) {
                        IconoVista(.foto, tamano: 28).foregroundStyle(Color.esmeralda700)
                        Text("Elegí hasta 10 fotos").tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                    }
                    .frame(maxWidth: .infinity).frame(height: 180)
                    .background(Color.esmeralda50, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.esmeralda.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])))
                }
            } else {
                GrillaFotos(fotos: p.fotos, alto: 196).padding(.horizontal, -12)
                HStack {
                    PhotosPicker(selection: $items, maxSelectionCount: 10, matching: .images) {
                        Text("Cambiar fotos").tipo(.texto(14, 700)).foregroundStyle(Color.esmeralda700).frame(minHeight: 44)
                    }
                    Spacer()
                    Text(Texto.plural(p.fotos.count, "foto", "fotos")).tipo(.texto(13, 500)).foregroundStyle(Color.gris)
                }
            }
        case .audio:
            GrabadorAudio(segundos: $p.audioSegundos, grabando: $grabando)
        case .texto:
            EmptyView()
        }
    }

    private func cargar(_ nuevos: [PhotosPickerItem]) {
        guard !nuevos.isEmpty else { return }
        Task {
            var fotos: [Imagen] = []
            for i in nuevos {
                if let d = try? await i.loadTransferable(type: Data.self), let chica = Imagenes.achicar(d, lado: 1400) {
                    fotos.append(Imagen(datos: chica, fx: 0.5, fy: 0.5, zoom: 1))
                }
            }
            await MainActor.run { withAnimation(.snappy) { p.fotos = fotos } }
        }
    }
}

private struct TiposPosteo: View {
    @Binding var tipo: TipoPosteo
    var body: some View {
        HStack(spacing: 8) {
            ForEach(TipoPosteo.allCases, id: \.self) { t in
                Button {
                    Haptico.seleccion()
                    withAnimation(.snappy) { tipo = t }
                } label: {
                    VStack(spacing: 6) {
                        IconoVista(t.icono, tamano: 22)
                        Text(t.nombre).tipo(.texto(14, 700))
                    }
                    .foregroundStyle(tipo == t ? Color.white : Color.tinta)
                    .frame(maxWidth: .infinity).frame(height: 72)
                    .background(tipo == t ? Color.tinta : Color.white, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(tipo == t ? .clear : Color.linea, lineWidth: 1.5))
                }
                .buttonStyle(Apretable())
                .accessibilityAddTraits(tipo == t ? .isSelected : [])
            }
        }
    }
}

/// «Quién lo ve»: Todos, los que te bancan, o desde un nivel para arriba.
struct QuienLoVe: View {
    @Binding var publico: PublicoPosteo
    @Environment(Estado.self) private var estado

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Etiqueta("Quién lo ve")
            Renglones {
                ChipOpcion(titulo: "Todos", elegido: publico == .todos) { publico = .todos }
                ChipOpcion(titulo: "Los que te bancan", elegido: publico == .quienesTeBancan) { publico = .quienesTeBancan }
                ForEach(estado.yo.nivelesActivos.dropFirst()) { n in
                    ChipOpcion(titulo: estado.yo.publicoTexto(.desde(n.id)), elegido: publico == .desde(n.id)) { publico = .desde(n.id) }
                }
            }
        }
    }
}

/// Grabador (simulado): toca para grabar, toca para parar.
private struct GrabadorAudio: View {
    @Binding var segundos: Int
    @Binding var grabando: Bool

    var body: some View {
        VStack(spacing: 12) {
            if segundos > 0 && !grabando {
                ReproductorAudio(segundos: segundos)
            } else {
                OndaAudio(avance: grabando ? 1 : 0).opacity(grabando ? 1 : 0.4)
                Text(String(format: "%d:%02d", segundos / 60, segundos % 60)).tipo(.numero(28)).foregroundStyle(Color.tinta)
            }
            Button {
                Haptico.suave()
                if !grabando { segundos = 0 }
                grabando.toggle()
            } label: {
                HStack(spacing: 8) {
                    if grabando { RoundedRectangle(cornerRadius: 3).fill(.white).frame(width: 14, height: 14) } else { IconoVista(.audio, tamano: 20) }
                    Text(grabando ? "Parar" : (segundos > 0 ? "Grabar de nuevo" : "Grabar")).tipo(.texto(16, 700))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20).frame(height: 52)
                .background(grabando ? Color.error : Color.tinta, in: Capsule())
            }
            .buttonStyle(Apretable())
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.fondo, in: RoundedRectangle(cornerRadius: 16))
        .task(id: grabando) {
            while grabando {
                try? await Task.sleep(for: .seconds(1))
                if grabando { segundos += 1 }
            }
        }
    }
}
