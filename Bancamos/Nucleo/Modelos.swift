import SwiftUI
import UIKit

/// Quién usa la app: quien recibe apoyos (creador) o quien los da (fan).
enum Lado: String, Codable, CaseIterable {
    case creador, fan
}

/// De qué se trata lo que hace cada creador. Sirve para explorar y para los intereses del que banca.
enum Categoria: String, CaseIterable, Codable, Identifiable, Hashable {
    case ilustracion, musica, cocina, bienestar, streaming, escritura, podcast, fotografia, educacion, oficios

    var id: String { rawValue }
    var nombre: String {
        switch self {
        case .ilustracion: return "Ilustración"
        case .musica: return "Música"
        case .cocina: return "Cocina"
        case .bienestar: return "Yoga y bienestar"
        case .streaming: return "Streaming"
        case .escritura: return "Escritura"
        case .podcast: return "Podcast"
        case .fotografia: return "Fotografía"
        case .educacion: return "Clases"
        case .oficios: return "Oficios"
        }
    }
    /// SF Symbol (los chips de categorías).
    var simbolo: String {
        switch self {
        case .ilustracion: return "paintbrush.pointed"
        case .musica: return "guitars"
        case .cocina: return "frying.pan"
        case .bienestar: return "figure.mind.and.body"
        case .streaming: return "gamecontroller"
        case .escritura: return "text.book.closed"
        case .podcast: return "mic"
        case .fotografia: return "camera"
        case .educacion: return "graduationcap"
        case .oficios: return "hammer"
        }
    }
}

/// Una imagen: un asset de la maqueta o lo que el usuario eligió con PhotosPicker. `foco` es el punto de la
/// foto que queda al centro al recortar (como el object-position del CSS).
struct Imagen: Hashable, Codable {
    var asset: String?
    var datos: Data?
    var fx: Double = 0.5
    var fy: Double = 0.45
    /// Cuánto se acerca para un avatar (1 = la foto entera de ancho).
    var zoom: Double = 2.4

    static let vacia = Imagen()
    static func asset(_ n: String, _ fx: Double = 0.5, _ fy: Double = 0.45, zoom: Double = 2.4) -> Imagen {
        Imagen(asset: n, fx: fx, fy: fy, zoom: zoom)
    }

    var uiImage: UIImage? {
        if let datos, let i = UIImage(data: datos) { return i }
        if let asset { return UIImage(named: asset) }
        return nil
    }
    var existe: Bool { asset != nil || datos != nil }
    var foco: UnitPoint { UnitPoint(x: fx, y: fy) }
}

/// Un nivel de membresía (cuota mensual).
struct Nivel: Identifiable, Hashable, Codable {
    var id: String
    var nombre: String
    var precio: Int
    var descripcion: String
    var incluye: [String]
    /// nil: sin cupo.
    var cupo: Int?
    var miembros: Int
    var pausado = false

    var quedan: Int? { cupo.map { max(0, $0 - miembros) } }
    var lleno: Bool { (quedan ?? 1) == 0 }
    /// Lo que le llega al creador por persona (sin lo de Mercado Pago, que va aparte).
    var neto: Int { Comision.neto(precio) }
}

/// Una meta («Imprimir mi primer libro»). La barra de progreso es el elemento central de la marca.
struct Meta: Identifiable, Hashable, Codable {
    var id: String
    var titulo: String
    var descripcion: String
    var objetivo: Int
    var recaudado: Int
    var creada: Date
    var cerrada = false
    var cumplida: Date?

    var fraccion: Double { objetivo <= 0 ? 0 : min(1, Double(recaudado) / Double(objetivo)) }
    var porcentaje: Int { objetivo <= 0 ? 0 : Int((Double(recaudado) / Double(objetivo) * 100).rounded(.down)) }
    var falta: Int { max(0, objetivo - recaudado) }
    var lograda: Bool { recaudado >= objetivo }
}

/// Quién ve un posteo.
enum PublicoPosteo: Hashable, Codable {
    case todos
    case quienesTeBancan
    /// Desde ese nivel para arriba («Color y Original»).
    case desde(String)
}

enum TipoPosteo: String, Codable, CaseIterable {
    case texto, fotos, audio
    var nombre: String {
        switch self { case .texto: return "Texto"; case .fotos: return "Fotos"; case .audio: return "Audio" }
    }
    var icono: Icono {
        switch self { case .texto: return .texto; case .fotos: return .foto; case .audio: return .audio }
    }
}

struct Posteo: Identifiable, Hashable, Codable {
    var id: String
    var creadorId: String
    var titulo: String
    var texto: String
    var tipo: TipoPosteo
    var fotos: [Imagen] = []
    var audioSegundos = 0
    var publico: PublicoPosteo
    var fecha: Date
    /// Si está programado, sale en esta fecha.
    var programado: Date?
    var meGusta = 0
    var comentarios = 0
    var leGusta = false
    var avisarPorMail = true

    var esProgramado: Bool { (programado ?? .distantPast) > Date() }
}

enum TipoApoyo: String, Codable, Hashable {
    case unaVez, mensual
}

/// Un aporte que entró (lo ve el creador).
struct Apoyo: Identifiable, Hashable, Codable {
    var id: String
    var nombre: String
    var monto: Int
    var tipo: TipoApoyo
    var nivelId: String?
    var mensaje: String
    var fecha: Date
    var agradecido = false
    var anonimo = false

    var iniciales: String { anonimo ? "?" : Texto.iniciales(nombre) }
    var nombreVisible: String { anonimo ? "Alguien" : nombre }
}

enum EstadoMiembro: String, Codable, Hashable {
    case alDia, porVencer, vencido, baja
    var nombre: String {
        switch self {
        case .alDia: return "Al día"
        case .porVencer: return "Vence pronto"
        case .vencido: return "No pagó"
        case .baja: return "Se dio de baja"
        }
    }
}

/// Alguien que banca cada mes.
struct Miembro: Identifiable, Hashable, Codable {
    var id: String
    var nombre: String
    var email: String
    var nivelId: String
    var desde: Date
    var proximoPago: Date
    var estado: EstadoMiembro
    var aportado: Int
    var nota = ""

    var iniciales: String { Texto.iniciales(nombre) }
    var meses: Int { max(1, Calendar.current.dateComponents([.month], from: desde, to: Date()).month ?? 1) }
}

struct Mensaje: Identifiable, Hashable, Codable {
    var id: String
    var deMi: Bool
    var texto: String
    var fecha: Date
}

struct Conversacion: Identifiable, Hashable, Codable {
    var id: String
    var nombre: String
    var nivel: String?
    var mensajes: [Mensaje]
    var noLeidos: Int
    var iniciales: String { Texto.iniciales(nombre) }
    var ultimo: Mensaje? { mensajes.last }
}

/// Lo que Mercado Pago acreditó en la cuenta del creador por cada apoyo.
struct Acreditacion: Identifiable, Hashable, Codable {
    var id: String
    var fecha: Date
    var nombre: String
    var tipo: TipoApoyo
    var bruto: Int
    var operacionMP: String

    var comision: Int { Comision.de(bruto) }
    var cargoMP: Int { Comision.mercadoPago(bruto) }
    var neto: Int { bruto - comision - cargoMP }
}

/// Un mes cerrado: lo que entró y la factura de Bancamos por su 3 %.
struct MesCobros: Identifiable, Hashable, Codable {
    var id: String { mes }
    /// AAAA-MM
    var mes: String
    var bruto: Int
    var apoyos: Int
    var miembros: Int
    var facturaBancamos: String?
    var comision: Int { Comision.de(bruto) }
    var cargoMP: Int { Comision.mercadoPago(bruto) }
    var neto: Int { bruto - comision - cargoMP }
}

enum TipoNotificacion: String, Codable, Hashable {
    case apoyo, miembro, baja, meta, mensaje, sistema, posteo, cobro
    var icono: Icono {
        switch self {
        case .apoyo: return .corazon
        case .miembro: return .gente
        case .baja: return .persona
        case .meta: return .bandera
        case .mensaje: return .mensaje
        case .sistema: return .segura
        case .posteo: return .texto
        case .cobro: return .plata
        }
    }
}

struct Notificacion: Identifiable, Hashable, Codable {
    var id: String
    var tipo: TipoNotificacion
    var titulo: String
    var texto: String
    var fecha: Date
    var leida = false
}

struct CuentaMP: Hashable, Codable {
    var conectada: Bool
    var email: String
    var nombre: String
    var desde: Date?
}

enum CondicionFiscal: String, CaseIterable, Codable, Hashable {
    case monotributo, responsableInscripto, ninguna
    var nombre: String {
        switch self {
        case .monotributo: return "Monotributo"
        case .responsableInscripto: return "Responsable inscripto"
        case .ninguna: return "Todavía no estoy inscripto"
        }
    }
}

struct DatosFiscales: Hashable, Codable {
    var condicion: CondicionFiscal
    var cuit: String
    var razonSocial: String
    var domicilio: String
}

struct Privacidad: Hashable, Codable {
    var mostrarRecaudado = true
    var mostrarCantidad = true
    var mensajesDe: QuienEscribe = .quienesBancan
    var mostrarEnExplorar = true
    var mostrarCiudad = true
}

enum QuienEscribe: String, CaseIterable, Codable, Hashable {
    case todos, quienesBancan, nadie
    var nombre: String {
        switch self {
        case .todos: return "Cualquiera"
        case .quienesBancan: return "Quienes te bancan"
        case .nadie: return "Nadie"
        }
    }
}

struct AjustesAvisos: Hashable, Codable {
    var cadaApoyo = true
    var resumenDiario = false
    var miembrosNuevos = true
    var bajas = true
    var mensajes = true
    var novedadesDeMisCreadores = true
    var recordatorioDePago = true
}

/// Un punto de los gráficos: una etiqueta (mes, día) y un valor.
struct Punto: Identifiable, Hashable, Codable {
    var id: String { etiqueta }
    var etiqueta: String
    var valor: Int
}

/// El creador: su página pública y todo lo que se ve de él.
struct Creador: Identifiable, Hashable, Codable {
    var id: String
    var nombre: String
    var usuario: String
    var frase: String
    var ciudad: String
    var categoria: Categoria
    var foto: Imagen
    var portada: Imagen
    var sobreMi: String
    var redes: [String]
    var niveles: [Nivel]
    var metas: [Meta]
    var posteos: [Posteo]
    var mensuales: Int
    var bancadas: Int
    var destacado = false
    var distanciaKm: Double?
    var montosSugeridos: [Int] = [1000, 2000, 5000]
    var agradecimiento = "¡Gracias por bancarme!"
    /// Para «Bancala» o «Bancalo».
    var femenino = true

    var lo: String { femenino ? "la" : "lo" }

    var primerNombre: String { nombre.split(separator: " ").first.map(String.init) ?? nombre }
    var link: String { "bancamos.com.ar/\(usuario)" }
    var url: URL { URL(string: "https://\(link)")! }
    var metaActiva: Meta? { metas.first { !$0.cerrada } }
    var nivelesActivos: [Nivel] { niveles.filter { !$0.pausado }.sorted { $0.precio < $1.precio } }
    var desde: Int? { nivelesActivos.first?.precio }
    var iniciales: String { Texto.iniciales(nombre) }

    func nivel(_ id: String?) -> Nivel? { id.flatMap { i in niveles.first { $0.id == i } } }

    /// ¿Ese nivel ve el posteo? (nil: no banca).
    func puedeVer(_ p: Posteo, nivelId: String?) -> Bool {
        switch p.publico {
        case .todos: return true
        case .quienesTeBancan: return nivelId != nil
        case .desde(let desde):
            guard let nid = nivelId, let mio = nivel(nid), let min = nivel(desde) else { return false }
            return mio.precio >= min.precio
        }
    }

    func publicoTexto(_ p: PublicoPosteo) -> String {
        switch p {
        case .todos: return "Todos"
        case .quienesTeBancan: return "Los que te bancan"
        case .desde(let id):
            let ord = nivelesActivos
            guard let i = ord.firstIndex(where: { $0.id == id }) else { return "Un nivel" }
            let resto = ord[i...].map(\.nombre)
            if resto.count == 1 { return "Sólo \(resto[0])" }
            return resto.dropLast().joined(separator: ", ") + " y " + resto.last!
        }
    }
}

// MARK: - Lado del que banca

enum EstadoMembresia: String, Codable, Hashable {
    case alDia, porPagar, pausada
}

/// A quién banca cada mes el fan.
struct Membresia: Identifiable, Hashable, Codable {
    var id: String
    var creadorId: String
    var nivelId: String
    var monto: Int
    var desde: Date
    var proximoPago: Date
    var estado: EstadoMembresia
}

/// Comprobante de un pago del que banca.
struct Recibo: Identifiable, Hashable, Codable {
    var id: String
    var numero: String
    var creadorId: String
    var concepto: String
    var monto: Int
    var fecha: Date
    var medio: String
    var tipo: TipoApoyo
    var mensaje: String = ""
}

/// Lo que se pide al tocar «Pagar con Mercado Pago».
struct PedidoApoyo: Hashable, Identifiable {
    var id: String { "\(creadorId)-\(tipo.rawValue)-\(monto)-\(nivelId ?? "")" }
    var creadorId: String
    var tipo: TipoApoyo
    var monto: Int
    var nivelId: String?
    var mensaje: String
    var mostrarNombre: Bool
}

struct PanelCreador: Codable {
    var yo: Creador
    var apoyos: [Apoyo]
    var miembros: [Miembro]
    var conversaciones: [Conversacion]
    var acreditaciones: [Acreditacion]
    var meses: [MesCobros]
    var notificaciones: [Notificacion]
    var cuentaMP: CuentaMP
    var fiscal: DatosFiscales
    var privacidad: Privacidad
    var avisos: AjustesAvisos
    var visitas: [Punto]
    var email: String
}

struct PanelFan: Codable {
    var nombre: String
    var email: String
    var membresias: [Membresia]
    var recibos: [Recibo]
    var siguiendo: [String]
    var intereses: [Categoria]
    var avisos: AjustesAvisos
    var medio: String
}
