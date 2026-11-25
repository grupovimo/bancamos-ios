import Foundation

/// Lo que la app le pide al servidor. Hoy lo cumple `DatosDeMuestra` (en memoria); para conectar datos reales
/// se escribe otra implementación (por ejemplo `DatosApi`) y se pasa al crear `Estado`. Las pantallas no cambian.
///
/// Regla: las cargas van una detrás de otra. Nunca `async let` (cerraba la app en Release).
protocol Datos: Sendable {
    // Lecturas
    func panelCreador() async throws -> PanelCreador
    func panelFan() async throws -> PanelFan
    func creadores() async throws -> [Creador]

    // Cuenta
    func guardarPerfil(_ p: Perfil) async throws
    func cerrarSesion() async throws

    // Creador: su página
    func guardarCreador(_ c: Creador) async throws
    func guardarNivel(_ n: Nivel, creadorId: String) async throws
    func guardarMeta(_ m: Meta, creadorId: String) async throws
    func publicar(_ p: Posteo) async throws
    func borrarPosteo(id: String) async throws

    // Creador: su gente y su plata
    func agradecer(apoyoId: String, texto: String) async throws
    func enviarMensaje(conversacionId: String, texto: String) async throws
    /// Arranca el OAuth de Mercado Pago (el creador autoriza y vuelve con su cuenta conectada).
    func conectarMercadoPago() async throws -> CuentaMP
    func desconectarMercadoPago() async throws
    func guardarFiscal(_ f: DatosFiscales) async throws
    func guardarPrivacidad(_ p: Privacidad) async throws
    func guardarAvisos(_ a: AjustesAvisos) async throws

    // El que banca
    /// Crea el pago en Mercado Pago con el token del creador y la comisión de Bancamos (`marketplace_fee`).
    func apoyar(_ pedido: PedidoApoyo) async throws -> Recibo
    func cambiarNivel(membresiaId: String, nivelId: String) async throws
    func cancelar(membresiaId: String) async throws
    func seguir(creadorId: String, siguiendo: Bool) async throws
    func meGusta(posteoId: String, valor: Bool) async throws
}

enum ErrorDatos: LocalizedError {
    case sinConexion, pagoRechazado, desconocido
    var errorDescription: String? {
        switch self {
        case .sinConexion: return "No hay conexión. Probá de nuevo en un rato."
        case .pagoRechazado: return "Mercado Pago no aprobó el pago. No se te cobró nada."
        case .desconocido: return "Algo salió mal. Probá de nuevo."
        }
    }
}
