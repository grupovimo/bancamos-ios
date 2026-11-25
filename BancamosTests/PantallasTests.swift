import SwiftUI
import XCTest
@testable import Bancamos

/// Humo: monta cada pantalla con DatosDeMuestra en una ventana de verdad y la dibuja. Si algo se cae al
/// abrirla (como el `async let` que cerraba Tu Local Web en Release), salta acá. Corre también en Release:
/// `xcodebuild test -configuration Release ENABLE_TESTABILITY=YES …`.
@MainActor
final class PantallasTests: XCTestCase {
    private var ventana: UIWindow?

    override func tearDown() {
        ventana?.isHidden = true
        ventana = nil
    }

    private func montar<V: View>(_ vista: V, segundos: Double = 0.5, estado elegido: Estado? = nil,
                                 file: StaticString = #filePath, line: UInt = #line) {
        let estado = elegido ?? Estado()
        let raiz = vista
            .environment(estado)
            .environment(NavCreador())
            .environment(NavFan())
            .preferredColorScheme(.light)
        let escena = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        let v = escena.map { UIWindow(windowScene: $0) } ?? UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIHostingController(rootView: raiz)
        v.rootViewController = host
        v.makeKeyAndVisible()
        ventana = v
        RunLoop.main.run(until: Date().addingTimeInterval(segundos))
        host.view.layoutIfNeeded()
        XCTAssertGreaterThan(host.view.bounds.width, 0, file: file, line: line)
        // Y además a imagen, a 375 × 812 (el teléfono chico).
        let r = ImageRenderer(content: raiz.frame(width: 375, height: 812))
        r.scale = 1
        XCTAssertNotNil(r.uiImage, "No se pudo dibujar la pantalla", file: file, line: line)
    }

    private var vacio: Estado {
        var p = DatosDeMuestra.perfilCreador
        p.conEjemplos = false; p.mpConectado = false
        let e = Estado()
        e.panel = DatosDeMuestra.panelNuevo(p)
        e.fan = DatosDeMuestra.fanNuevo(DatosDeMuestra.perfilFan)
        return e
    }

    // Onboarding
    func testOnboardingCreador() { for i in 0..<PasoOnb.creador.count { montar(Onboarding(paso: i, lado: .creador), segundos: 0.3) } }
    func testOnboardingFan() { for i in 4..<PasoOnb.fan.count { montar(Onboarding(paso: i, lado: .fan), segundos: 0.3) } }

    // Creador
    func testRaizCreador() { montar(RaizCreador(arranque: .inicio)) }
    func testInicio() { montar(NavigationStack { Inicio() }) }
    func testInicioVacio() { montar(NavigationStack { Inicio() }, estado: vacio) }
    func testGente() { montar(NavigationStack { Gente() }) }
    func testGenteVacia() { montar(NavigationStack { Gente() }, estado: vacio) }
    func testApoyos() { montar(NavigationStack { Gente(soloApoyos: true) }) }
    func testFichaMiembro() { montar(NavigationStack { FichaMiembro(miembroId: "m2") }) }
    func testFichaInexistente() { montar(NavigationStack { FichaMiembro(miembroId: "nadie") }) }
    func testAgradecer() { montar(HojaAgradecer(apoyoIds: ["ap1"])) }
    func testAgradecerTodos() { montar(HojaAgradecer(apoyoIds: Estado().sinAgradecer.map(\.id))) }
    func testPosteos() { montar(NavigationStack { Posteos() }) }
    func testPosteosVacio() { montar(NavigationStack { Posteos() }, estado: vacio) }
    func testDetallePosteo() { montar(NavigationStack { DetallePosteoCreador(posteoId: "a2") }) }
    func testEditorPosteo() { montar(EditorPosteo(original: nil)) }
    func testEditarPosteo() { montar(EditorPosteo(original: DatosDeMuestra.ana.posteos[3])) }
    func testNiveles() { montar(NavigationStack { Niveles() }) }
    func testNivelesVacio() { let e = vacio; e.panel.yo.niveles = []; montar(NavigationStack { Niveles() }, estado: e) }
    func testEditorNivel() { montar(EditorNivel(original: nil)); montar(EditorNivel(original: DatosDeMuestra.ana.niveles[2])) }
    func testMetas() { montar(NavigationStack { Metas() }) }
    func testEditorMeta() { montar(EditorMeta(original: nil)) }
    func testMetaCumplida() { montar(MetaCumplida(meta: DatosDeMuestra.ana.metas[1]), segundos: 0.8) }
    func testMiPagina() { montar(NavigationStack { MiPagina() }) }
    func testMiPaginaVacia() { montar(NavigationStack { MiPagina() }, estado: vacio) }
    func testEditarSecciones() { for s in SeccionPagina.allCases { montar(EditarSeccion(seccion: s), segundos: 0.3) } }
    func testAsiTeVen() { montar(NavigationStack { AsiTeVen() }) }
    func testQR() { montar(HojaQR(), segundos: 0.8) }
    func testMensajes() { montar(NavigationStack { Mensajes() }) }
    func testConversacion() { montar(NavigationStack { ConversacionVista(conversacionId: "c1") }) }
    func testNotificaciones() { montar(NavigationStack { Notificaciones() }) }
    func testEstadisticas() { montar(NavigationStack { Estadisticas() }, segundos: 0.8) }
    func testEstadisticasVacias() { montar(NavigationStack { Estadisticas() }, estado: vacio) }
    func testCobros() { montar(NavigationStack { Cobros() }) }
    func testCobrosVacios() { montar(NavigationStack { Cobros() }, estado: vacio) }
    func testMas() { montar(NavigationStack { MasCreador() }) }
    func testAjustes() { montar(NavigationStack { AjustesCreador() }) }
    func testCuentaMP() { montar(NavigationStack { CuentaMercadoPago() }); montar(NavigationStack { CuentaMercadoPago() }, estado: vacio) }
    func testFiscal() { montar(NavigationStack { DatosFiscalesVista() }) }
    func testPrivacidad() { montar(NavigationStack { PrivacidadVista() }) }
    func testAvisos() { montar(NavigationStack { AvisosVista(lado: .creador) }); montar(NavigationStack { AvisosVista(lado: .fan) }) }
    func testPlan() { montar(NavigationStack { PlanComision() }) }
    func testAyuda() { montar(NavigationStack { Ayuda() }) }
    func testMenuCrear() { montar(MenuCrear()) }
    func testAutorizarMP() { montar(HojaAutorizarMP(email: "ana@gmail.com") { _ in }) }

    // Quien banca
    func testRaizFan() { montar(RaizFan(arranque: .explorar)) }
    func testExplorar() { montar(NavigationStack { Explorar() }) }
    func testCategoria() { montar(NavigationStack { ListaCategoria(categoria: .musica) }); montar(NavigationStack { ListaCategoria(categoria: .oficios) }) }
    func testPagina() { for c in DatosDeMuestra.creadores { montar(NavigationStack { PaginaCreadorFan(creadorId: c.id) }, segundos: 0.3) } }
    func testPaginaInexistente() { montar(NavigationStack { PaginaCreadorFan(creadorId: "nadie") }) }
    func testPosteoFan() { montar(NavigationStack { DetallePosteoFan(creadorId: "ana", posteoId: "a2") }); montar(NavigationStack { DetallePosteoFan(creadorId: "ana", posteoId: "a3") }) }
    func testFlujoUnaVez() { montar(FlujoApoyo(pedido: PedidoFlujo(creadorId: "ana", tipo: .unaVez))) }
    func testFlujoCadaMes() { montar(FlujoApoyo(pedido: PedidoFlujo(creadorId: "ana", tipo: .mensual, nivelId: "color"))) }
    func testFlujoRevisa() { montar(FlujoApoyo(pedido: PedidoFlujo(creadorId: "ana", tipo: .mensual, nivelId: "color", paso: 1)), segundos: 0.8) }
    func testFlujoGracias() { montar(FlujoApoyo(pedido: PedidoFlujo(creadorId: "ana", tipo: .unaVez, paso: 2)), segundos: 0.8) }
    func testCheckout() {
        montar(CheckoutMP(creador: DatosDeMuestra.ana, pedido: PedidoApoyo(creadorId: "ana", tipo: .mensual, monto: 5000, nivelId: "color", mensaje: "", mostrarNombre: true)) { _ in })
    }
    func testBancas() { montar(NavigationStack { ABancas() }) }
    func testBancasVacio() { montar(NavigationStack { ABancas() }, estado: vacio) }
    func testMembresia() { montar(NavigationStack { DetalleMembresia(membresiaId: "mb2") }); montar(NavigationStack { DetalleMembresia(membresiaId: "nada") }) }
    func testNovedades() { montar(NavigationStack { Novedades() }) }
    func testNovedadesVacias() { montar(NavigationStack { Novedades() }, estado: vacio) }
    func testPerfilFan() { montar(NavigationStack { PerfilFan() }) }
    func testRecibos() { montar(NavigationStack { Recibos() }); montar(NavigationStack { DetalleRecibo(reciboId: "rc1") }) }
    func testAjustesFan() { montar(NavigationStack { AjustesFan() }) }
}

/// La lógica: comisión, pagos, membresías, metas y exportación.
@MainActor
final class LogicaTests: XCTestCase {
    func testComision() {
        XCTAssertEqual(Comision.de(12000), 360)
        XCTAssertEqual(Comision.neto(12000), 11640) // lo que dice «Nivel nuevo»
        XCTAssertEqual(Plata.texto(1_486_000), "$1.486.000")
        XCTAssertEqual(Plata.leer("$ 12.000"), 12000)
        XCTAssertEqual(Texto.usuario("Ána Mazzéi"), "anamazzei")
        XCTAssertEqual(Texto.iniciales("Juliana Ríos"), "JR")
    }

    func testBancarUnaVezSumaALaMeta() {
        let e = Estado()
        let antes = e.creador("ana")!.metaActiva!.recaudado
        let recibos = e.fan.recibos.count
        let p = PedidoApoyo(creadorId: "ana", tipo: .unaVez, monto: 2000, nivelId: nil, mensaje: "Para los lápices.", mostrarNombre: true)
        e.aplicar(p, recibo: Recibo(id: "x", numero: "1", creadorId: "ana", concepto: "Bancada", monto: 2000, fecha: Date(), medio: "", tipo: .unaVez))
        XCTAssertEqual(e.creador("ana")!.metaActiva!.recaudado, antes + 2000)
        XCTAssertEqual(e.fan.recibos.count, recibos + 1)
    }

    func testHacerseMiembroYCambiarYCancelar() {
        let e = Estado()
        XCTAssertNil(e.membresia(de: "nico"))
        let mensuales = e.creador("nico")!.mensuales
        let p = PedidoApoyo(creadorId: "nico", tipo: .mensual, monto: 3000, nivelId: "mod", mensaje: "", mostrarNombre: true)
        e.aplicar(p, recibo: Recibo(id: "y", numero: "2", creadorId: "nico", concepto: "", monto: 3000, fecha: Date(), medio: "", tipo: .mensual))
        let m = try! XCTUnwrap(e.membresia(de: "nico"))
        XCTAssertEqual(e.creador("nico")!.mensuales, mensuales + 1)
        XCTAssertEqual(e.nivelDelFan(en: "nico"), "mod")
        // Ve lo de su nivel.
        let c = e.creador("nico")!
        XCTAssertTrue(c.puedeVer(Posteo(id: "z", creadorId: "nico", titulo: "", texto: "", tipo: .texto, publico: .desde("mod"), fecha: Date()), nivelId: "mod"))
        XCTAssertFalse(c.puedeVer(Posteo(id: "z", creadorId: "nico", titulo: "", texto: "", tipo: .texto, publico: .desde("vip"), fecha: Date()), nivelId: "mod"))
        e.cambiarNivel(membresiaId: m.id, a: "lurker")
        XCTAssertEqual(e.membresia(de: "nico")?.monto, 1000)
        e.cancelar(membresiaId: m.id)
        XCTAssertNil(e.membresia(de: "nico"))
        XCTAssertEqual(e.creador("nico")!.mensuales, mensuales)
    }

    func testPagarCuotaPendiente() {
        let e = Estado()
        XCTAssertEqual(e.porPagar.count, 1)
        let p = PedidoApoyo(creadorId: "tomas", tipo: .mensual, monto: 2000, nivelId: "oyente", mensaje: "", mostrarNombre: true)
        e.aplicar(p, recibo: Recibo(id: "w", numero: "3", creadorId: "tomas", concepto: "", monto: 2000, fecha: Date(), medio: "", tipo: .mensual))
        XCTAssertEqual(e.porPagar.count, 0)
    }

    func testMetaCumplidaFestejaAlCerrar() {
        let e = Estado()
        var m = e.yo.metaActiva!
        m.recaudado = m.objetivo
        e.guardarMeta(m)
        e.cerrar(metaId: m.id)
        XCTAssertEqual(e.celebrar?.id, m.id)
        XCTAssertNil(e.yo.metaActiva)
    }

    func testAgradecerYPublicar() {
        let e = Estado()
        let n = e.sinAgradecer.count
        XCTAssertGreaterThan(n, 1)
        e.agradecer(e.sinAgradecer[0].id, texto: "¡Gracias!")
        XCTAssertEqual(e.sinAgradecer.count, n - 1)
        e.agradecerTodos(texto: "Gracias")
        XCTAssertTrue(e.sinAgradecer.isEmpty)
        let posteos = e.yo.posteos.count
        e.publicar(Posteo(id: "nuevo", creadorId: "ana", titulo: "Hola", texto: "", tipo: .texto, publico: .todos, fecha: Date()))
        XCTAssertEqual(e.yo.posteos.count, posteos + 1)
        XCTAssertEqual(e.alcance(.desde("color")), 151 + 19)
    }

    func testCSV() throws {
        let e = Estado()
        let csv = try String(contentsOf: e.csvCobros(), encoding: .utf8)
        XCTAssertTrue(csv.contains("Fecha;Nombre;Tipo;Bruto;Bancamos 3 %"))
        XCTAssertEqual(csv.split(separator: "\n").count, e.panel.acreditaciones.count + 1)
        let m = try String(contentsOf: e.csvMiembros(), encoding: .utf8)
        XCTAssertEqual(m.split(separator: "\n").count, e.panel.miembros.count + 1)
    }

    func testCuentaNuevaArrancaVacia() {
        var p = DatosDeMuestra.perfilCreador
        p.conEjemplos = false
        let panel = DatosDeMuestra.panelNuevo(p)
        XCTAssertTrue(panel.apoyos.isEmpty)
        XCTAssertEqual(panel.yo.mensuales, 0)
        XCTAssertEqual(panel.yo.metaActiva?.recaudado, 0)
        XCTAssertEqual(panel.yo.usuario, "anamazzei")
    }

    func testBuscar() {
        let e = Estado()
        XCTAssertEqual(e.buscar("cordoba").first?.id, "tomas")
        XCTAssertEqual(e.buscar("MÚSICA").first?.id, "tomas")
        XCTAssertTrue(e.buscar("zzzz").isEmpty)
        XCTAssertEqual(e.sugeridos(para: [.cocina]).first?.id, "rosa")
    }

    func testQR() { XCTAssertNotNil(QR.imagen("https://bancamos.com.ar/anamazzei")) }
}
