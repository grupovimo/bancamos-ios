import SwiftUI

/// Cobros: lo que acreditó Mercado Pago, la comisión de Bancamos, el historial por mes y la exportación.
struct Cobros: View {
    @Environment(Estado.self) private var estado
    @Environment(NavCreador.self) private var nav
    @Environment(\.openURL) private var abrir
    @State private var todas = false
    @State private var mesAbierto: MesCobros?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let m = estado.mesActual { resumen(m) }
                NotaSegura(texto: "Todo esto ya está en tu Mercado Pago. Para pasarlo a tu banco, retiralo desde Mercado Pago, como siempre.",
                           icono: .segura)
                    .padding(.top, 12)
                Boton(titulo: "Abrir Mercado Pago", variante: .mp, alto: .normal, ancho: true) {
                    abrir(URL(string: "https://www.mercadopago.com.ar/activities")!)
                }
                .padding(.top, 10)
                .disabled(!estado.panel.cuentaMP.conectada)
                acreditaciones
                meses
                Text("* Lo que cobra Mercado Pago depende del plazo de acreditación que elegiste en tu cuenta. Bancamos sólo lo muestra.")
                    .tipo(.texto(12, 400)).foregroundStyle(Color.gris).padding(.top, 16)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Cobros")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CompartirBoton(generar: { estado.csvCobros() }) {
                    IconoVista(.descarga, tamano: 22).foregroundStyle(Color.tinta).frame(width: 44, height: 44)
                }
                .accessibilityLabel("Exportar a CSV")
            }
        }
        .sheet(item: $mesAbierto) { m in HojaMes(mes: m).presentationDetents([.medium, .large]) }
    }

    private func resumen(_ m: MesCobros) -> some View {
        Tarjeta(relleno: 16) {
            Etiqueta("Entró en \(Fecha.mes())")
            Text(Plata.texto(m.bruto)).tipo(.numero(40)).foregroundStyle(Color.tinta).padding(.top, 4)
            Text("\(Texto.plural(m.apoyos, "bancada suelta", "bancadas sueltas")) y \(Texto.plural(m.miembros, "cuota", "cuotas"))")
                .tipo(.texto(14, 400)).foregroundStyle(Color.gris)
            Divisor().padding(.vertical, 10)
            FilaDato(etiqueta: "Bancamos (3 %)", valor: "−\(Plata.texto(m.comision))", fuerte: false)
            FilaDato(etiqueta: "Mercado Pago*", valor: "−\(Plata.texto(m.cargoMP))", fuerte: false)
            Divisor()
            FilaDato(etiqueta: "Te quedó", valor: Plata.texto(m.neto), colorValor: .ok)
        }
    }

    @ViewBuilder private var acreditaciones: some View {
        let lista = estado.panel.acreditaciones
        TituloSeccion(texto: "Lo que acreditó Mercado Pago", accion: lista.count > 6 ? (todas ? "Menos" : "Ver todo") : nil) {
            withAnimation(.snappy) { todas.toggle() }
        }
        if lista.isEmpty {
            Tarjeta {
                EstadoVacio(icono: .plata, titulo: "Todavía no entró nada",
                            texto: estado.panel.cuentaMP.conectada ? "Cuando alguien te banque, cada pago aparece acá con su comisión." : "Primero conectá tu Mercado Pago para poder recibir.",
                            accion: estado.panel.cuentaMP.conectada ? nil : "Conectar") { nav.ir(.cuentaMP) }
            }
        } else {
            Tarjeta {
                ForEach(Array((todas ? lista : Array(lista.prefix(6))).enumerated()), id: \.element.id) { i, a in
                    if i > 0 { Divisor(izquierda: 16) }
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.nombre).tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                            Text("\(a.tipo == .mensual ? "Cuota" : "Bancada") · \(Fecha.hace(a.fecha)) · op. \(a.operacionMP.suffix(6))")
                                .tipo(.texto(12, 400)).foregroundStyle(Color.gris)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(Plata.texto(a.bruto)).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                            Text("te quedan \(Plata.texto(a.neto))").tipo(.texto(12, 500)).foregroundStyle(Color.ok)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    @ViewBuilder private var meses: some View {
        let anteriores = estado.panel.meses.dropLast().reversed()
        if !anteriores.isEmpty {
            TituloSeccion(texto: "Meses anteriores")
            Tarjeta {
                ForEach(Array(anteriores.enumerated()), id: \.element.id) { i, m in
                    if i > 0 { Divisor(izquierda: 16) }
                    Button { mesAbierto = m } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Fecha.mesDe(m.mes)).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                                Text(m.facturaBancamos.map { "Factura \($0)" } ?? "Factura en preparación").tipo(.texto(12, 400)).foregroundStyle(Color.gris)
                            }
                            Spacer()
                            Text(Plata.texto(m.bruto)).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                            IconoVista(.der, tamano: 16).foregroundStyle(Color.gris)
                        }
                        .padding(.horizontal, 16).frame(minHeight: 60).contentShape(Rectangle())
                    }
                    .buttonStyle(Apretable())
                }
            }
        }
    }
}

/// El detalle de un mes cerrado, con la factura de Bancamos.
private struct HojaMes: View {
    let mes: MesCobros
    @Environment(\.dismiss) private var cerrar

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(Plata.texto(mes.bruto)).tipo(.numero(40)).foregroundStyle(Color.tinta)
                    Tarjeta(relleno: 16) {
                        FilaDato(etiqueta: "Bancadas sueltas", valor: "\(mes.apoyos)", fuerte: false)
                        FilaDato(etiqueta: "Cuotas", valor: "\(mes.miembros)", fuerte: false)
                        Divisor()
                        FilaDato(etiqueta: "Bancamos (3 %)", valor: "−\(Plata.texto(mes.comision))", fuerte: false)
                        FilaDato(etiqueta: "Mercado Pago*", valor: "−\(Plata.texto(mes.cargoMP))", fuerte: false)
                        Divisor()
                        FilaDato(etiqueta: "Te quedó", valor: Plata.texto(mes.neto), colorValor: .ok)
                    }
                    if let f = mes.facturaBancamos {
                        CompartirBoton(generar: { "Factura \(f) · Bancamos · comisión de \(Fecha.mesDe(mes.mes)): \(Plata.texto(mes.comision))" }) {
                            HStack(spacing: 8) { IconoVista(.recibo, tamano: 20); Text("Factura \(f)").tipo(.texto(16, 700)) }
                                .foregroundStyle(Color.tinta).frame(maxWidth: .infinity).frame(height: 52)
                                .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.control))
                                .overlay(RoundedRectangle(cornerRadius: Radio.control).strokeBorder(Color.linea, lineWidth: 1.5))
                        }
                    }
                    Sec("Bancamos te factura su 3 % una vez por mes. La factura llega también por mail.")
                }
                .padding(Espacio.margen)
            }
            .background(Color.fondo)
            .navigationTitle(Fecha.mesDe(mes.mes))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Listo") { cerrar() } } }
        }
    }
}
