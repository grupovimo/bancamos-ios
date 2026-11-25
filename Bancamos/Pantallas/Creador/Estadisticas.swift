import SwiftUI
import Charts

/// Estadísticas: lo que entró por mes, los que te bancan cada mes, de dónde viene y las visitas a la página.
struct Estadisticas: View {
    @Environment(Estado.self) private var estado
    @State private var marcado: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                cifras
                TituloSeccion(texto: "Lo que entró por mes")
                Tarjeta(relleno: 16) { GraficoMeses(meses: estado.panel.meses, marcado: $marcado) }
                TituloSeccion(texto: "Te bancan cada mes")
                Tarjeta(relleno: 16) { GraficoMiembros(meses: estado.panel.meses) }
                TituloSeccion(texto: "Por nivel")
                Tarjeta(relleno: 16) { PorNivel(niveles: estado.yo.nivelesActivos) }
                TituloSeccion(texto: "Visitas a tu página")
                Tarjeta(relleno: 16) { GraficoVisitas(puntos: estado.panel.visitas, bancaron: estado.sueltasEsteMes + estado.yo.mensuales / 10) }
            }
            .padding(.horizontal, Espacio.margen)
            .padding(.bottom, 40)
        }
        .background(Color.fondo)
        .navigationTitle("Estadísticas")
    }

    private var cifras: some View {
        let m = estado.mesActual
        let promedio = (m?.apoyos ?? 0) + estado.yo.mensuales > 0 ? (m?.bruto ?? 0) / max(1, (m?.apoyos ?? 0) + estado.yo.mensuales) : 0
        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            Cifra(titulo: "Este mes", valor: Plata.texto(m?.bruto ?? 0), sub: estado.crecimiento.map { "\($0 >= 0 ? "+" : "")\($0) % que el anterior" })
            Cifra(titulo: "Cada mes", valor: Plata.numero(estado.yo.mensuales), sub: "personas")
            Cifra(titulo: "Aporte promedio", valor: Plata.texto(promedio), sub: nil)
            Cifra(titulo: "Bajas del mes", valor: "\(estado.panel.miembros.filter { $0.estado == .baja }.count)", sub: "de \(Plata.numero(estado.yo.mensuales))")
        }
    }
}

private struct Cifra: View {
    let titulo: String
    let valor: String
    var sub: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Etiqueta(titulo)
            Text(valor).tipo(.numero(24)).foregroundStyle(Color.tinta).lineLimit(1).minimumScaleFactor(0.7)
            Text(sub ?? " ").tipo(.texto(12, 500)).foregroundStyle(Color.gris).lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .sombra()
        .accessibilityElement(children: .combine)
    }
}

/// Barras por mes; el mes actual en esmeralda, los anteriores más suaves. Se toca para ver el número.
struct GraficoMeses: View {
    let meses: [MesCobros]
    @Binding var marcado: String?

    var body: some View {
        let elegido = marcado ?? meses.last?.mes
        VStack(alignment: .leading, spacing: 6) {
            if let m = meses.first(where: { $0.mes == elegido }) {
                Text(Fecha.mesDe(m.mes)).tipo(.texto(13, 600)).foregroundStyle(Color.gris)
                Text(Plata.texto(m.bruto)).tipo(.numero(26)).foregroundStyle(Color.tinta)
                    .contentTransition(.numericText(value: Double(m.bruto)))
            }
            Chart(meses) { m in
                BarMark(x: .value("Mes", Fecha.mesCortoDe(m.mes)), y: .value("Entró", m.bruto), width: .ratio(0.62))
                    .foregroundStyle(m.mes == elegido ? Color.esmeralda : Color.esmeralda.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { v in
                    AxisGridLine().foregroundStyle(Color.linea)
                    AxisValueLabel { if let n = v.as(Int.self) { Text(Plata.corto(n)).font(Estilo.texto(11, 500).font()) } }
                }
            }
            .chartXAxis { AxisMarks { _ in AxisValueLabel().font(Estilo.texto(12, 600).font()) } }
            .chartOverlay { p in
                GeometryReader { _ in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0).onChanged { g in
                            if let x: String = p.value(atX: g.location.x), let m = meses.first(where: { Fecha.mesCortoDe($0.mes) == x }), m.mes != marcado {
                                Haptico.seleccion()
                                withAnimation(.snappy) { marcado = m.mes }
                            }
                        })
                }
            }
            .frame(height: 190)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lo que entró por mes")
        .accessibilityValue(meses.map { "\(Fecha.mesDe($0.mes)): \(Plata.texto($0.bruto))" }.joined(separator: ", "))
    }
}

private struct GraficoMiembros: View {
    let meses: [MesCobros]
    var body: some View {
        Chart(meses) { m in
            AreaMark(x: .value("Mes", Fecha.mesCortoDe(m.mes)), y: .value("Personas", m.miembros))
                .foregroundStyle(LinearGradient(colors: [Color.esmeralda.opacity(0.25), Color.esmeralda.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                .interpolationMethod(.catmullRom)
            LineMark(x: .value("Mes", Fecha.mesCortoDe(m.mes)), y: .value("Personas", m.miembros))
                .foregroundStyle(Color.esmeralda700)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .interpolationMethod(.catmullRom)
            PointMark(x: .value("Mes", Fecha.mesCortoDe(m.mes)), y: .value("Personas", m.miembros))
                .foregroundStyle(Color.esmeralda700)
                .annotation(position: .top) {
                    if m.mes == meses.last?.mes { Text("\(m.miembros)").font(Estilo.texto(12, 700).font()).foregroundStyle(Color.tinta) }
                }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine().foregroundStyle(Color.linea)
                AxisValueLabel().font(Estilo.texto(11, 500).font())
            }
        }
        .chartXAxis { AxisMarks { _ in AxisValueLabel().font(Estilo.texto(12, 600).font()) } }
        .frame(height: 170)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Personas que te bancan cada mes")
        .accessibilityValue(meses.map { "\(Fecha.mesDe($0.mes)): \($0.miembros)" }.joined(separator: ", "))
    }
}

private struct PorNivel: View {
    let niveles: [Nivel]
    var body: some View {
        let total = max(1, niveles.reduce(0) { $0 + $1.precio * $1.miembros })
        VStack(spacing: 12) {
            GeometryReader { g in
                HStack(spacing: 3) {
                    ForEach(Array(niveles.enumerated()), id: \.element.id) { i, n in
                        Rectangle().fill(tono(i))
                            .frame(width: max(4, g.size.width * CGFloat(n.precio * n.miembros) / CGFloat(total) - 3))
                    }
                }
                .clipShape(Capsule())
            }
            .frame(height: 14)
            ForEach(Array(niveles.enumerated()), id: \.element.id) { i, n in
                HStack(spacing: 10) {
                    Circle().fill(tono(i)).frame(width: 10, height: 10)
                    Text(n.nombre).tipo(.texto(15, 600)).foregroundStyle(Color.tinta)
                    Text("\(n.miembros) × \(Plata.texto(n.precio))").tipo(.texto(13, 400)).foregroundStyle(Color.gris)
                    Spacer()
                    Text(Plata.texto(n.precio * n.miembros)).tipo(.texto(15, 700)).foregroundStyle(Color.tinta)
                }
            }
        }
    }

    private func tono(_ i: Int) -> Color { [Color.esmeralda.opacity(0.35), Color.esmeralda, Color.esmeralda900, Color.tinta][i % 4] }
}

private struct GraficoVisitas: View {
    let puntos: [Punto]
    let bancaron: Int
    var body: some View {
        let total = puntos.reduce(0) { $0 + $1.valor }
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(Plata.numero(total)).tipo(.numero(26)).foregroundStyle(Color.tinta)
                Text("en 14 días").tipo(.texto(14, 400)).foregroundStyle(Color.gris)
                Spacer()
                if total > 0 { Chip(texto: "\(String(format: "%.1f", Double(bancaron) / Double(total) * 100).replacingOccurrences(of: ".", with: ",")) % bancó", tono: .marca) }
            }
            Chart(puntos) { p in
                BarMark(x: .value("Día", p.etiqueta), y: .value("Visitas", p.valor), width: .ratio(0.55))
                    .foregroundStyle(Color.tinta.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: puntos.enumerated().filter { $0.offset % 4 == 1 }.map(\.element.etiqueta)) { _ in
                    AxisValueLabel().font(Estilo.texto(11, 500).font())
                }
            }
            .frame(height: 120)
            if total == 0 {
                Text("Compartí tu link para que lleguen visitas.").tipo(.texto(13, 500)).foregroundStyle(Color.gris)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
