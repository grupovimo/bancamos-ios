import SwiftUI
import PhotosUI

enum SeccionPagina: String, CaseIterable, Hashable {
    case datos, fotos, sobreMi, redes, montos

    var titulo: String {
        switch self {
        case .datos: return "Nombre, link y rubro"
        case .fotos: return "Foto y portada"
        case .sobreMi: return "Sobre vos"
        case .redes: return "Tus redes"
        case .montos: return "Montos y agradecimiento"
        }
    }
    var icono: Icono {
        switch self {
        case .datos: return .persona
        case .fotos: return .foto
        case .sobreMi: return .texto
        case .redes: return .link
        case .montos: return .corazon
        }
    }
}

/// Mi página: cómo está, qué falta, cada parte para editar, «Así te ven», el QR y compartir.
struct MiPagina: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav

    private var pendientes: [SeccionPagina] {
        var p: [SeccionPagina] = []
        if !estado.yo.foto.existe || !estado.yo.portada.existe { p.append(.fotos) }
        if estado.yo.sobreMi.limpio.isEmpty { p.append(.sobreMi) }
        if estado.yo.redes.isEmpty { p.append(.redes) }
        return p
    }

    var body: some View {
        let total = SeccionPagina.allCases.count
        let hechas = total - pendientes.count
        let completo: Int = hechas * 100 / total
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button { nav.ir(.asiTeVen) } label: { cabecera }
                    .buttonStyle(Apretable())
                HStack(spacing: 10) {
                    Boton(titulo: "Así te ven", icono: .ojo, variante: .osc, alto: .normal, ancho: true) { nav.ir(.asiTeVen) }
                    Boton(titulo: "QR", variante: .blanco, alto: .normal) { nav.abrir(.qr) }
                    ShareLink(item: estado.yo.url, message: Text("Bancame en Bancamos")) {
                        IconoVista(.compartir, tamano: 20).foregroundStyle(Color.tinta)
                            .frame(width: 52, height: 52)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.control))
                            .overlay(RoundedRectangle(cornerRadius: Radio.control).strokeBorder(Color.linea, lineWidth: 1.5))
                    }
                    .simultaneousGesture(TapGesture().onEnded { estado.marcarLinkCompartido() })
                    .accessibilityLabel("Compartir mi link")
                }
                .padding(.top, 12)
                if completo < 100 {
                    Tarjeta(relleno: 16) {
                        HStack {
                            Text("Tu página está al \(completo) %").tipo(.texto(16, 700)).foregroundStyle(Color.tinta)
                            Spacer()
                        }
                        BarraMeta(fraccion: Double(completo) / 100, alto: 8).padding(.top, 10)
                        Text("Las páginas completas reciben más apoyos. Te falta: \(pendientes.map { $0.titulo.lowercased() }.joined(separator: ", ")).")
                            .tipo(.texto(14, 400)).foregroundStyle(Color.gris).padding(.top, 8)
                    }
                    .padding(.top, 16)
                }
                TituloSeccion(texto: "Editar")
                Tarjeta {
                    ForEach(Array(SeccionPagina.allCases.enumerated()), id: \.element) { i, s in
                        if i > 0 { Divisor(izquierda: 68) }
                        Button { nav.abrir(.editar(s)) } label: {
                            FilaMenu(icono: s.icono, titulo: s.titulo, sub: resumen(s),
                                     colorIcono: pendientes.contains(s) ? .alerta : .esmeralda700,
                                     fondoIcono: pendientes.contains(s) ? .alerta100 : .esmeralda100)
                        }
                        .buttonStyle(Apretable())
                    }
                }
                TituloSeccion(texto: "Lo que ofrecés")
                Tarjeta {
                    Button { nav.ir(.niveles) } label: {
                        FilaMenu(icono: .capas, titulo: "Niveles", sub: estado.yo.nivelesActivos.map { "\($0.nombre) \(Plata.texto($0.precio))" }.joined(separator: " · "))
                    }
                    .buttonStyle(Apretable())
                    Divisor(izquierda: 68)
                    Button { nav.ir(.metas) } label: {
                        FilaMenu(icono: .bandera, titulo: "Metas", sub: estado.yo.metaActiva.map { "\($0.titulo) · \($0.porcentaje) %" } ?? "Sin meta activa")
                    }
                    .buttonStyle(Apretable())
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Mi página")
    }

    private var cabecera: some View {
        VStack(alignment: .leading, spacing: 0) {
            FotoRecortada(imagen: estado.yo.portada, zoom: 1).frame(height: 120)
            HStack(alignment: .bottom, spacing: 12) {
                Avatar(estado.yo, tamano: 72, aro: 4)
                VStack(alignment: .leading, spacing: 2) {
                    Text(estado.yo.nombre).tipo(.titulo(22)).foregroundStyle(Color.tinta)
                    Text(estado.yo.link).tipo(.texto(14, 500)).foregroundStyle(Color.esmeralda700)
                }
                .padding(.bottom, 4)
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, -36).padding(.bottom, 16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .sombra()
    }

    private func resumen(_ s: SeccionPagina) -> String {
        let c = estado.yo
        switch s {
        case .datos: return "\(c.nombre) · \(c.categoria.nombre)"
        case .fotos: return c.foto.existe && c.portada.existe ? "Listas" : "Falta completar"
        case .sobreMi: return c.sobreMi.isEmpty ? "Contá quién sos y para qué es la plata" : c.sobreMi
        case .redes: return c.redes.isEmpty ? "Instagram, YouTube, Twitch…" : c.redes.joined(separator: " · ")
        case .montos: return c.montosSugeridos.map { Plata.texto($0) }.joined(separator: " · ")
        }
    }
}

/// Editor de una parte de la página.
struct EditarSeccion: View {
    let seccion: SeccionPagina
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var c: Creador = DatosDeMuestra.ana
    @State private var cargado = false
    @State private var itemFoto: PhotosPickerItem?
    @State private var itemPortada: PhotosPickerItem?
    @State private var redNueva = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) { contenido }
                    .padding(.horizontal, Espacio.margen)
                    .padding(.top, 10).padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(seccion.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if !redNueva.limpio.isEmpty { c.redes.append(redNueva.limpio) }
                        estado.guardar(creador: c)
                        cerrar()
                    }
                    .font(Estilo.texto(16, 700).font())
                    .disabled(c.nombre.limpio.isEmpty || c.usuario.count < 3)
                }
            }
            .onAppear { if !cargado { c = estado.yo; cargado = true } }
            .onChange(of: itemFoto) { _, i in cargar(i) { c.foto = Imagen(datos: $0, fx: 0.5, fy: 0.5, zoom: 1) } }
            .onChange(of: itemPortada) { _, i in cargar(i) { c.portada = Imagen(datos: $0, fx: 0.5, fy: 0.5, zoom: 1) } }
        }
    }

    @ViewBuilder private var contenido: some View {
        switch seccion {
        case .datos:
            Campo(etiqueta: "Nombre", texto: $c.nombre, mayusculas: .words)
            Campo(etiqueta: "Tu link", texto: Binding(get: { c.usuario }, set: { c.usuario = Texto.usuario($0) }), prefijo: "bancamos.com.ar/", mayusculas: .never)
            Campo(etiqueta: "Tu frase", texto: $c.frase, limite: 80)
            Campo(etiqueta: "Ciudad", texto: $c.ciudad, mayusculas: .words)
            Etiqueta("Rubro").padding(.top, 6)
            Renglones {
                ForEach(Categoria.allCases) { k in
                    ChipOpcion(titulo: k.nombre, simbolo: k.simbolo, elegido: c.categoria == k) { c.categoria = k }
                }
            }
        case .fotos:
            PhotosPicker(selection: $itemPortada, matching: .images) {
                FotoRecortada(imagen: c.portada, zoom: 1).frame(height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: Radio.foto, style: .continuous))
                    .overlay(alignment: .bottomTrailing) { pastilla("Cambiar portada") }
            }
            HStack(spacing: 16) {
                PhotosPicker(selection: $itemFoto, matching: .images) {
                    Avatar(c, tamano: 96, aro: 0)
                        .overlay(alignment: .bottomTrailing) {
                            IconoVista(.foto, tamano: 16).foregroundStyle(.white).frame(width: 34, height: 34)
                                .background(Color.tinta, in: Circle()).overlay(Circle().stroke(.white, lineWidth: 3))
                        }
                }
                .accessibilityLabel("Cambiar tu foto")
                Sec("Una foto tuya, de frente y con luz. La portada, haciendo lo tuyo.", tamano: 15)
            }
            .padding(.top, 6)
        case .sobreMi:
            Campo(etiqueta: "Sobre vos", texto: $c.sobreMi, placeholder: "Quién sos, qué hacés y para qué es la plata.", lineas: 6, limite: 600)
            Sec("Contá para qué es la plata: la gente banca más cuando sabe a dónde va.")
        case .redes:
            ForEach(Array(c.redes.enumerated()), id: \.offset) { i, r in
                HStack {
                    IconoVista(.link, tamano: 18).foregroundStyle(Color.esmeralda700)
                    Text(r).tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                    Spacer()
                    Button { c.redes.remove(at: i) } label: { IconoVista(.cruz, tamano: 16).foregroundStyle(Color.gris).frame(width: 44, height: 44) }
                        .accessibilityLabel("Sacar \(r)")
                }
                .padding(.leading, 14)
                .background(Color.fondo, in: RoundedRectangle(cornerRadius: 12))
            }
            Campo(etiqueta: "Agregar una red", texto: $redNueva, placeholder: "instagram.com/tuusuario", teclado: .URL, mayusculas: .never)
            Boton(titulo: "Agregar", icono: .mas, variante: .blanco, alto: .chico, habilitado: !redNueva.limpio.isEmpty) {
                withAnimation(.snappy) { c.redes.append(redNueva.limpio); redNueva = "" }
            }
        case .montos:
            Etiqueta("Montos sugeridos para bancar una vez")
            HStack(spacing: 10) {
                ForEach(c.montosSugeridos.indices, id: \.self) { i in
                    CampoPlata(etiqueta: "Monto \(i + 1)", monto: $c.montosSugeridos[i])
                }
            }
            Campo(etiqueta: "Lo que ven después de bancarte", texto: $c.agradecimiento, lineas: 2, limite: 140).padding(.top, 8)
        }
    }

    private func pastilla(_ t: String) -> some View {
        HStack(spacing: 6) { IconoVista(.foto, tamano: 16); Text(t).tipo(.texto(14, 700)) }
            .foregroundStyle(Color.tinta).padding(.horizontal, 12).frame(height: 36)
            .background(.white.opacity(0.95), in: Capsule()).padding(10)
    }

    private func cargar(_ item: PhotosPickerItem?, _ poner: @escaping (Data) -> Void) {
        guard let item else { return }
        Task {
            if let d = try? await item.loadTransferable(type: Data.self), let chica = Imagenes.achicar(d) {
                await MainActor.run { withAnimation(.snappy) { poner(chica) } }
            }
        }
    }
}

/// «Así te ven»: la página pública tal cual, sin poder tocar los pagos.
struct AsiTeVen: View {
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var volver

    var body: some View {
        PaginaPublica(creador: estado.yo, vistaPrevia: true, recibePagos: estado.panel.cuentaMP.conectada, volver: { volver() })
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .bottom) {
                Text("Vista previa: así te ve quien entra a \(estado.yo.link)")
                    .tipo(.texto(13, 600)).foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Color.tinta.opacity(0.92), in: Capsule())
                    .padding(.bottom, 10)
            }
    }
}

/// El QR de la página, para imprimir o subir a una historia.
struct HojaQR: View {
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tarjeta.padding(.top, 8)
                Text("Imprimilo para la feria o el show, o subilo a una historia.").tipo(.texto(15, 400)).foregroundStyle(Color.gris)
                    .multilineTextAlignment(.center).padding(.top, 16).padding(.horizontal, 20)
                Spacer()
                VStack(spacing: 10) {
                    ShareLink(item: estado.yo.url, message: Text("Bancame en Bancamos")) {
                        HStack(spacing: 8) { IconoVista(.compartir, tamano: 20); Text("Compartir mi link").tipo(.texto(16, 700)) }
                            .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 56)
                            .background(Color.esmeralda700, in: RoundedRectangle(cornerRadius: Radio.control))
                    }
                    .simultaneousGesture(TapGesture().onEnded { estado.marcarLinkCompartido() })
                    CompartirBoton(generar: { () -> Any in if let i = imagenTarjeta() { return i } else { return estado.yo.url } }) {
                        HStack(spacing: 8) { IconoVista(.descarga, tamano: 20); Text("Guardar el QR").tipo(.texto(16, 700)) }
                            .foregroundStyle(Color.tinta).frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.control))
                            .overlay(RoundedRectangle(cornerRadius: Radio.control).strokeBorder(Color.linea, lineWidth: 1.5))
                    }
                    Button {
                        UIPasteboard.general.string = estado.yo.url.absoluteString
                        estado.marcarLinkCompartido()
                        Haptico.exito()
                        estado.avisar("Link copiado.")
                    } label: {
                        HStack(spacing: 6) { IconoVista(.copiar, tamano: 18); Text("Copiar link").tipo(.texto(15, 700)) }
                            .foregroundStyle(Color.esmeralda700).frame(minHeight: 44)
                    }
                }
                .padding(.horizontal, Espacio.margen).padding(.bottom, 12)
            }
            .background(Color.fondo)
            .navigationTitle("Tu QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Listo") { cerrar() } } }
        }
    }

    private var tarjeta: some View {
        VStack(spacing: 14) {
            Avatar(estado.yo, tamano: 64)
            Text(estado.yo.nombre).tipo(.titulo(24)).foregroundStyle(Color.tinta)
            if let q = QR.imagen(estado.yo.url.absoluteString) {
                Image(uiImage: q).interpolation(.none).resizable().frame(width: 210, height: 210)
                    .overlay { Image("isotipo").resizable().scaledToFit().frame(width: 34).padding(8).background(.white, in: RoundedRectangle(cornerRadius: 10)) }
                    .accessibilityLabel("Código QR de \(estado.yo.link)")
            }
            Text(estado.yo.link).tipo(.texto(16, 600)).foregroundStyle(Color.tinta)
            Image("logotipo").resizable().scaledToFit().frame(height: 18).opacity(0.9)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .sombra()
        .padding(.horizontal, 32)
    }

    @MainActor private func imagenTarjeta() -> UIImage? {
        let r = ImageRenderer(content: tarjeta.frame(width: 390).padding(20).background(Color.fondo).environment(estado))
        r.scale = 3
        return r.uiImage
    }
}
