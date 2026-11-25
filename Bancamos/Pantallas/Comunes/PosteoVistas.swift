import SwiftUI

/// Un posteo como tarjeta: cabecera con el creador, lo que muestra (o el candado) y los «me gusta».
struct TarjetaPosteo: View {
    let creador: Creador
    let posteo: Posteo
    var bloqueado = false
    var conCabecera = true
    var meGusta: (() -> Void)? = nil
    var desbloquear: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if conCabecera {
                HStack(spacing: 10) {
                    Avatar(creador, tamano: 36)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(creador.nombre).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                        Text(Fecha.hace(posteo.fecha)).tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                    }
                    Spacer()
                    ChipPublico(creador: creador, publico: posteo.publico)
                }
                .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 12)
            }
            if bloqueado {
                Bloqueado(creador: creador, posteo: posteo, desbloquear: desbloquear)
            } else {
                MediaPosteo(posteo: posteo).padding(.horizontal, posteo.tipo == .fotos ? 0 : 16)
                VStack(alignment: .leading, spacing: 6) {
                    Text(posteo.titulo).tipo(.titulo(20)).foregroundStyle(Color.tinta)
                    Text(posteo.texto).tipo(.texto(15, 400)).foregroundStyle(Color.tinta.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true).lineLimit(4)
                }
                .padding(.horizontal, 16).padding(.top, 12)
                HStack(spacing: 16) {
                    Button { meGusta?() } label: {
                        HStack(spacing: 6) {
                            IconoVista(posteo.leGusta ? .corazonLleno : .corazon, tamano: 20)
                                .foregroundStyle(posteo.leGusta ? Color.esmeralda : Color.tinta)
                                .scaleEffect(posteo.leGusta ? 1.1 : 1)
                            Text(Plata.numero(posteo.meGusta)).tipo(.texto(14, 600)).foregroundStyle(Color.tinta)
                                .contentTransition(.numericText(value: Double(posteo.meGusta)))
                        }
                        .frame(minHeight: 44).contentShape(Rectangle())
                    }
                    .buttonStyle(Apretable())
                    .disabled(meGusta == nil)
                    .accessibilityLabel(posteo.leGusta ? "Ya te gusta, \(posteo.meGusta)" : "Me gusta, \(posteo.meGusta)")
                    HStack(spacing: 6) {
                        IconoVista(.mensaje, tamano: 20).foregroundStyle(Color.tinta)
                        Text(Plata.numero(posteo.comentarios)).tipo(.texto(14, 600)).foregroundStyle(Color.tinta)
                    }
                    .accessibilityElement(children: .combine)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.bottom, 4)
            }
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: Radio.tarjeta, style: .continuous))
        .sombra()
    }
}

/// Quién lo ve, en un chip («Color y Original» con candado).
struct ChipPublico: View {
    let creador: Creador
    let publico: PublicoPosteo
    var body: some View {
        if publico == .todos {
            Chip(texto: "Para todos", tono: .gris)
        } else {
            Chip(texto: creador.publicoTexto(publico), tono: .gris, icono: .candado)
        }
    }
}

/// Las fotos (grilla como en el diseño), el audio o nada si es texto.
struct MediaPosteo: View {
    let posteo: Posteo

    var body: some View {
        switch posteo.tipo {
        case .fotos: GrillaFotos(fotos: posteo.fotos)
        case .audio: ReproductorAudio(segundos: posteo.audioSegundos)
        case .texto: EmptyView()
        }
    }
}

struct GrillaFotos: View {
    let fotos: [Imagen]
    var alto: CGFloat = 220

    var body: some View {
        if fotos.count >= 3 {
            HStack(spacing: 6) {
                FotoRecortada(imagen: fotos[0], zoom: fotos[0].zoom / 1.4)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .layoutPriority(1.4)
                VStack(spacing: 6) {
                    FotoRecortada(imagen: fotos[1], zoom: fotos[1].zoom / 1.4).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    FotoRecortada(imagen: fotos[2], zoom: fotos[2].zoom / 1.4).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            if fotos.count > 3 {
                                Text("+\(fotos.count - 3)").tipo(.texto(16, 700)).foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity).background(.black.opacity(0.35))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: alto)
            .padding(.horizontal, 12)
        } else if let f = fotos.first {
            FotoRecortada(imagen: f, zoom: f.datos != nil ? 1 : f.zoom / 1.4)
                .frame(height: alto)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 12)
        }
    }
}

/// Un reproductor de audio (en la maqueta avanza solo, sin sonido).
struct ReproductorAudio: View {
    let segundos: Int
    @State private var sonando = false
    @State private var avance: Double = 0

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Haptico.suave()
                sonando.toggle()
            } label: {
                IconoVista(sonando ? .pausa : .play, tamano: 20, grosor: 2.6).foregroundStyle(.white)
                    .frame(width: 44, height: 44).background(Color.esmeralda700, in: Circle())
            }
            .buttonStyle(Apretable())
            .accessibilityLabel(sonando ? "Pausar" : "Escuchar")
            OndaAudio(avance: avance)
            Text(tiempo(sonando || avance > 0 ? Int(Double(segundos) * avance) : segundos))
                .tipo(.texto(13, 600)).monospacedDigit().foregroundStyle(Color.gris)
        }
        .padding(12)
        .background(Color.esmeralda50, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .task(id: sonando) {
            while sonando && avance < 1 {
                try? await Task.sleep(for: .milliseconds(200))
                avance = min(1, avance + 0.2 / Double(max(segundos, 1)) * 8)
            }
            if avance >= 1 { sonando = false; avance = 0 }
        }
    }

    private func tiempo(_ s: Int) -> String { String(format: "%d:%02d", s / 60, s % 60) }
}

struct OndaAudio: View {
    var avance: Double = 0
    var barras = 32
    var body: some View {
        GeometryReader { g in
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<barras, id: \.self) { i in
                    let h = 6 + abs(sin(Double(i) * 1.7) * cos(Double(i) * 0.6)) * 20
                    Capsule()
                        .fill(Double(i) / Double(barras) < avance ? Color.esmeralda700 : Color.esmeralda.opacity(0.35))
                        .frame(width: max(2, (g.size.width - CGFloat(barras - 1) * 2) / CGFloat(barras)), height: h)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 30)
        .accessibilityHidden(true)
    }
}

/// Lo exclusivo para quien no banca: borroso, con candado y la invitación a sumarse.
struct Bloqueado: View {
    let creador: Creador
    let posteo: Posteo
    var desbloquear: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if let f = posteo.fotos.first {
                    FotoRecortada(imagen: f, zoom: f.zoom / 1.4).blur(radius: 18).overlay(Color.tinta.opacity(0.25))
                } else {
                    LinearGradient(colors: [.esmeralda100, Color(hex: 0xD5EFE3)], startPoint: .top, endPoint: .bottom)
                }
                VStack(spacing: 8) {
                    IconoVista(.candado, tamano: 24).foregroundStyle(posteo.fotos.isEmpty ? Color.esmeralda700 : .white)
                        .frame(width: 52, height: 52)
                        .background(posteo.fotos.isEmpty ? Color.white : Color.white.opacity(0.2), in: Circle())
                    Text("Para \(creador.publicoTexto(posteo.publico).replacingOccurrences(of: "Los que te bancan", with: "los que \(creador.lo) bancan"))")
                        .tipo(.texto(14, 700)).foregroundStyle(posteo.fotos.isEmpty ? Color.tinta : .white)
                }
            }
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 12)
            VStack(alignment: .leading, spacing: 10) {
                Text(posteo.titulo).tipo(.titulo(20)).foregroundStyle(Color.tinta)
                if let desbloquear {
                    Boton(titulo: "Bancá\(creador.lo) para verlo", icono: .abierto,
                          variante: .prim, alto: .chico, accion: desbloquear)
                }
            }
            .padding(16)
        }
    }
}
