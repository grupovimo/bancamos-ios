import SwiftUI

/// «Más»: todo lo del creador, ordenado, con «Cerrar sesión» a la vista.
struct MasCreador: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @State private var salir = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button { nav.ir(.miPagina) } label: {
                    HStack(spacing: 14) {
                        Avatar(estado.yo, tamano: 56)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(estado.yo.nombre).tipo(.titulo(20)).foregroundStyle(Color.tinta)
                            Text(estado.yo.link).tipo(.texto(14, 500)).foregroundStyle(Color.esmeralda700)
                        }
                        Spacer()
                        IconoVista(.der, tamano: 16).foregroundStyle(Color.gris)
                    }
                    .padding(16)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
                    .sombra()
                }
                .buttonStyle(Apretable())
                grupo("Tu página", [
                    (.persona, "Mi página", "Editar, así te ven y QR", RutaCreador.miPagina, 0),
                    (.capas, "Niveles", "\(estado.yo.nivelesActivos.count) activos", .niveles, 0),
                    (.bandera, "Metas", estado.yo.metaActiva.map { "\($0.porcentaje) % de \($0.titulo.lowercased())" } ?? "Sin meta activa", .metas, 0),
                ])
                grupo("Tu gente", [
                    (.mensaje, "Mensajes", estado.mensajesSinLeer > 0 ? "\(estado.mensajesSinLeer) sin leer" : "Al día", .mensajes, estado.mensajesSinLeer),
                    (.campana, "Avisos", estado.avisosSinLeer > 0 ? "\(estado.avisosSinLeer) nuevos" : "Al día", .notificaciones, estado.avisosSinLeer),
                ])
                grupo("Tu plata", [
                    (.plata, "Cobros", "Lo que acreditó Mercado Pago", .cobros, 0),
                    (.grafico, "Estadísticas", "Meses, niveles y visitas", .estadisticas, 0),
                    (.recibo, "Plan y comisión", "3 % de lo que entra, sin abono", .plan, 0),
                ])
                grupo("Cuenta", [
                    (.segura, "Ajustes", "Mercado Pago, datos fiscales y privacidad", .ajustes, 0),
                    (.mensaje, "Ayuda", "Preguntas y contacto", .ayuda, 0),
                ])
                BannerGrupo(.laColumnaCreador).padding(.top, 20)
                Boton(titulo: "Cerrar sesión", icono: .salir, variante: .blanco, alto: .normal, ancho: true) { salir = true }
                    .padding(.top, 20)
                Text("Bancamos 1.0 · De Grupo Vimo").tipo(.texto(12, 500)).foregroundStyle(Color.gris).frame(maxWidth: .infinity).padding(.top, 14)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.top, 4)
            .padding(.bottom, Espacio.bajoBarra)
        }
        .background(Color.fondo)
        .navigationTitle("Más")
        .confirmationDialog("¿Cerrar sesión?", isPresented: $salir, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) { estado.cerrarSesion() }
        } message: { Text("Tu página sigue en línea y recibiendo apoyos.") }
    }

    private func grupo(_ titulo: String, _ filas: [(Icono, String, String, RutaCreador, Int)]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            TituloSeccion(texto: titulo, arriba: 22)
            Tarjeta {
                ForEach(Array(filas.enumerated()), id: \.offset) { i, f in
                    if i > 0 { Divisor(izquierda: 68) }
                    Button { nav.ir(f.3) } label: { FilaMenu(icono: f.0, titulo: f.1, sub: f.2, badge: f.4) }
                        .buttonStyle(Apretable())
                }
            }
        }
    }
}

/// Ajustes del creador.
struct AjustesCreador: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @State private var salir = false
    @State private var borrar = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Tarjeta {
                    fila(.mp, "Cuenta de Mercado Pago", estado.panel.cuentaMP.conectada ? estado.panel.cuentaMP.email : "Sin conectar", .cuentaMP,
                         alerta: !estado.panel.cuentaMP.conectada)
                    Divisor(izquierda: 68)
                    fila(.recibo, "Datos fiscales", estado.panel.fiscal.condicion.nombre, .fiscal, alerta: estado.panel.fiscal.cuit.isEmpty)
                    Divisor(izquierda: 68)
                    fila(.candado, "Privacidad", "Qué se ve de vos y quién te escribe", .privacidad)
                    Divisor(izquierda: 68)
                    fila(.campana, "Avisos", "Qué te avisamos y cómo", .avisos)
                    Divisor(izquierda: 68)
                    fila(.plata, "Plan y comisión", "3 % de lo que entra", .plan)
                }
                TituloSeccion(texto: "La app")
                Tarjeta(relleno: 16) {
                    FilaInterruptor(titulo: "Ver con datos de ejemplo", sub: "Para mostrar cómo se ve una página con mucha gente.",
                                    valor: Binding(get: { estado.perfil?.conEjemplos ?? true }, set: { estado.usarEjemplos($0) }))
                    Divisor().padding(.vertical, 8)
                    Button { estado.cambiarLado(.fan) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Usar Bancamos para bancar").tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                                Text("Pasás al lado del que banca. Volvés cuando quieras.").tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                            }
                            Spacer()
                            IconoVista(.flecha, tamano: 18).foregroundStyle(Color.esmeralda700)
                        }
                        .frame(minHeight: 44).contentShape(Rectangle())
                    }
                    .buttonStyle(Apretable())
                }
                TituloSeccion(texto: "Legales")
                Tarjeta {
                    enlace("Términos y condiciones", "https://bancamos.com.ar/terminos")
                    Divisor(izquierda: 16)
                    enlace("Política de privacidad", "https://bancamos.com.ar/privacidad")
                    Divisor(izquierda: 16)
                    enlace("Reglas de publicación", "https://bancamos.com.ar/reglas")
                }
                Boton(titulo: "Cerrar sesión", icono: .salir, variante: .blanco, alto: .normal, ancho: true) { salir = true }.padding(.top, 24)
                Button { borrar = true } label: {
                    Text("Eliminar mi cuenta").tipo(.texto(15, 600)).foregroundStyle(Color.error).frame(maxWidth: .infinity, minHeight: 44)
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Ajustes")
        .confirmationDialog("¿Cerrar sesión?", isPresented: $salir, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) { estado.cerrarSesion() }
        }
        .confirmationDialog("¿Eliminar tu cuenta?", isPresented: $borrar, titleVisibility: .visible) {
            Button("Eliminar cuenta", role: .destructive) { estado.cerrarSesion() }
        } message: {
            Text("Tu página deja de verse, se cancelan las cuotas de quienes te bancan y borramos tus datos en 30 días. Lo que ya cobraste queda en tu Mercado Pago.")
        }
    }

    private func fila(_ i: Icono, _ t: String, _ s: String, _ r: RutaCreador, alerta: Bool = false) -> some View {
        Button { nav.ir(r) } label: {
            FilaMenu(icono: i, titulo: t, sub: s, colorIcono: alerta ? .alerta : .esmeralda700, fondoIcono: alerta ? .alerta100 : .esmeralda100)
        }
        .buttonStyle(Apretable())
    }

    private func enlace(_ t: String, _ u: String) -> some View {
        Link(destination: URL(string: u)!) {
            HStack {
                Text(t).tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                Spacer()
                Image(systemName: "arrow.up.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.gris)
            }
            .padding(.horizontal, 16).frame(minHeight: 52)
        }
    }
}

/// La cuenta de Mercado Pago: conectada o para conectar.
struct CuentaMercadoPago: View {
    @Environment(Estado.self) private var estado
    @State private var autorizar = false
    @State private var desconectar = false

    var body: some View {
        let c = estado.panel.cuentaMP
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if c.conectada {
                    Tarjeta(relleno: 16) {
                        HStack(spacing: 12) {
                            IconoVista(.mp, tamano: 30).foregroundStyle(.white).frame(width: 52, height: 52).background(Color.mp, in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(c.email).tipo(.texto(16, 700)).foregroundStyle(Color.tinta)
                                Text(c.desde.map { "Conectada desde el \(Fecha.dia($0))" } ?? "Conectada").tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                            }
                            Spacer()
                            Chip(texto: "Activa", tono: .ok, icono: .tilde)
                        }
                    }
                } else {
                    Titulo("Conectá tu Mercado Pago", tamano: 28)
                    FlujoPlata()
                }
                PuntosMP()
                if c.conectada {
                    Boton(titulo: "Desconectar", variante: .peligro, alto: .normal, ancho: true) { desconectar = true }
                    Sec("Si cambiás de cuenta, desconectá esta y conectá la nueva. Lo que ya entró queda donde está.")
                } else {
                    Boton(titulo: "Conectar Mercado Pago", variante: .mp, alto: .alto, ancho: true) { autorizar = true }
                    Text("Te lleva a Mercado Pago y volvés solo.").tipo(.texto(14, 400)).foregroundStyle(Color.gris).frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Mercado Pago")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $autorizar) {
            HojaAutorizarMP(email: estado.panel.email) { ok in if ok { estado.avisar("Listo: ya podés recibir apoyos.") } }
        }
        .confirmationDialog("¿Desconectar Mercado Pago?", isPresented: $desconectar, titleVisibility: .visible) {
            Button("Desconectar", role: .destructive) { estado.desconectarMercadoPago() }
        } message: { Text("Tu página deja de recibir apoyos y las cuotas mensuales se pausan hasta que conectes otra cuenta.") }
    }
}

struct DatosFiscalesVista: View {
    @Environment(Estado.self) private var estado
    @State private var f = DatosFiscales(condicion: .ninguna, cuit: "", razonSocial: "", domicilio: "")
    @State private var cargado = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Sec("Los usamos para hacerte la factura de Bancamos por su 3 %. No se ven en tu página.", tamano: 15)
                Etiqueta("Condición").padding(.top, 6)
                VStack(spacing: 8) {
                    ForEach(CondicionFiscal.allCases, id: \.self) { c in
                        Button { Haptico.seleccion(); f.condicion = c } label: {
                            HStack(spacing: 12) {
                                Circle().strokeBorder(f.condicion == c ? Color.tinta : Color.linea, lineWidth: f.condicion == c ? 7 : 2).frame(width: 24, height: 24)
                                Text(c.nombre).tipo(.texto(16, 600)).foregroundStyle(Color.tinta)
                                Spacer()
                            }
                            .padding(.horizontal, 16).frame(minHeight: 56)
                            .background(f.condicion == c ? Color.esmeralda50 : Color.white, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(f.condicion == c ? Color.tinta : Color.linea, lineWidth: f.condicion == c ? 2 : 1.5))
                        }
                        .buttonStyle(Apretable())
                    }
                }
                Campo(etiqueta: "CUIT o CUIL", texto: $f.cuit, placeholder: "27-34567890-4", teclado: .numbersAndPunctuation)
                Campo(etiqueta: "Nombre o razón social", texto: $f.razonSocial, mayusculas: .words)
                Campo(etiqueta: "Domicilio fiscal", texto: $f.domicilio, mayusculas: .words)
                NotaSegura(texto: "Lo que te bancan suele ser un ingreso por tu trabajo: según tu caso, va al monotributo o a Ingresos Brutos. Consultalo con tu contador.",
                           icono: .recibo)
                Boton(titulo: "Guardar", alto: .alto, ancho: true, habilitado: f.condicion == .ninguna || f.cuit.filter(\.isNumber).count == 11) {
                    estado.guardar(fiscal: f)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.fondo)
        .navigationTitle("Datos fiscales")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if !cargado { f = estado.panel.fiscal; cargado = true } }
    }
}

struct PrivacidadVista: View {
    @Environment(Estado.self) private var estado

    var body: some View {
        @Bindable var estado = estado
        let p = Binding(get: { estado.panel.privacidad }, set: { estado.guardar(privacidad: $0) })
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Tarjeta(relleno: 16) {
                    FilaInterruptor(titulo: "Mostrar cuánto juntaste", sub: "En la meta de tu página", valor: p.mostrarRecaudado)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Mostrar cuántos te bancan", sub: "«312 la bancan cada mes»", valor: p.mostrarCantidad)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Aparecer en Explorar", sub: "Si lo apagás, sólo entran con tu link", valor: p.mostrarEnExplorar)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Mostrar tu ciudad", sub: "Para «Cerca tuyo»", valor: p.mostrarCiudad)
                }
                TituloSeccion(texto: "Quién te puede escribir")
                Tarjeta {
                    ForEach(QuienEscribe.allCases, id: \.self) { q in
                        Button { Haptico.seleccion(); p.wrappedValue.mensajesDe = q } label: {
                            HStack {
                                Text(q.nombre).tipo(.texto(16, 600)).foregroundStyle(Color.tinta)
                                Spacer()
                                if p.wrappedValue.mensajesDe == q { IconoVista(.tilde, tamano: 20).foregroundStyle(Color.esmeralda700) }
                            }
                            .padding(.horizontal, 16).frame(minHeight: 52).contentShape(Rectangle())
                        }
                        .buttonStyle(Apretable())
                        if q != .nadie { Divisor(izquierda: 16) }
                    }
                }
                TituloSeccion(texto: "Tus datos")
                Tarjeta {
                    CompartirBoton(generar: { estado.csvMiembros() }) {
                        FilaMenu(icono: .descarga, titulo: "Descargar mis datos", sub: "Tu página, tu gente y tus cobros")
                    }
                }
                Text("Cuidamos los datos de tu gente según la Ley 25.326. Los mensajes y los datos de pago no se comparten con nadie.")
                    .tipo(.texto(13, 400)).foregroundStyle(Color.gris).padding(.top, 14)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Privacidad")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Qué avisos recibir (los dos lados).
struct AvisosVista: View {
    let lado: Lado
    @Environment(Estado.self) private var estado

    var body: some View {
        let a = Binding(get: { lado == .creador ? estado.panel.avisos : estado.fan.avisos },
                        set: { lado == .creador ? estado.guardar(avisos: $0) : estado.guardarAvisosFan($0) })
        ScrollView {
            Tarjeta(relleno: 16) {
                if lado == .creador {
                    FilaInterruptor(titulo: "Cada apoyo", sub: "Con el mensaje, apenas llega", valor: a.cadaApoyo)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Resumen del día", sub: "A las 21, lo que entró en el día", valor: a.resumenDiario)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Alguien se suma cada mes", valor: a.miembrosNuevos)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Alguien se da de baja", valor: a.bajas)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Mensajes", valor: a.mensajes)
                } else {
                    FilaInterruptor(titulo: "Posteos nuevos", sub: "De quienes bancás y seguís", valor: a.novedadesDeMisCreadores)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Antes de cada cuota", sub: "Tres días antes, para que no te sorprenda", valor: a.recordatorioDePago)
                    Divisor().padding(.vertical, 6)
                    FilaInterruptor(titulo: "Respuestas y gracias", valor: a.mensajes)
                }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Avisos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// El plan: sin abono, 3 % de lo que entra, y una calculadora.
struct PlanComision: View {
    @Environment(Estado.self) private var estado
    @State private var monto: Double = 300_000

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Etiqueta("Tu plan", color: .white.opacity(0.8))
                    Text("3 %").tipo(.numero(64)).foregroundStyle(.white)
                    Text("de lo que entra. Sin abono, sin mínimo, sin letra chica.").tipo(.texto(16, 500)).foregroundStyle(.white.opacity(0.9))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.esmeralda700, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                if let m = estado.mesActual, m.bruto > 0 {
                    Text("En \(Fecha.mes()) Bancamos se quedó con \(Plata.texto(m.comision)) de \(Plata.texto(m.bruto)).")
                        .tipo(.texto(15, 500)).foregroundStyle(Color.tinta).padding(.top, 14)
                }
                TituloSeccion(texto: "Hacé la cuenta")
                Tarjeta(relleno: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Si te entran").tipo(.texto(15, 400)).foregroundStyle(Color.gris)
                        Spacer()
                        Text(Plata.texto(Int(monto))).tipo(.numero(24)).foregroundStyle(Color.tinta)
                    }
                    Slider(value: $monto, in: 10_000...3_000_000, step: 10_000).tint(Color.esmeralda700)
                        .accessibilityValue(Plata.texto(Int(monto)))
                    Divisor().padding(.vertical, 6)
                    FilaDato(etiqueta: "Bancamos (3 %)", valor: Plata.texto(Comision.de(Int(monto))), fuerte: false)
                    FilaDato(etiqueta: "Te llegan (antes de Mercado Pago)", valor: Plata.texto(Comision.neto(Int(monto))), colorValor: .ok)
                }
                TituloSeccion(texto: "Comparado")
                Tarjeta {
                    comparar("Bancamos", "3 %", fuerte: true)
                    Divisor(izquierda: 16)
                    comparar("Cafecito", "5 %")
                    Divisor(izquierda: 16)
                    comparar("Patreon", "10 %")
                }
                Text("Mercado Pago cobra lo suyo aparte, igual que en cualquier plataforma. La comisión de Bancamos se factura una vez por mes.")
                    .tipo(.texto(13, 400)).foregroundStyle(Color.gris).padding(.top, 12)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Plan y comisión")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func comparar(_ n: String, _ v: String, fuerte: Bool = false) -> some View {
        HStack {
            Text(n).tipo(.texto(16, fuerte ? 700 : 500)).foregroundStyle(Color.tinta)
            Spacer()
            Text(v).tipo(.texto(16, 700)).foregroundStyle(fuerte ? Color.esmeralda700 : Color.gris)
        }
        .padding(.horizontal, 16).frame(minHeight: 52)
    }
}

/// Ayuda: preguntas frecuentes y contacto.
struct Ayuda: View {
    private let preguntas: [(String, String)] = [
        ("¿Cuándo me llega la plata?", "Al momento: cada apoyo entra directo a tu Mercado Pago. Bancamos nunca la tiene."),
        ("¿Cuánto cobra Bancamos?", "El 3 % de lo que entra, descontado en el mismo pago. Mercado Pago cobra lo suyo aparte. No hay abono."),
        ("¿Cómo pagan los que me bancan cada mes?", "Tres días antes de cada cuota les avisamos y pagan con un toque en Mercado Pago. Se dan de baja cuando quieren."),
        ("¿Qué pasa si alguien no paga?", "Le avisamos para que pague con otro medio. Si en 7 días no paga, deja de ver lo exclusivo. Vos no tenés que cobrar a nadie."),
        ("¿Puedo devolver un apoyo?", "Sí, desde Mercado Pago. La devolución sale de tu saldo, porque la plata es tuya."),
        ("¿Tengo que facturar?", "Depende de tu situación. Suele ser un ingreso por tu trabajo (monotributo o Ingresos Brutos). Consultalo con tu contador."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(preguntas, id: \.0) { p in
                    Tarjeta(relleno: 16) {
                        DisclosureGroup {
                            Text(p.1).tipo(.texto(15, 400)).foregroundStyle(Color.tinta).fixedSize(horizontal: false, vertical: true).padding(.top, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } label: {
                            Text(p.0).tipo(.texto(16, 700)).foregroundStyle(Color.tinta).multilineTextAlignment(.leading)
                        }
                        .tint(Color.tinta)
                    }
                }
                TituloSeccion(texto: "¿No está tu pregunta?")
                Link(destination: URL(string: "mailto:ayuda@bancamos.com.ar")!) {
                    HStack(spacing: 8) { IconoVista(.mensaje, tamano: 20); Text("Escribinos").tipo(.texto(16, 700)) }
                        .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 52)
                        .background(Color.tinta, in: RoundedRectangle(cornerRadius: Radio.control))
                }
                Text("Te contestamos en el día, de lunes a viernes.").tipo(.texto(13, 400)).foregroundStyle(Color.gris).frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Ayuda")
    }
}
