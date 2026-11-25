import SwiftUI

@main
struct BancamosApp: App {
    @State private var estado: Estado

    init() {
        AparienciaNav.aplicar()
        // Con `-pantalla x` (capturas y pruebas) se abre directo esa pantalla, en su lado.
        if let a = Arranque.actual {
            if a == .onboarding {
                Perfil.borrar()
            } else if a.vacio {
                var p = a.lado == .creador ? DatosDeMuestra.perfilCreador : DatosDeMuestra.perfilFan
                p.conEjemplos = false
                if a.lado == .creador { p.mpConectado = false; p.niveles = Perfil.nivelesSugeridos }
                p.siguiendo = []
                p.guardar()
            } else {
                (a.lado == .creador ? DatosDeMuestra.perfilCreador : DatosDeMuestra.perfilFan).guardar()
            }
        }
        // Después de acomodar el perfil: Estado lo lee al crearse.
        _estado = State(initialValue: Estado())
    }

    var body: some Scene {
        WindowGroup {
            Raiz()
                .environment(estado)
                .preferredColorScheme(.light)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .tint(Color.esmeralda700)
                .task { await estado.cargar() }
        }
    }
}

/// Sin perfil, el onboarding. Con perfil, la app del lado elegido.
struct Raiz: View {
    @Environment(Estado.self) private var estado

    var body: some View {
        @Bindable var estado = estado
        ZStack(alignment: .top) {
            Group {
                if let p = estado.perfil {
                    if p.lado == .creador {
                        RaizCreador(arranque: Arranque.actual).transition(.opacity)
                    } else {
                        RaizFan(arranque: Arranque.actual).transition(.opacity)
                    }
                } else {
                    Onboarding(paso: Arranque.pasoOnboarding, lado: Arranque.ladoOnboarding).transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: estado.perfil?.lado)
            if let aviso = estado.aviso {
                AvisoFlotante(texto: aviso)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
                    .onTapGesture { withAnimation { estado.aviso = nil } }
            }
        }
        .fullScreenCover(item: $estado.celebrar) { m in MetaCumplida(meta: m) }
        .alert("No se pudo", isPresented: Binding(get: { estado.error != nil }, set: { if !$0 { estado.error = nil } })) {
            Button("Entendido", role: .cancel) {}
        } message: { Text(estado.error ?? "") }
    }
}

/// Qué pantalla abrir al arrancar (`-pantalla inicio`, `-pantalla onboarding -paso 3 -ladoOnb fan`…).
/// Sólo para capturas y pruebas.
enum Arranque: String, CaseIterable {
    case onboarding
    // Creador
    case inicio, inicioVacio = "inicio-vacio", crear, gente, apoyos, miembro, agradecer, posteos, posteo, posteoNuevo = "posteo-nuevo"
    case niveles, nivelNuevo = "nivel-nuevo", metas, metaNueva = "meta-nueva", metaCumplida = "meta-cumplida"
    case miPagina = "mi-pagina", editarPagina = "editar-pagina", asiTeVen = "asi-te-ven", qr
    case mensajes, conversacion, estadisticas, cobros, notificaciones, ajustes, cuentaMP = "cuenta-mp", fiscal, privacidad, plan, ayuda, mas
    // Quien banca
    case explorar, buscar, categoria, creador, posteoFan = "posteo-fan", unaVez = "una-vez", cadaMes = "cada-mes", revisa, checkout, gracias
    case bancas, bancasVacio = "bancas-vacio", membresia, novedades, perfilFan = "perfil-fan", recibos, recibo

    static var actual: Arranque? {
        UserDefaults.standard.string(forKey: "pantalla").flatMap(Arranque.init(rawValue:))
    }

    static var pasoOnboarding: Int { actual == .onboarding ? UserDefaults.standard.integer(forKey: "paso") : 0 }
    static var ladoOnboarding: Lado? {
        actual == .onboarding ? UserDefaults.standard.string(forKey: "ladoOnb").flatMap(Lado.init(rawValue:)) : nil
    }

    var lado: Lado {
        switch self {
        case .explorar, .buscar, .categoria, .creador, .posteoFan, .unaVez, .cadaMes, .revisa, .checkout, .gracias,
             .bancas, .bancasVacio, .membresia, .novedades, .perfilFan, .recibos, .recibo:
            return .fan
        default:
            return .creador
        }
    }

    /// Cuenta recién hecha (sin datos de ejemplo).
    var vacio: Bool { self == .inicioVacio || self == .bancasVacio }
}
