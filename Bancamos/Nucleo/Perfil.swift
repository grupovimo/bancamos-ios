import Foundation

/// Lo que se responde en el onboarding. Queda guardado en el teléfono; las fotos van aparte, como archivos.
struct Perfil: Codable, Equatable {
    var lado: Lado
    var nombre: String = ""
    var email: String = ""
    // Creador
    var usuario: String = ""
    var frase: String = ""
    var categorias: [Categoria] = []
    var metaTitulo: String = ""
    var metaMonto: Int = 0
    var niveles: [Nivel] = []
    var mpConectado = false
    // Quien banca
    var intereses: [Categoria] = []
    var siguiendo: [String] = []
    /// Con datos de ejemplo (la maqueta llena) o la cuenta recién hecha (vacía, con los primeros pasos).
    var conEjemplos = false

    var primerNombre: String { nombre.split(separator: " ").first.map(String.init) ?? nombre }

    private static let clave = "perfil"

    static func guardado() -> Perfil? {
        guard let d = UserDefaults.standard.data(forKey: clave) else { return nil }
        return try? JSONDecoder().decode(Perfil.self, from: d)
    }

    func guardar() {
        if let d = try? JSONEncoder().encode(self) { UserDefaults.standard.set(d, forKey: Self.clave) }
    }

    static func borrar() {
        UserDefaults.standard.removeObject(forKey: clave)
        Archivo.borrar("foto.jpg")
        Archivo.borrar("portada.jpg")
    }

    /// Niveles que se sugieren al crear la página (se pueden editar o sacar).
    static let nivelesSugeridos: [Nivel] = [
        Nivel(id: "n1", nombre: "Mate", precio: 2000, descripcion: "Un gracias de corazón y tu nombre en mi página.",
              incluye: ["Tu nombre en mi página"], cupo: nil, miembros: 0),
        Nivel(id: "n2", nombre: "De cerca", precio: 5000, descripcion: "Todo lo de Mate y los posteos para los que me bancan.",
              incluye: ["Todo lo de Mate", "Posteos exclusivos"], cupo: nil, miembros: 0),
        Nivel(id: "n3", nombre: "Del equipo", precio: 12000, descripcion: "Todo lo anterior y algo hecho para vos una vez por año.",
              incluye: ["Todo lo de De cerca", "Algo hecho para vos por año"], cupo: 25, miembros: 0),
    ]
}

/// Archivos chicos de la app (las fotos elegidas en el onboarding y en «Mi página»).
enum Archivo {
    static var carpeta: URL {
        let u = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("Bancamos")
        try? FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
        return u
    }
    static func guardar(_ d: Data, _ nombre: String) { try? d.write(to: carpeta.appendingPathComponent(nombre), options: .atomic) }
    static func leer(_ nombre: String) -> Data? { try? Data(contentsOf: carpeta.appendingPathComponent(nombre)) }
    static func borrar(_ nombre: String) { try? FileManager.default.removeItem(at: carpeta.appendingPathComponent(nombre)) }
}
