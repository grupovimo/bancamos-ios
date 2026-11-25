import SwiftUI

/// Las tres pantallas de bienvenida (con la meta que se llena) y la elección del lado.
struct Bienvenida: View {
    @Binding var indice: Int
    let borrador: BorradorOnb
    var siguiente: () -> Void

    var body: some View {
        if indice < 3 { carrusel } else { ElegirLado(borrador: borrador, siguiente: siguiente, atras: { indice = 2 }) }
    }

    private var carrusel: some View {
        VStack(spacing: 0) {
            Image("logotipo").resizable().scaledToFit().frame(height: 26)
                .padding(.top, 10)
                .accessibilityLabel("Bancamos")
            TabView(selection: $indice) {
                Diapositiva(titulo: "Que te banque tu gente.",
                            sub: "Aportes de una vez o cada mes, para seguir haciendo lo que hacés.") { VisualMeta(activa: indice == 0) }
                    .tag(0)
                Diapositiva(titulo: "Bancá a quien te alegra el día.",
                            sub: "Con un mensaje, una vez o cada mes. Te das de baja con un toque.") { VisualApoyo(activa: indice == 1) }
                    .tag(1)
                Diapositiva(titulo: "La plata va directo a su Mercado Pago.",
                            sub: "Bancamos nunca la tiene. Sólo descuenta su 3 %.") { VisualDirecto(activa: indice == 2) }
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule().fill(i == indice ? Color.tinta : Color.linea).frame(width: i == indice ? 22 : 8, height: 8)
                }
            }
            .animation(.snappy, value: indice)
            .padding(.bottom, 16)
            .accessibilityHidden(true)
            Boton(titulo: indice == 2 ? "Empezar" : "Seguir", variante: indice == 2 ? .prim : .osc, alto: .alto, ancho: true) {
                Haptico.suave()
                withAnimation(.snappy) { indice += 1 }
            }
            .padding(.horizontal, Espacio.margen)
            BotonTexto(titulo: "Saltear", color: .gris) { withAnimation(.snappy) { indice = 3 } }
                .opacity(indice == 2 ? 0 : 1)
        }
    }
}

private struct Diapositiva<Visual: View>: View {
    let titulo: String
    let sub: String
    @ViewBuilder var visual: () -> Visual

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            visual()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .padding(.top, 18)
            Titulo(titulo, tamano: 34).padding(.top, 26)
            Sec(sub, tamano: 17).padding(.top, 8)
        }
        .padding(.horizontal, Espacio.margen)
        .padding(.bottom, 22)
    }
}

/// 1 · La foto de Ana y su meta que se llena.
private struct VisualMeta: View {
    var activa: Bool
    @State private var lleno = false

    var body: some View {
        ZStack(alignment: .bottom) {
            FotoRecortada(imagen: .asset("foto-ilustradora", 0.52, 0.4), zoom: 1)
                .clipShape(RoundedRectangle(cornerRadius: Radio.foto, style: .continuous))
                .padding(.bottom, 54)
            Tarjeta(relleno: 16) {
                HStack {
                    Avatar(DatosDeMuestra.ana, tamano: 32)
                    Text("Imprimir mi primer libro").tipo(.texto(15, 700)).foregroundStyle(Color.tinta).lineLimit(1)
                    Spacer(minLength: 4)
                    Chip(texto: lleno ? "72 %" : "0 %")
                }
                HStack(alignment: .firstTextBaseline) {
                    Text(Plata.texto(lleno ? 612_000 : 0)).tipo(.numero(26)).foregroundStyle(Color.tinta)
                        .contentTransition(.numericText(value: lleno ? 612_000 : 0))
                    Spacer()
                    Text("de $850.000").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                }
                .padding(.top, 8)
                BarraMeta(fraccion: lleno ? 0.72 : 0.02).padding(.top, 10)
            }
            .padding(.horizontal, 14)
        }
        .onAppear(perform: animar)
        .onChange(of: activa) { animar() }
    }

    private func animar() {
        lleno = false
        guard activa else { return }
        withAnimation(.easeInOut(duration: 1.4).delay(0.35)) { lleno = true }
    }
}

/// 2 · Alguien banca desde el colectivo y le llega con su mensaje.
private struct VisualApoyo: View {
    var activa: Bool
    @State private var visible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            FotoRecortada(imagen: .asset("foto-banca", 0.5, 0.4), zoom: 1)
                .clipShape(RoundedRectangle(cornerRadius: Radio.foto, style: .continuous))
                .padding(.bottom, 64)
            Tarjeta(relleno: 14) {
                HStack(alignment: .top, spacing: 12) {
                    Avatar(imagen: nil, iniciales: "MG", tamano: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Martín G.").tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                            Spacer()
                            Text("$2.000").tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                        }
                        Text("Te bancó una vez · recién").tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                        Text("Para los lápices.").tipo(.texto(14, 400)).foregroundStyle(Color.tinta)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(Color.fondo, in: UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 14, bottomTrailingRadius: 14, topTrailingRadius: 14))
                            .padding(.top, 6)
                    }
                }
            }
            .padding(.horizontal, 14)
            .offset(y: visible ? 0 : 30)
            .opacity(visible ? 1 : 0)
        }
        .onAppear(perform: animar)
        .onChange(of: activa) { animar() }
    }

    private func animar() {
        visible = false
        guard activa else { return }
        withAnimation(.spring(duration: 0.6, bounce: 0.3).delay(0.3)) { visible = true }
    }
}

/// 3 · Tu gente → tu Mercado Pago, y la meta cumplida.
private struct VisualDirecto: View {
    var activa: Bool
    @State private var lleno = false

    var body: some View {
        VStack(spacing: 14) {
            Borde(relleno: 0) {
                HStack(spacing: 10) {
                    nodo(texto: "Tu gente", fondo: .esmeralda100) { IconoVista(.gente, tamano: 28).foregroundStyle(Color.esmeralda700) }
                    IconoVista(.flecha, tamano: 24).foregroundStyle(Color.tinta)
                        .offset(x: lleno ? 4 : -4)
                        .animation(activa ? .easeInOut(duration: 0.8).repeatForever() : .default, value: lleno)
                    nodo(texto: "Su Mercado Pago", fondo: .mp) { IconoVista(.mp, tamano: 36).foregroundStyle(.white) }
                }
                .padding(.vertical, 22).padding(.horizontal, 16)
            }
            Tarjeta(relleno: 16) {
                HStack {
                    Text("Grabar el disco").tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                    Spacer()
                    Chip(texto: lleno ? "¡Meta cumplida!" : "92 %", tono: lleno ? .oscuro : .marca, icono: lleno ? .tilde : nil)
                }
                BarraMeta(fraccion: lleno ? 1 : 0.92).padding(.top, 12)
                Text("Bancamos se queda con el 3 %. Lo de Mercado Pago va aparte.").tipo(.texto(13, 400)).foregroundStyle(Color.gris).padding(.top, 8)
            }
            .background { if lleno && activa { Papelitos(cantidad: 24, centroLibre: false).padding(-24).transition(.opacity) } }
            Spacer(minLength: 0)
        }
        .onAppear(perform: animar)
        .onChange(of: activa) { animar() }
    }

    private func nodo<I: View>(texto: String, fondo: Color, @ViewBuilder icono: () -> I) -> some View {
        VStack(spacing: 8) {
            icono().frame(width: 68, height: 68).background(fondo, in: Circle())
            Text(texto).tipo(.texto(13, 700)).foregroundStyle(Color.tinta).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func animar() {
        lleno = false
        guard activa else { return }
        withAnimation(.easeInOut(duration: 1).delay(0.5)) { lleno = true }
    }
}

/// «¿Cómo querés usar Bancamos?»: dos tarjetas grandes con foto.
private struct ElegirLado: View {
    let borrador: BorradorOnb
    var siguiente: () -> Void
    var atras: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: atras) {
                IconoVista(.atras, tamano: 24).foregroundStyle(Color.tinta).frame(width: 44, height: 44).contentShape(Rectangle())
            }
            .accessibilityLabel("Volver")
            .padding(.leading, 10)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Titulo("¿Cómo querés usar Bancamos?", tamano: 32)
                    Sec("Podés cambiar cuando quieras desde Ajustes.", tamano: 16).padding(.bottom, 6)
                    opcion(.creador, titulo: "Quiero que me banquen",
                           sub: "Armá tu página, tus niveles y tu meta. Cobrás directo en tu Mercado Pago.",
                           foto: .asset("foto-musico", 0.55, 0.42))
                    opcion(.fan, titulo: "Quiero bancar a alguien",
                           sub: "Encontrá a quien te gusta y bancalo con un mensaje, una vez o cada mes.",
                           foto: .asset("foto-banca", 0.5, 0.35))
                }
                .padding(.horizontal, Espacio.margen)
                .padding(.top, 8).padding(.bottom, 24)
            }
        }
    }

    private func opcion(_ l: Lado, titulo: String, sub: String, foto: Imagen) -> some View {
        Button {
            borrador.lado = l
            siguiente()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                FotoRecortada(imagen: foto, zoom: 1.15).frame(height: 150)
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(titulo).tipo(.titulo(20)).foregroundStyle(Color.tinta)
                        Text(sub).tipo(.texto(14, 400)).foregroundStyle(Color.gris).multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    IconoVista(.flecha, tamano: 20).foregroundStyle(.white)
                        .frame(width: 44, height: 44).background(Color.esmeralda700, in: Circle())
                }
                .padding(16)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous).strokeBorder(Color.linea, lineWidth: 1.5))
        }
        .buttonStyle(Apretable())
    }
}
