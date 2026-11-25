import SwiftUI
import PhotosUI

/// Los pasos del onboarding, en orden. Los tres primeros son la bienvenida; después se elige el lado.
enum PasoOnb: Hashable {
    case bienvenida(Int), elegir
    case nombre, rubro, fotos, meta, niveles, mercadoPago, listoCreador
    case nombreFan, intereses, seguir, listoFan

    static let creador: [PasoOnb] = [.bienvenida(0), .bienvenida(1), .bienvenida(2), .elegir, .nombre, .rubro, .fotos, .meta, .niveles, .mercadoPago, .listoCreador]
    static let fan: [PasoOnb] = [.bienvenida(0), .bienvenida(1), .bienvenida(2), .elegir, .nombreFan, .intereses, .seguir, .listoFan]
}

/// El borrador que se va llenando; al final se guarda como `Perfil`.
@Observable
final class BorradorOnb {
    var lado: Lado = .creador
    var nombre = ""
    var email = ""
    var usuario = ""
    var usuarioEditado = false
    var frase = ""
    var categorias: [Categoria] = []
    var foto: Data?
    var portada: Data?
    var fotoMuestra: Imagen?
    var portadaMuestra: Imagen?
    var metaTitulo = ""
    var metaMonto = 0
    var niveles: [Nivel] = Perfil.nivelesSugeridos
    var nivelesElegidos: Set<String> = ["n1", "n2", "n3"]
    var mpConectado = false
    var intereses: [Categoria] = []
    var siguiendo: [String] = []

    /// Arranca a mitad del onboarding con los datos de la maqueta (capturas).
    func llenarDeMuestra(_ l: Lado) {
        lado = l
        if l == .creador {
            nombre = "Ana Mazzei"; email = "ana.mazzei@gmail.com"; usuario = "anamazzei"; usuarioEditado = true
            frase = "Dibujo un gato por día."; categorias = [.ilustracion]
            fotoMuestra = DatosDeMuestra.ana.foto; portadaMuestra = DatosDeMuestra.ana.portada
            metaTitulo = "Imprimir mi primer libro"; metaMonto = 850_000
        } else {
            nombre = "Martín Gómez"; email = "martin.gomez@gmail.com"
            intereses = [.ilustracion, .musica, .cocina]; siguiendo = ["ana", "tomas"]
        }
    }

    var perfil: Perfil {
        if let foto { Archivo.guardar(foto, "foto.jpg") }
        if let portada { Archivo.guardar(portada, "portada.jpg") }
        return Perfil(lado: lado, nombre: nombre.limpio, email: email.limpio, usuario: usuario, frase: frase.limpio, categorias: categorias,
                      metaTitulo: metaTitulo.limpio, metaMonto: metaMonto, niveles: niveles.filter { nivelesElegidos.contains($0.id) },
                      mpConectado: mpConectado, intereses: intereses, siguiendo: siguiendo, conEjemplos: false)
    }

    var imagenFoto: Imagen { foto.map { Imagen(datos: $0, fx: 0.5, fy: 0.5, zoom: 1) } ?? fotoMuestra ?? .vacia }
    var imagenPortada: Imagen { portada.map { Imagen(datos: $0, fx: 0.5, fy: 0.5, zoom: 1) } ?? portadaMuestra ?? .vacia }
    var iniciales: String { Texto.iniciales(nombre.isEmpty ? "Vos" : nombre) }
}

struct Onboarding: View {
    @Environment(Estado.self) private var estado
    @State private var borrador = BorradorOnb()
    @State private var indice: Int
    @State private var adelante = true

    init(paso: Int = 0, lado: Lado? = nil) {
        _indice = State(initialValue: paso)
        let b = BorradorOnb()
        if let lado { b.lado = lado; if paso > 3 { b.llenarDeMuestra(lado) } }
        _borrador = State(initialValue: b)
    }

    private var pasos: [PasoOnb] { borrador.lado == .creador ? PasoOnb.creador : PasoOnb.fan }
    private var paso: PasoOnb { pasos[min(indice, pasos.count - 1)] }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            switch paso {
            case .bienvenida, .elegir:
                Bienvenida(indice: $indice, borrador: borrador, siguiente: siguiente)
            default:
                VStack(spacing: 0) {
                    BarraPasos(actual: indice - 3, total: pasos.count - 4, atras: atras)
                    contenido
                        .id(indice)
                        .transition(.asymmetric(insertion: .move(edge: adelante ? .trailing : .leading).combined(with: .opacity),
                                                removal: .opacity))
                }
            }
        }
        .animation(.snappy(duration: 0.35), value: indice)
    }

    @ViewBuilder private var contenido: some View {
        switch paso {
        case .nombre: PasoNombre(b: borrador, siguiente: siguiente)
        case .rubro: PasoRubro(b: borrador, siguiente: siguiente)
        case .fotos: PasoFotos(b: borrador, siguiente: siguiente)
        case .meta: PasoMeta(b: borrador, siguiente: siguiente)
        case .niveles: PasoNiveles(b: borrador, siguiente: siguiente)
        case .mercadoPago: PasoMercadoPago(b: borrador, siguiente: siguiente)
        case .listoCreador: PasoListo(b: borrador, terminar: terminar)
        case .nombreFan: PasoNombreFan(b: borrador, siguiente: siguiente)
        case .intereses: PasoIntereses(b: borrador, siguiente: siguiente)
        case .seguir: PasoSeguir(b: borrador, siguiente: siguiente)
        case .listoFan: PasoListo(b: borrador, terminar: terminar)
        default: EmptyView()
        }
    }

    private func siguiente() {
        Haptico.suave()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        adelante = true
        indice = min(indice + 1, pasos.count - 1)
    }

    private func atras() {
        Haptico.seleccion()
        adelante = false
        indice = max(0, indice - 1)
    }

    private func terminar(_ ejemplos: Bool) {
        var p = borrador.perfil
        p.conEjemplos = ejemplos
        if ejemplos && p.lado == .creador { p.mpConectado = true }
        Haptico.exito()
        withAnimation(.easeInOut(duration: 0.35)) { estado.terminarOnboarding(p) }
    }
}

/// Arriba de cada paso: volver y la barra de pasos (.pasos).
struct BarraPasos: View {
    let actual: Int
    let total: Int
    var atras: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: atras) {
                IconoVista(.atras, tamano: 24).foregroundStyle(Color.tinta).frame(width: 44, height: 44).contentShape(Rectangle())
            }
            .buttonStyle(Apretable())
            .accessibilityLabel("Volver")
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { i in
                    Capsule().fill(i < actual ? Color.esmeralda : Color.linea).frame(height: 5)
                }
            }
            .accessibilityElement()
            .accessibilityLabel("Paso \(actual) de \(total)")
            Color.clear.frame(width: 34, height: 44)
        }
        .padding(.horizontal, 10)
        .animation(.snappy, value: actual)
    }
}

/// Molde de cada paso: etiqueta, título, bajada, contenido con scroll y el botón abajo.
struct MarcoPaso<Contenido: View>: View {
    var etiqueta: String? = nil
    let titulo: String
    var sub: String? = nil
    var boton = "Seguir"
    var variante: Boton.Variante = .prim
    var habilitado = true
    var saltar: (() -> Void)? = nil
    @ViewBuilder var contenido: () -> Contenido
    var accion: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let etiqueta { Etiqueta(etiqueta).padding(.bottom, 6) }
                    Titulo(titulo, tamano: 32)
                    if let sub { Sec(sub, tamano: 16).padding(.top, 8) }
                    contenido().padding(.top, 22)
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            VStack(spacing: 4) {
                Boton(titulo: boton, variante: variante, alto: .alto, ancho: true, habilitado: habilitado, accion: accion)
                if let saltar {
                    BotonTexto(titulo: "Lo hago después", color: .gris, accion: saltar)
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, saltar == nil ? 12 : 0)
            .background(Color.white)
        }
    }
}
