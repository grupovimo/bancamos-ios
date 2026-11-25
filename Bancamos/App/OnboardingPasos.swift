import SwiftUI
import PhotosUI

// MARK: - Creador

/// Nombre, mail y el link de la página (con el aviso de si está libre).
struct PasoNombre: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void

    static let tomados: Set<String> = Set(DatosDeMuestra.creadores.map(\.usuario)).subtracting(["anamazzei"]).union(["bancamos", "admin", "ayuda", "ana"])
    private var libre: Bool { !Self.tomados.contains(b.usuario) }
    private var listo: Bool { b.nombre.limpio.count >= 2 && b.usuario.count >= 3 && libre && b.email.contains("@") }

    var body: some View {
        MarcoPaso(etiqueta: "Tu página", titulo: "¿Cómo te llamás?", sub: "Así te va a ver tu gente.", habilitado: listo) {
            VStack(alignment: .leading, spacing: 12) {
                Campo(etiqueta: "Nombre", texto: $b.nombre, placeholder: "Ana Mazzei", mayusculas: .words)
                    .onChange(of: b.nombre) { _, n in
                        if !b.usuarioEditado { b.usuario = Texto.usuario(n.replacingOccurrences(of: " ", with: "")) }
                    }
                Campo(etiqueta: "Tu mail", texto: $b.email, placeholder: "vos@gmail.com", teclado: .emailAddress, mayusculas: .never)
                Campo(etiqueta: "Tu link", texto: Binding(get: { b.usuario }, set: { b.usuario = Texto.usuario($0); b.usuarioEditado = true }),
                      placeholder: "tunombre", prefijo: "bancamos.com.ar/", mayusculas: .never)
                if b.usuario.count >= 3 {
                    HStack(spacing: 6) {
                        IconoVista(libre ? .tilde : .cruz, tamano: 16)
                        Text(libre ? "Está libre. Es tuyo." : "Ya está en uso. Probá con \(b.usuario).ok o \(b.usuario)\(Fecha.diaDelMes())")
                            .tipo(.texto(14, 600))
                    }
                    .foregroundStyle(libre ? Color.ok : Color.error)
                    .transition(.opacity)
                }
            }
        } accion: { siguiente() }
    }
}

/// Qué hace (hasta tres categorías) y su frase.
struct PasoRubro: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void

    var body: some View {
        MarcoPaso(etiqueta: "Tu página", titulo: "¿Qué hacés?", sub: "Elegí hasta tres. Sirve para que te encuentren al explorar.",
                  habilitado: !b.categorias.isEmpty) {
            VStack(alignment: .leading, spacing: 20) {
                Renglones {
                    ForEach(Categoria.allCases) { c in
                        ChipOpcion(titulo: c.nombre, simbolo: c.simbolo, elegido: b.categorias.contains(c)) {
                            if let i = b.categorias.firstIndex(of: c) { b.categorias.remove(at: i) }
                            else if b.categorias.count < 3 { b.categorias.append(c) }
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Campo(etiqueta: "Contalo en una línea", texto: $b.frase, placeholder: "Dibujo un gato por día.", limite: 80)
                    Sec("Va debajo de tu nombre, en tu página.")
                }
            }
        } accion: { siguiente() }
    }
}

/// Foto y portada, con PhotosPicker de verdad y la vista previa de la página.
struct PasoFotos: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void
    @State private var itemFoto: PhotosPickerItem?
    @State private var itemPortada: PhotosPickerItem?

    var body: some View {
        MarcoPaso(etiqueta: "Tu página", titulo: "Tu foto y tu portada", sub: "Con una foto tuya haciendo lo tuyo, te bancan más.",
                  saltar: siguiente) {
            VStack(alignment: .leading, spacing: 0) {
                PhotosPicker(selection: $itemPortada, matching: .images) {
                    FotoRecortada(imagen: b.imagenPortada, zoom: 1)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: Radio.foto, style: .continuous))
                        .overlay(alignment: .topTrailing) { etiquetaCambiar(b.imagenPortada.existe ? "Cambiar portada" : "Elegir portada") }
                }
                .accessibilityLabel("Elegir la portada")
                HStack(alignment: .bottom, spacing: 12) {
                    PhotosPicker(selection: $itemFoto, matching: .images) {
                        Avatar(imagen: b.imagenFoto, iniciales: b.iniciales, tamano: 96, aro: 4)
                            .shadow(color: .black.opacity(0.12), radius: 9, y: 8)
                            .overlay(alignment: .bottomTrailing) {
                                IconoVista(.foto, tamano: 16).foregroundStyle(.white)
                                    .frame(width: 34, height: 34).background(Color.tinta, in: Circle())
                                    .overlay(Circle().stroke(.white, lineWidth: 3))
                            }
                    }
                    .accessibilityLabel("Elegir tu foto")
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, -48)
                Text(b.nombre.isEmpty ? "Tu nombre" : b.nombre).tipo(.titulo(28)).foregroundStyle(Color.tinta).padding(.top, 10)
                Sec(b.frase.isEmpty ? "Tu frase" : b.frase, tamano: 15).padding(.top, 2)
            }
        } accion: { siguiente() }
        .onChange(of: itemFoto) { _, i in cargar(i) { b.foto = $0 } }
        .onChange(of: itemPortada) { _, i in cargar(i) { b.portada = $0 } }
    }

    private func etiquetaCambiar(_ t: String) -> some View {
        HStack(spacing: 6) {
            IconoVista(.foto, tamano: 16)
            Text(t).tipo(.texto(14, 700))
        }
        .foregroundStyle(Color.tinta)
        .padding(.horizontal, 12).frame(height: 36)
        .background(.white.opacity(0.95), in: Capsule())
        .padding(10)
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

/// La primera meta, con la vista previa de cómo se ve.
struct PasoMeta: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void
    private let ideas = ["Equipo nuevo", "Grabar el disco", "Imprimir un libro", "Un viaje para el canal"]

    var body: some View {
        MarcoPaso(etiqueta: "Tu página", titulo: "Tu primera meta", sub: "Una meta clara entusiasma: la gente ve cuánto falta y empuja.",
                  habilitado: !b.metaTitulo.limpio.isEmpty && b.metaMonto >= 1000, saltar: siguiente) {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ideas, id: \.self) { i in
                            ChipOpcion(titulo: i, elegido: b.metaTitulo == i) { b.metaTitulo = i }
                        }
                    }
                }
                .scrollClipDisabled()
                Campo(etiqueta: "¿Para qué es?", texto: $b.metaTitulo, placeholder: "Imprimir mi primer libro", limite: 50)
                CampoPlata(etiqueta: "¿Cuánto necesitás?", monto: $b.metaMonto)
                HStack(spacing: 8) {
                    ForEach([200_000, 500_000, 1_000_000], id: \.self) { m in
                        ChipOpcion(titulo: Plata.corto(m), elegido: b.metaMonto == m) { b.metaMonto = m }
                    }
                }
                Etiqueta("Así se ve").padding(.top, 10)
                TarjetaMeta(meta: Meta(id: "prev", titulo: b.metaTitulo.isEmpty ? "Tu meta" : b.metaTitulo, descripcion: "",
                                       objetivo: max(b.metaMonto, 1), recaudado: 0, creada: Date()),
                            pie: "Arranca en cero. Cada aporte la llena.")
            }
        } accion: { siguiente() }
    }
}

/// Los niveles sugeridos: se prenden, se apagan y se les cambia el precio.
struct PasoNiveles: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void

    var body: some View {
        MarcoPaso(etiqueta: "Tu página", titulo: "Niveles para los que te bancan cada mes",
                  sub: "Te sugerimos tres. Cambiales el nombre y el precio, o apagá los que no quieras.",
                  habilitado: !b.nivelesElegidos.isEmpty, saltar: siguiente) {
            VStack(spacing: 10) {
                ForEach($b.niveles) { $n in
                    FilaNivelOnb(nivel: $n, elegido: Binding(get: { b.nivelesElegidos.contains(n.id) },
                                                             set: { v in if v { b.nivelesElegidos.insert(n.id) } else { b.nivelesElegidos.remove(n.id) } }))
                }
                Text("Bancamos se queda con el 3 % de cada cuota. Mercado Pago cobra lo suyo aparte.")
                    .tipo(.texto(13, 400)).foregroundStyle(Color.gris).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
            }
        } accion: { siguiente() }
    }
}

private struct FilaNivelOnb: View {
    @Binding var nivel: Nivel
    @Binding var elegido: Bool

    var body: some View {
        Borde(relleno: 14, color: elegido ? .tinta : .linea, ancho: elegido ? 2 : 1.5, fondo: elegido ? .esmeralda50 : .white) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(nivel.nombre).tipo(.titulo(20)).foregroundStyle(Color.tinta)
                    Text(nivel.descripcion).tipo(.texto(14, 400)).foregroundStyle(Color.gris).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Toggle("", isOn: $elegido.animation(.snappy)).labelsHidden().tint(.tinta)
                    .accessibilityLabel("Usar \(nivel.nombre)")
            }
            if elegido {
                HStack(spacing: 10) {
                    Campo(etiqueta: "Nombre", texto: $nivel.nombre, limite: 20)
                    CampoPlata(etiqueta: "Por mes", monto: $nivel.precio)
                }
                .padding(.top, 12)
                Text("Por cada persona te llegan \(Plata.texto(nivel.neto)).").tipo(.texto(13, 500)).foregroundStyle(Color.gris).padding(.top, 8)
            }
        }
    }
}

/// Conectar Mercado Pago (simulado): la plata va directo a su cuenta y Bancamos cobra 3 %.
struct PasoMercadoPago: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void
    @State private var autorizar = false

    var body: some View {
        MarcoPaso(etiqueta: "Para cobrar", titulo: "Conectá tu Mercado Pago",
                  boton: b.mpConectado ? "Seguir" : "Conectar Mercado Pago", variante: b.mpConectado ? .prim : .mp,
                  saltar: b.mpConectado ? nil : siguiente) {
            VStack(alignment: .leading, spacing: 0) {
                FlujoPlata()
                if b.mpConectado {
                    HStack(spacing: 12) {
                        IconoVista(.tilde, tamano: 20).foregroundStyle(.white).frame(width: 36, height: 36).background(Color.ok, in: Circle())
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Conectado").tipo(.texto(16, 700)).foregroundStyle(Color.tinta)
                            Text(b.email.isEmpty ? "Tu cuenta de Mercado Pago" : b.email).tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.ok100, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.top, 14)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
                PuntosMP().padding(.top, 8)
                if !b.mpConectado {
                    Text("Te lleva a Mercado Pago y volvés solo.").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                        .frame(maxWidth: .infinity).padding(.top, 10)
                }
            }
        } accion: {
            if b.mpConectado { siguiente() } else { autorizar = true }
        }
        .sheet(isPresented: $autorizar) {
            HojaAutorizarMP(email: b.email) { ok in
                if ok { withAnimation(.snappy) { b.mpConectado = true } }
            }
        }
    }
}

/// El dibujo «Tu gente → Tu Mercado Pago» (.flujo).
struct FlujoPlata: View {
    var body: some View {
        Borde {
            HStack(spacing: 10) {
                nodo("Tu gente", fondo: .esmeralda100) { IconoVista(.gente, tamano: 24).foregroundStyle(Color.esmeralda700) }
                IconoVista(.flecha, tamano: 24).foregroundStyle(Color.tinta)
                nodo("Tu Mercado Pago", fondo: .mp) { IconoVista(.mp, tamano: 34).foregroundStyle(.white) }
            }
            .padding(.vertical, 22).padding(.horizontal, 16)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("La plata va de tu gente a tu Mercado Pago")
    }

    private func nodo<I: View>(_ t: String, fondo: Color, @ViewBuilder icono: () -> I) -> some View {
        VStack(spacing: 8) {
            icono().frame(width: 64, height: 64).background(fondo, in: Circle())
            Text(t).tipo(.texto(13, 700)).foregroundStyle(Color.tinta)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Los tres puntos de la plata (.punto).
struct PuntosMP: View {
    var body: some View {
        VStack(spacing: 0) {
            punto("La plata entra directo a tu cuenta, al momento.")
            Divisor()
            punto("Bancamos nunca la tiene. Sólo descuenta su 3 %.")
            Divisor()
            punto("Desconectás cuando quieras.")
        }
    }
    private func punto(_ t: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconoVista(.tilde, tamano: 20).foregroundStyle(Color.ok)
            Text(t).tipo(.texto(15, 400)).foregroundStyle(Color.tinta).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Quien banca

struct PasoNombreFan: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void
    var body: some View {
        MarcoPaso(etiqueta: "Tu cuenta", titulo: "¿Cómo te llamás?", sub: "Para que sepan quién los banca. Si querés, podés bancar sin mostrar tu nombre.",
                  habilitado: b.nombre.limpio.count >= 2 && b.email.contains("@")) {
            VStack(spacing: 12) {
                Campo(etiqueta: "Nombre", texto: $b.nombre, placeholder: "Martín Gómez", mayusculas: .words)
                Campo(etiqueta: "Tu mail", texto: $b.email, placeholder: "vos@gmail.com", teclado: .emailAddress, mayusculas: .never)
                Sec("Te mandamos los recibos y el aviso antes de cada cuota.")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } accion: { siguiente() }
    }
}

struct PasoIntereses: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void
    var body: some View {
        MarcoPaso(etiqueta: "Tu cuenta", titulo: "¿Qué te gusta?", sub: "Te mostramos primero a quienes hacen eso.", habilitado: !b.intereses.isEmpty,
                  saltar: siguiente) {
            Renglones {
                ForEach(Categoria.allCases) { c in
                    ChipOpcion(titulo: c.nombre, simbolo: c.simbolo, elegido: b.intereses.contains(c)) {
                        if let i = b.intereses.firstIndex(of: c) { b.intereses.remove(at: i) } else { b.intereses.append(c) }
                    }
                }
            }
        } accion: { siguiente() }
    }
}

struct PasoSeguir: View {
    @Bindable var b: BorradorOnb
    var siguiente: () -> Void
    @Environment(Estado.self) private var estado

    var body: some View {
        MarcoPaso(etiqueta: "Tu cuenta", titulo: "Seguí a quienes te gustan", sub: "Vas a ver lo que publican. Seguir es gratis.",
                  boton: b.siguiendo.isEmpty ? "Seguir sin elegir" : "Seguir") {
            VStack(spacing: 0) {
                ForEach(estado.sugeridos(para: b.intereses)) { c in
                    fila(c)
                    if c.id != estado.creadores.last?.id { Divisor(izquierda: 64) }
                }
            }
        } accion: { siguiente() }
    }

    private func fila(_ c: Creador) -> some View {
        let sigo = b.siguiendo.contains(c.id)
        return HStack(spacing: 12) {
            Avatar(c, tamano: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(c.nombre).tipo(.texto(16, 700)).foregroundStyle(Color.tinta)
                Text("\(c.categoria.nombre) · \(c.frase)").tipo(.texto(13, 400)).foregroundStyle(Color.gris).lineLimit(2)
            }
            Spacer(minLength: 8)
            Button {
                Haptico.seleccion()
                withAnimation(.snappy) { if sigo { b.siguiendo.removeAll { $0 == c.id } } else { b.siguiendo.append(c.id) } }
            } label: {
                Text(sigo ? "Siguiendo" : "Seguir").tipo(.texto(14, 700))
                    .foregroundStyle(sigo ? Color.tinta : .white)
                    .padding(.horizontal, 14).frame(height: 36)
                    .background(sigo ? Color.fondo : Color.tinta, in: Capsule())
                    .frame(minHeight: 44).contentShape(Rectangle())
            }
            .buttonStyle(Apretable())
            .accessibilityLabel(sigo ? "Dejar de seguir a \(c.nombre)" : "Seguir a \(c.nombre)")
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Listo

struct PasoListo: View {
    let b: BorradorOnb
    var terminar: (Bool) -> Void

    var body: some View {
        ZStack {
            Papelitos()
            VStack(spacing: 0) {
                Spacer(minLength: 10)
                Avatar(imagen: b.lado == .creador ? b.imagenFoto : nil, iniciales: b.iniciales, tamano: 104, aro: 5)
                    .shadow(color: .black.opacity(0.14), radius: 13, y: 12)
                Titulo(b.lado == .creador ? "¡Tu página ya está en línea!" : "¡Listo, \(b.nombre.split(separator: " ").first.map(String.init) ?? "")!", tamano: 34)
                    .multilineTextAlignment(.center).padding(.top, 22)
                Sec(b.lado == .creador ? "Compartila donde estés: Instagram, tu bio, un QR en la feria."
                                       : (b.siguiendo.isEmpty ? "Explorá y encontrá a quién bancar." : "Ya seguís a \(Texto.plural(b.siguiendo.count, "persona", "personas")). Lo que publiquen te aparece en Novedades."),
                    tamano: 17)
                    .multilineTextAlignment(.center).padding(.top, 8).padding(.horizontal, 10)
                if b.lado == .creador {
                    HStack(spacing: 8) {
                        IconoVista(.candado, tamano: 14)
                        Text("bancamos.com.ar/\(b.usuario)").tipo(.texto(15, 600))
                    }
                    .foregroundStyle(Color.tinta)
                    .padding(.horizontal, 16).frame(height: 44)
                    .background(Color.fondo, in: Capsule())
                    .padding(.top, 18)
                }
                Spacer(minLength: 10)
                VStack(spacing: 10) {
                    Boton(titulo: b.lado == .creador ? "Ir a mi panel" : "Empezar a explorar", alto: .alto, ancho: true) { terminar(false) }
                    Boton(titulo: "Ver la app con datos de ejemplo", variante: .blanco, alto: .normal, ancho: true) { terminar(true) }
                }
                .padding(.bottom, 12)
            }
            .padding(.horizontal, Espacio.margen)
        }
    }
}

// MARK: - Imágenes

enum Imagenes {
    /// Achica a 1200 px de lado y pasa a JPEG (las fotos del teléfono pesan mucho).
    static func achicar(_ d: Data, lado: CGFloat = 1200) -> Data? {
        guard let ui = UIImage(data: d) else { return nil }
        let esc = min(1, lado / max(ui.size.width, ui.size.height))
        let t = CGSize(width: ui.size.width * esc, height: ui.size.height * esc)
        let r = UIGraphicsImageRenderer(size: t)
        return r.jpegData(withCompressionQuality: 0.82) { _ in ui.draw(in: CGRect(origin: .zero, size: t)) }
    }
}
