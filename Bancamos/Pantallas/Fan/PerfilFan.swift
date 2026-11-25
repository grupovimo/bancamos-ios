import SwiftUI

/// El perfil del que banca: sus números, recibos, medio de pago, avisos y ajustes.
struct PerfilFan: View {
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav
    @State private var salir = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 10) {
                    Avatar(imagen: nil, iniciales: Texto.iniciales(estado.fan.nombre), tamano: 88)
                    Titulo(estado.fan.nombre, tamano: 28)
                    if !estado.fan.email.isEmpty { Text(estado.fan.email).tipo(.texto(14, 400)).foregroundStyle(Color.gris) }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                HStack(spacing: 10) {
                    numero(estado.fan.membresias.count, "bancás cada mes")
                    numero(estado.fan.recibos.filter { $0.tipo == .unaVez }.count, "bancadas sueltas")
                    numero(estado.fan.siguiendo.count, "seguís")
                }
                .padding(.top, 20)
                TituloSeccion(texto: "Tu cuenta")
                Tarjeta {
                    Button { nav.ir(.recibos) } label: { FilaMenu(icono: .recibo, titulo: "Recibos", sub: "\(estado.fan.recibos.count) pagos") }
                        .buttonStyle(Apretable())
                    Divisor(izquierda: 68)
                    FilaMenu(icono: .mp, titulo: "Cómo pagás", sub: estado.fan.medio.isEmpty ? "Con tu cuenta de Mercado Pago, al pagar" : "\(estado.fan.medio), en Mercado Pago",
                             colorIcono: .white, fondoIcono: .mp)
                    Divisor(izquierda: 68)
                    Button { nav.ir(.avisos) } label: { FilaMenu(icono: .campana, titulo: "Avisos", sub: "Posteos nuevos y antes de cada cuota") }
                        .buttonStyle(Apretable())
                    Divisor(izquierda: 68)
                    Button { nav.ir(.ajustes) } label: { FilaMenu(icono: .segura, titulo: "Ajustes", sub: "Privacidad y cuenta") }
                        .buttonStyle(Apretable())
                }
                Button { estado.cambiarLado(.creador) } label: {
                    HStack(spacing: 14) {
                        Image("isotipo").resizable().scaledToFit().frame(width: 26)
                            .frame(width: 48, height: 48).background(Color.white, in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("¿Hacés algo? Que te banquen").tipo(.texto(16, 700)).foregroundStyle(.white)
                            Text("Armá tu página en 5 minutos").tipo(.texto(14, 400)).foregroundStyle(.white.opacity(0.85))
                        }
                        Spacer()
                        IconoVista(.flecha, tamano: 20).foregroundStyle(.white)
                    }
                    .padding(16)
                    .background(Color.esmeralda700, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
                }
                .buttonStyle(Apretable())
                .padding(.top, 18)
                TituloSeccion(texto: "Ayuda")
                Tarjeta {
                    Link(destination: URL(string: "mailto:ayuda@bancamos.com.ar")!) {
                        FilaMenu(icono: .mensaje, titulo: "Escribinos", sub: "Te contestamos en el día")
                    }
                }
                Boton(titulo: "Cerrar sesión", icono: .salir, variante: .blanco, alto: .normal, ancho: true) { salir = true }
                    .padding(.top, 22)
                Text("Bancamos 1.0 · De Grupo Vimo").tipo(.texto(12, 500)).foregroundStyle(Color.gris).frame(maxWidth: .infinity).padding(.top, 14)
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, Espacio.bajoBarra)
        }
        .background(Color.fondo)
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("¿Cerrar sesión?", isPresented: $salir, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) { estado.cerrarSesion() }
        } message: { Text("Tus membresías siguen activas.") }
    }

    private func numero(_ n: Int, _ t: String) -> some View {
        VStack(spacing: 2) {
            Text("\(n)").tipo(.numero(24)).foregroundStyle(Color.tinta)
            Text(t).tipo(.texto(12, 500)).foregroundStyle(Color.gris).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .sombra()
        .accessibilityElement(children: .combine)
    }
}

struct FilaRecibo: View {
    let recibo: Recibo
    let creador: Creador?
    var body: some View {
        HStack(spacing: 12) {
            if let creador { Avatar(creador, tamano: 40) }
            VStack(alignment: .leading, spacing: 1) {
                Text(creador?.nombre ?? "").tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                Text("\(recibo.concepto) · \(Fecha.corta(recibo.fecha))").tipo(.texto(13, 400)).foregroundStyle(Color.gris)
            }
            Spacer()
            Text(Plata.texto(recibo.monto)).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
        }
        .padding(.horizontal, 16).frame(minHeight: 64).contentShape(Rectangle())
    }
}

/// Todos los recibos.
struct Recibos: View {
    @Environment(Estado.self) private var estado
    @Environment(NavFan.self) private var nav

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if estado.fan.recibos.isEmpty {
                    EstadoVacio(icono: .recibo, titulo: "Sin recibos todavía", texto: "Cada vez que bancás a alguien, el recibo queda acá y te llega por mail.")
                } else {
                    Tarjeta {
                        ForEach(Array(estado.fan.recibos.enumerated()), id: \.element.id) { i, r in
                            if i > 0 { Divisor(izquierda: 68) }
                            Button { nav.ir(.recibo(r.id)) } label: { FilaRecibo(recibo: r, creador: estado.creador(r.creadorId)) }
                                .buttonStyle(Apretable())
                        }
                    }
                    Text("En total: \(Plata.texto(estado.fan.recibos.reduce(0) { $0 + $1.monto })).").tipo(.texto(14, 500)).foregroundStyle(Color.gris).padding(.top, 12)
                }
            }
            .padding(.horizontal, Espacio.margen).padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Recibos")
    }
}

struct DetalleRecibo: View {
    let reciboId: String
    @Environment(Estado.self) private var estado

    var body: some View {
        if let r = estado.fan.recibos.first(where: { $0.id == reciboId }) {
            let c = estado.creador(r.creadorId)
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        IconoVista(.tilde, tamano: 26).foregroundStyle(.white).frame(width: 56, height: 56).background(Color.ok, in: Circle())
                        Text(Plata.texto(r.monto)).tipo(.numero(40)).foregroundStyle(Color.tinta)
                        Text("Pago aprobado").tipo(.texto(15, 600)).foregroundStyle(Color.ok)
                    }
                    .padding(.vertical, 22)
                    Tarjeta(relleno: 16) {
                        FilaDato(etiqueta: "Para", valor: c?.nombre ?? "")
                        Divisor()
                        FilaDato(etiqueta: "Concepto", valor: r.concepto)
                        Divisor()
                        FilaDato(etiqueta: "Fecha", valor: "\(Fecha.dia(r.fecha)), \(Fecha.hora(r.fecha))")
                        Divisor()
                        FilaDato(etiqueta: "Medio", valor: r.medio)
                        Divisor()
                        FilaDato(etiqueta: "Número", valor: r.numero)
                        if !r.mensaje.isEmpty {
                            Divisor()
                            FilaDato(etiqueta: "Tu mensaje", valor: "«\(r.mensaje)»", fuerte: false)
                        }
                    }
                    NotaSegura(texto: "El pago fue directo a la cuenta de Mercado Pago de \(c?.primerNombre ?? "quien bancaste"). Para devoluciones, escribinos.")
                        .padding(.top, 12)
                    CompartirBoton(generar: { "Recibo \(r.numero) · Bancamos\n\(r.concepto) para \(c?.nombre ?? "")\n\(Plata.texto(r.monto)) · \(Fecha.dia(r.fecha))\n\(r.medio)" }) {
                        HStack(spacing: 8) { IconoVista(.compartir, tamano: 20); Text("Compartir recibo").tipo(.texto(16, 700)) }
                            .foregroundStyle(Color.tinta).frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.control))
                            .overlay(RoundedRectangle(cornerRadius: Radio.control).strokeBorder(Color.linea, lineWidth: 1.5))
                    }
                    .padding(.top, 14)
                }
                .padding(.horizontal, Espacio.margen).padding(.bottom, 40)
            }
            .background(Color.fondo)
            .navigationTitle("Recibo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// Ajustes del que banca.
struct AjustesFan: View {
    @Environment(Estado.self) private var estado
    @State private var borrar = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Tarjeta(relleno: 16) {
                    FilaInterruptor(titulo: "Ver con datos de ejemplo", sub: "Para ver cómo es bancar a varias personas.",
                                    valor: Binding(get: { estado.perfil?.conEjemplos ?? true }, set: { estado.usarEjemplos($0) }))
                    Divisor().padding(.vertical, 8)
                    Button { estado.cambiarLado(.creador) } label: {
                        HStack {
                            Text("Pasar a mi página de creador").tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                            Spacer()
                            IconoVista(.flecha, tamano: 18).foregroundStyle(Color.esmeralda700)
                        }
                        .frame(minHeight: 44).contentShape(Rectangle())
                    }
                    .buttonStyle(Apretable())
                }
                TituloSeccion(texto: "Legales")
                Tarjeta {
                    Link(destination: URL(string: "https://bancamos.com.ar/terminos")!) { FilaMenu(icono: .texto, titulo: "Términos y condiciones") }
                    Divisor(izquierda: 68)
                    Link(destination: URL(string: "https://bancamos.com.ar/privacidad")!) { FilaMenu(icono: .candado, titulo: "Política de privacidad") }
                    Divisor(izquierda: 68)
                    Link(destination: URL(string: "https://bancamos.com.ar/arrepentimiento")!) { FilaMenu(icono: .recibo, titulo: "Botón de arrepentimiento") }
                }
                Button { borrar = true } label: {
                    Text("Eliminar mi cuenta").tipo(.texto(15, 600)).foregroundStyle(Color.error).frame(maxWidth: .infinity, minHeight: 44)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, Espacio.margen).padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("¿Eliminar tu cuenta?", isPresented: $borrar, titleVisibility: .visible) {
            Button("Eliminar cuenta", role: .destructive) { estado.cerrarSesion() }
        } message: { Text("Se cancelan todas tus membresías y borramos tus datos en 30 días.") }
    }
}
