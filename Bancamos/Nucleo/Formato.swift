import Foundation

/// La comisión de Bancamos: 3 % de lo que entra. Mercado Pago cobra lo suyo aparte.
enum Comision {
    static let porcentaje = 3.0
    /// Lo que se muestra del cargo de Mercado Pago en la maqueta (depende del plazo que eligió el creador en su cuenta).
    static let porcentajeMP = 4.99

    static func de(_ monto: Int) -> Int { Int((Double(monto) * porcentaje / 100).rounded()) }
    static func mercadoPago(_ monto: Int) -> Int { Int((Double(monto) * porcentajeMP / 100).rounded()) }
    /// Lo que le llega por persona antes de Mercado Pago (lo del «Nivel nuevo»: $12.000 → $11.640).
    static func neto(_ monto: Int) -> Int { monto - de(monto) }
}

enum Plata {
    private static let f: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "es_AR")
        f.groupingSeparator = "."
        f.maximumFractionDigits = 0
        return f
    }()

    /// $1.486.000
    static func texto(_ v: Int) -> String { "$" + (f.string(from: NSNumber(value: v)) ?? "\(v)") }
    /// 1.204
    static func numero(_ v: Int) -> String { f.string(from: NSNumber(value: v)) ?? "\(v)" }
    /// $1,4 M · $612 mil (para ejes de gráficos).
    static func corto(_ v: Int) -> String {
        if v >= 1_000_000 {
            let m = Double(v) / 1_000_000
            return "$" + String(format: m >= 10 ? "%.0f" : "%.1f", m).replacingOccurrences(of: ".", with: ",") + " M"
        }
        if v >= 1000 { return "$\(v / 1000) mil" }
        return texto(v)
    }
    /// Lee lo que se tipea («12.000», «$ 5000») como pesos enteros.
    static func leer(_ s: String) -> Int? {
        let d = s.filter(\.isNumber)
        return d.isEmpty ? nil : Int(d.prefix(9))
    }
}

enum Texto {
    static func iniciales(_ nombre: String) -> String {
        let p = nombre.split(separator: " ").prefix(2).compactMap { $0.first }
        return p.isEmpty ? "?" : String(p).uppercased()
    }

    /// Para el @usuario: minúsculas, sin tildes ni espacios.
    static func usuario(_ s: String) -> String {
        let base = s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es_AR")).lowercased()
        return String(base.filter { $0.isLetter || $0.isNumber || $0 == "." || $0 == "_" }.prefix(24))
    }

    static func plural(_ n: Int, _ uno: String, _ varios: String) -> String { n == 1 ? "1 \(uno)" : "\(Plata.numero(n)) \(varios)" }
}

enum Fecha {
    static let ar = Locale(identifier: "es_AR")
    private static func formato(_ f: String) -> DateFormatter {
        let d = DateFormatter()
        d.locale = ar
        d.dateFormat = f
        return d
    }
    private static let diaLargo = formato("EEEE d 'de' MMMM")
    private static let diaMes = formato("d 'de' MMMM")
    private static let corta = formato("d/M")
    private static let hora = formato("HH:mm")
    private static let mesNombre = formato("MMMM")
    private static let mesAnio = formato("MMMM yyyy")
    private static let iso = formato("yyyy-MM-dd")
    private static let mesISO = formato("yyyy-MM")
    private static let mesCorto = formato("MMM")

    /// «Miércoles 25 de noviembre»
    static func encabezado(_ d: Date = Date()) -> String { diaLargo.string(from: d).capitalizedPrimera }
    /// «25 de diciembre»
    static func dia(_ d: Date) -> String { diaMes.string(from: d) }
    /// «25/12»
    static func corta(_ d: Date) -> String { corta.string(from: d) }
    static func hora(_ d: Date) -> String { hora.string(from: d) }
    /// «noviembre»
    static func mes(_ d: Date = Date()) -> String { mesNombre.string(from: d) }
    static func isoDia(_ d: Date) -> String { iso.string(from: d) }
    static func isoMes(_ d: Date) -> String { mesISO.string(from: d) }
    /// «Noviembre 2026» desde «2026-11»
    static func mesDe(_ iso: String) -> String {
        guard let d = mesISO.date(from: iso) else { return iso }
        return mesAnio.string(from: d).capitalizedPrimera
    }
    /// «nov» desde «2026-11»
    static func mesCortoDe(_ iso: String) -> String {
        guard let d = mesISO.date(from: iso) else { return iso }
        return mesCorto.string(from: d).replacingOccurrences(of: ".", with: "")
    }

    /// «hace 5 min», «hace 1 h», «ayer», «el 12/11»
    static func hace(_ d: Date, ahora: Date = Date()) -> String {
        let s = ahora.timeIntervalSince(d)
        if s < 60 { return "recién" }
        if s < 3600 { return "hace \(Int(s / 60)) min" }
        if s < 86400 { return "hace \(Int(s / 3600)) h" }
        if Calendar.current.isDateInYesterday(d) { return "ayer" }
        if s < 6 * 86400 { return "hace \(Int(s / 86400)) días" }
        return "el \(corta(d))"
    }

    /// «el 2/12», «mañana», «hoy»
    static func cuando(_ d: Date) -> String {
        if Calendar.current.isDateInToday(d) { return "hoy" }
        if Calendar.current.isDateInTomorrow(d) { return "mañana" }
        return "el \(corta(d))"
    }

    /// Fecha relativa a hoy: `Fecha.en(dias: -3, horas: 2)`.
    static func en(dias: Int = 0, horas: Double = 0, minutos: Double = 0, desde: Date = Date()) -> Date {
        let base = Calendar.current.date(byAdding: .day, value: dias, to: desde) ?? desde
        return base.addingTimeInterval(horas * 3600 + minutos * 60)
    }

    /// El mismo día del mes que viene (para «Después, $5.000 el 25 de cada mes»).
    static func proximoMes(_ d: Date = Date()) -> Date { Calendar.current.date(byAdding: .month, value: 1, to: d) ?? d }
    static func diaDelMes(_ d: Date = Date()) -> Int { Calendar.current.component(.day, from: d) }
}

extension String {
    var capitalizedPrimera: String { prefix(1).uppercased() + dropFirst() }
    var limpio: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
