import SwiftUI

/// Encabezado de las hojas de Mercado Pago (simuladas en la maqueta).
private struct EncabezadoMP: View {
    var cerrar: () -> Void
    var body: some View {
        HStack(spacing: 10) {
            IconoVista(.mp, tamano: 34).foregroundStyle(.white)
            Text("Mercado Pago").tipo(.texto(18, 700)).foregroundStyle(.white)
            Spacer()
            Button(action: cerrar) {
                IconoVista(.cruz, tamano: 20).foregroundStyle(.white).frame(width: 44, height: 44)
            }
            .accessibilityLabel("Cerrar")
        }
        .padding(.leading, 20).padding(.trailing, 8)
        .frame(height: 64)
        .background(Color.mp)
    }
}

private struct NotaMaqueta: View {
    var body: some View {
        Text("Simulado en la maqueta: no se conecta ni se cobra de verdad.")
            .tipo(.texto(12, 500)).foregroundStyle(Color.gris).multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

/// El OAuth de Mercado Pago: el creador autoriza a Bancamos a cobrar en su cuenta y vuelve solo.
struct HojaAutorizarMP: View {
    var email: String
    var listo: (Bool) -> Void
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var fase = 0 // 0 pedir · 1 conectando · 2 listo

    var body: some View {
        VStack(spacing: 0) {
            EncabezadoMP { listo(false); cerrar() }
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Image("isotipo").resizable().scaledToFit().frame(width: 30)
                            .frame(width: 52, height: 52).background(Color.esmeralda100, in: RoundedRectangle(cornerRadius: 14))
                        IconoVista(.flecha, tamano: 20).foregroundStyle(Color.gris)
                        IconoVista(.mp, tamano: 32).foregroundStyle(.white)
                            .frame(width: 52, height: 52).background(Color.mp, in: RoundedRectangle(cornerRadius: 14))
                    }
                    Text("Bancamos quiere conectarse con tu cuenta").tipo(.titulo(24)).foregroundStyle(Color.tinta)
                    VStack(alignment: .leading, spacing: 0) {
                        permiso("Cobrar los apoyos en tu cuenta", "La plata entra directo a tu Mercado Pago.")
                        Divisor()
                        permiso("Descontar la comisión de Bancamos", "El 3 % de cada apoyo, en el mismo pago.")
                        Divisor()
                        permiso("Ver los pagos de Bancamos", "Para mostrarte lo que entró, en la app.")
                    }
                    Text(email.isEmpty ? "Vas a entrar con tu cuenta de Mercado Pago." : "Cuenta: \(email)")
                        .tipo(.texto(14, 500)).foregroundStyle(Color.gris)
                }
                .padding(20)
            }
            VStack(spacing: 8) {
                switch fase {
                case 0:
                    Boton(titulo: "Autorizar", variante: .mp, alto: .alto, ancho: true) { Task { await autorizar() } }
                    BotonTexto(titulo: "Cancelar", color: .gris) { listo(false); cerrar() }
                case 1:
                    Boton(titulo: "Conectando…", variante: .mp, alto: .alto, ancho: true, cargando: true) {}
                default:
                    Boton(titulo: "Conectado", icono: .tilde, variante: .prim, alto: .alto, ancho: true) {}
                }
                NotaMaqueta()
            }
            .padding(.horizontal, 20).padding(.bottom, 12)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(fase == 1)
    }

    private func permiso(_ t: String, _ s: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconoVista(.tilde, tamano: 20).foregroundStyle(Color.mp)
            VStack(alignment: .leading, spacing: 2) {
                Text(t).tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                Text(s).tipo(.texto(13, 400)).foregroundStyle(Color.gris)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
    }

    private func autorizar() async {
        withAnimation { fase = 1 }
        let ok = await estado.conectarMercadoPago()
        withAnimation(.snappy) { fase = ok ? 2 : 0 }
        guard ok else { return }
        try? await Task.sleep(for: .seconds(0.7))
        listo(true)
        cerrar()
    }
}

/// El checkout de Mercado Pago (simulado): elige el medio y paga. Si sale bien, avisa con el recibo.
struct CheckoutMP: View {
    let creador: Creador
    let pedido: PedidoApoyo
    var pagado: (Recibo) -> Void
    @Environment(Estado.self) private var estado
    @Environment(\.dismiss) private var cerrar
    @State private var medio = 0
    @State private var pagando = false
    @State private var error: String?

    private let medios = [("Visa •••• 4242", "Crédito · vence 08/29", "creditcard"),
                          ("Dinero en cuenta", "Disponible: $23.450", "banknote"),
                          ("Otra tarjeta", "Crédito, débito o prepaga", "plus.circle")]

    var body: some View {
        VStack(spacing: 0) {
            EncabezadoMP { cerrar() }
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Avatar(creador, tamano: 48)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Le pagás a \(creador.nombre)").tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                            Text(pedido.tipo == .mensual ? "Cuota de \(creador.nivel(pedido.nivelId)?.nombre ?? "") · por Bancamos" : "Bancada · por Bancamos")
                                .tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                        }
                    }
                    Text(Plata.texto(pedido.monto)).tipo(.numero(44)).foregroundStyle(Color.tinta)
                    Etiqueta("Cómo pagás")
                    VStack(spacing: 0) {
                        ForEach(medios.indices, id: \.self) { i in
                            filaMedio(i)
                            if i < medios.count - 1 { Divisor(izquierda: 56) }
                        }
                    }
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.linea, lineWidth: 1.5))
                    if let error {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Color.error)
                            Text(error).tipo(.texto(14, 500)).foregroundStyle(Color.error)
                        }
                        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.error100, in: RoundedRectangle(cornerRadius: 14))
                        .transition(.opacity)
                    }
                }
                .padding(20)
            }
            VStack(spacing: 8) {
                Boton(titulo: "Pagar \(Plata.texto(pedido.monto))", variante: .mp, alto: .alto, ancho: true, cargando: pagando) {
                    Task { await pagar() }
                }
                NotaMaqueta()
            }
            .padding(.horizontal, 20).padding(.bottom, 12)
        }
        .background(Color.fondo)
        .interactiveDismissDisabled(pagando)
    }

    private func filaMedio(_ i: Int) -> some View {
        let m = medios[i]
        return Button {
            Haptico.seleccion()
            medio = i
        } label: {
            HStack(spacing: 12) {
                Image(systemName: m.2).font(.system(size: 18, weight: .medium)).foregroundStyle(Color.mp).frame(width: 32)
                VStack(alignment: .leading, spacing: 1) {
                    Text(m.0).tipo(.texto(16, 600)).foregroundStyle(Color.tinta)
                    Text(m.1).tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                }
                Spacer()
                Circle().strokeBorder(medio == i ? Color.mp : Color.linea, lineWidth: medio == i ? 7 : 2).frame(width: 24, height: 24)
            }
            .padding(.horizontal, 14).frame(minHeight: 64).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(medio == i ? .isSelected : [])
    }

    private func pagar() async {
        pagando = true
        withAnimation { error = nil }
        do {
            var p = pedido
            p.mensaje = pedido.mensaje.limpio
            let r = try await estado.apoyar(p)
            pagando = false
            pagado(r)
            cerrar()
        } catch {
            pagando = false
            Haptico.aviso()
            withAnimation { self.error = (error as? LocalizedError)?.errorDescription ?? ErrorDatos.pagoRechazado.errorDescription }
        }
    }
}
