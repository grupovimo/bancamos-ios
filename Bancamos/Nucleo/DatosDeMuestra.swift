import Foundation

/// Los datos de la maqueta (los del diseño aprobado en propuestas/apoyo/pantallas). Todo en memoria: las
/// escrituras no hacen nada y `Estado` aplica cada cambio al instante.
struct DatosDeMuestra: Datos {
    func panelCreador() async throws -> PanelCreador { Self.panelCreador }
    func panelFan() async throws -> PanelFan { Self.panelFan }
    func creadores() async throws -> [Creador] { Self.creadores }
    func guardarPerfil(_ p: Perfil) async throws {}
    func cerrarSesion() async throws {}
    func guardarCreador(_ c: Creador) async throws {}
    func guardarNivel(_ n: Nivel, creadorId: String) async throws {}
    func guardarMeta(_ m: Meta, creadorId: String) async throws {}
    func publicar(_ p: Posteo) async throws {}
    func borrarPosteo(id: String) async throws {}
    func agradecer(apoyoId: String, texto: String) async throws {}
    func enviarMensaje(conversacionId: String, texto: String) async throws {}
    func conectarMercadoPago() async throws -> CuentaMP {
        try await Task.sleep(for: .seconds(1.2))
        return CuentaMP(conectada: true, email: "ana.mazzei@gmail.com", nombre: "Ana Mazzei", desde: Date())
    }
    func desconectarMercadoPago() async throws {}
    func guardarFiscal(_ f: DatosFiscales) async throws {}
    func guardarPrivacidad(_ p: Privacidad) async throws {}
    func guardarAvisos(_ a: AjustesAvisos) async throws {}
    func apoyar(_ p: PedidoApoyo) async throws -> Recibo {
        try await Task.sleep(for: .seconds(1.4))
        return Recibo(id: UUID().uuidString, numero: "BC-\(Int.random(in: 100_000...999_999))", creadorId: p.creadorId,
                      concepto: p.tipo == .mensual ? "Cuota mensual" : "Bancada", monto: p.monto, fecha: Date(),
                      medio: "Visa •••• 4242", tipo: p.tipo, mensaje: p.mensaje)
    }
    func cambiarNivel(membresiaId: String, nivelId: String) async throws {}
    func cancelar(membresiaId: String) async throws {}
    func seguir(creadorId: String, siguiendo: Bool) async throws {}
    func meGusta(posteoId: String, valor: Bool) async throws {}
}

// MARK: - Creadores

extension DatosDeMuestra {
    static let ana = Creador(
        id: "ana", nombre: "Ana Mazzei", usuario: "anamazzei", frase: "Dibujo un gato por día.", ciudad: "Buenos Aires",
        categoria: .ilustracion, foto: .asset("foto-ilustradora", 0.53, 0.40, zoom: 2.6), portada: .asset("foto-ilustradora", 0.5, 0.42),
        sobreMi: "Ilustro desde chica y hace tres años que dibujo un gato por día. Con lo que me bancan compro materiales, pago la luz del taller y ahora estoy juntando para imprimir mi primer libro: 120 gatos, a todo color.",
        redes: ["instagram.com/anamazzei.gatos"],
        niveles: [
            Nivel(id: "boceto", nombre: "Boceto", precio: 2000, descripcion: "Un fondo de pantalla nuevo cada mes.",
                  incluye: ["Un fondo de pantalla por mes", "Tu nombre en los agradecimientos del libro"], cupo: nil, miembros: 142),
            Nivel(id: "color", nombre: "Color", precio: 5000, descripcion: "Lo de Boceto y el paso a paso de cada dibujo.",
                  incluye: ["Todo lo de Boceto", "El paso a paso de cada dibujo", "Audios del proceso"], cupo: nil, miembros: 151),
            Nivel(id: "original", nombre: "Original", precio: 12000, descripcion: "Todo lo anterior y un dibujo tuyo por año.",
                  incluye: ["Todo lo de Color", "Un dibujo tuyo por año"], cupo: 25, miembros: 19),
        ],
        metas: [
            Meta(id: "libro", titulo: "Imprimir mi primer libro", descripcion: "120 gatos a todo color, en tapa dura. Imprenta de Barracas, 300 ejemplares.",
                 objetivo: 850_000, recaudado: 612_000, creada: Fecha.en(dias: -74)),
            Meta(id: "tableta", titulo: "Una tableta para dibujar", descripcion: "La vieja ya no daba más.", objetivo: 400_000,
                 recaudado: 400_000, creada: Fecha.en(dias: -260), cerrada: true, cumplida: Fecha.en(dias: -190)),
        ],
        posteos: [
            Posteo(id: "a-prog", creadorId: "ana", titulo: "El gato de diciembre", texto: "Un gato con gorro de Papá Noel que no quiere saber nada con el gorro.",
                   tipo: .fotos, fotos: [.asset("foto-ilustradora", 0.3, 0.6, zoom: 1.6)], publico: .todos, fecha: Fecha.en(dias: 3),
                   programado: Fecha.en(dias: 3, horas: 2)),
            Posteo(id: "a1", creadorId: "ana", titulo: "¡Llegamos al 72 % del libro!", texto: "Gracias a todos los que bancan. Ya elegí la imprenta y el papel: ilustración de 150 gramos, para que el color se vea como en el original. Faltan $238.000.",
                   tipo: .texto, publico: .todos, fecha: Fecha.en(dias: -1, horas: -3), meGusta: 214, comentarios: 31),
            Posteo(id: "a2", creadorId: "ana", titulo: "El gato de la tormenta, paso a paso", texto: "Del boceto en lápiz al color final. Abajo, el pincel que usé para la lluvia.",
                   tipo: .fotos, fotos: [.asset("foto-ilustradora", 0.62, 0.62, zoom: 2.2), .asset("foto-ilustradora", 0.45, 0.35, zoom: 1.8), .asset("foto-ilustradora", 0.8, 0.5, zoom: 2.6)],
                   publico: .desde("color"), fecha: Fecha.en(dias: -3), meGusta: 96, comentarios: 12),
            Posteo(id: "a3", creadorId: "ana", titulo: "Cómo elijo los colores", texto: "Un audio corto mientras pinto: por qué casi nunca uso negro.",
                   tipo: .audio, audioSegundos: 252, publico: .desde("color"), fecha: Fecha.en(dias: -6), meGusta: 71, comentarios: 8),
            Posteo(id: "a4", creadorId: "ana", titulo: "Fondo de pantalla de noviembre", texto: "El gato que duerme sobre el teclado. En alta para el teléfono.",
                   tipo: .fotos, fotos: [.asset("foto-ilustradora", 0.7, 0.3, zoom: 2)], publico: .quienesTeBancan, fecha: Fecha.en(dias: -12), meGusta: 188, comentarios: 22),
        ],
        mensuales: 312, bancadas: 1204, destacado: true, distanciaKm: 3.2, montosSugeridos: [1000, 2000, 5000],
        agradecimiento: "¡Gracias por bancarme! Con esto el libro está más cerca.")

    static let tomas = Creador(
        id: "tomas", nombre: "Tomás Ferreyra", usuario: "tomasferreyra", frase: "Canciones de río y de pueblo.", ciudad: "Córdoba",
        categoria: .musica, foto: .asset("foto-musico", 0.57, 0.45, zoom: 2.6), portada: .asset("foto-musico", 0.55, 0.45),
        sobreMi: "Toco la guitarra desde los doce. Estoy grabando mi primer disco en una sala de Alta Córdoba, con amigos y de a poco.",
        redes: ["instagram.com/tomasferreyra.musica"],
        niveles: [
            Nivel(id: "oyente", nombre: "Oyente", precio: 2000, descripcion: "Las maquetas antes que nadie.", incluye: ["Maquetas antes que nadie"], cupo: nil, miembros: 64),
            Nivel(id: "banda", nombre: "Banda", precio: 4000, descripcion: "Lo de Oyente y un vivo por mes, sólo para ustedes.", incluye: ["Todo lo de Oyente", "Un vivo por mes"], cupo: nil, miembros: 28),
            Nivel(id: "productor", nombre: "Productor", precio: 10000, descripcion: "Tu nombre en el disco y una canción a pedido.", incluye: ["Todo lo de Banda", "Tu nombre en el disco"], cupo: 10, miembros: 6),
        ],
        metas: [Meta(id: "disco", titulo: "Grabar el disco", descripcion: "Diez canciones, sala y mezcla.", objetivo: 1_200_000, recaudado: 492_000, creada: Fecha.en(dias: -40))],
        posteos: [
            Posteo(id: "t1", creadorId: "tomas", titulo: "Maqueta de «Río Primero»", texto: "Grabada anoche, con la guitarra criolla y una sola toma.",
                   tipo: .audio, audioSegundos: 200, publico: .quienesTeBancan, fecha: Fecha.en(dias: -2), meGusta: 58, comentarios: 9),
            Posteo(id: "t2", creadorId: "tomas", titulo: "Así quedó la sala", texto: "Paneles hechos a mano con cajas de huevo. Funcionan.",
                   tipo: .fotos, fotos: [.asset("foto-musico", 0.5, 0.5, zoom: 1.4)], publico: .todos, fecha: Fecha.en(dias: -5), meGusta: 112, comentarios: 14),
        ],
        mensuales: 98, bancadas: 410, destacado: true, distanciaKm: 640, femenino: false)

    static let rosa = Creador(
        id: "rosa", nombre: "Rosa Benítez", usuario: "rosabenitez", frase: "Las recetas de la abuela, sin vueltas.", ciudad: "Rosario",
        categoria: .cocina, foto: .asset("foto-cocinera", 0.63, 0.36, zoom: 2.6), portada: .asset("foto-cocinera", 0.5, 0.4),
        sobreMi: "Cocino como me enseñó mi mamá. Mis nietos me armaron el canal y ahora somos muchos.",
        redes: ["youtube.com/@rosacocina"],
        niveles: [
            Nivel(id: "probador", nombre: "Probador", precio: 2000, descripcion: "Una receta completa por semana.", incluye: ["Una receta por semana"], cupo: nil, miembros: 201),
            Nivel(id: "comensal", nombre: "Comensal", precio: 3500, descripcion: "Lo de Probador y un vivo para cocinar juntos.", incluye: ["Todo lo de Probador", "Cocinamos juntos en vivo"], cupo: nil, miembros: 77),
        ],
        metas: [Meta(id: "horno", titulo: "Un horno nuevo para el canal", descripcion: "El mío tiene 30 años.", objetivo: 600_000, recaudado: 348_000, creada: Fecha.en(dias: -30))],
        posteos: [
            Posteo(id: "r1", creadorId: "rosa", titulo: "Ñoquis del 29, la receta completa", texto: "Papa, harina y paciencia. Les dejo las cantidades exactas y el truco del tenedor.",
                   tipo: .texto, publico: .quienesTeBancan, fecha: Fecha.en(dias: -1), meGusta: 301, comentarios: 44),
            Posteo(id: "r2", creadorId: "rosa", titulo: "Amasar sin máquina", texto: "Fotos del paso a paso. La masa tiene que quedar como el lóbulo de la oreja.",
                   tipo: .fotos, fotos: [.asset("foto-cocinera", 0.35, 0.7, zoom: 1.8)], publico: .todos, fecha: Fecha.en(dias: -4), meGusta: 240, comentarios: 31),
        ],
        mensuales: 278, bancadas: 990, destacado: true, distanciaKm: 290)

    static let flor = Creador(
        id: "flor", nombre: "Flor Acosta", usuario: "floracosta", frase: "Yoga para empezar, desde el living.", ciudad: "Mar del Plata",
        categoria: .bienestar, foto: .asset("foto-yoga", 0.63, 0.45, zoom: 2.8), portada: .asset("foto-yoga", 0.6, 0.5),
        sobreMi: "Doy clases de yoga hace ocho años. Acá subo prácticas cortas para hacer en casa, sin experiencia.",
        redes: ["instagram.com/flor.yoga.mdp"],
        niveles: [
            Nivel(id: "respiro", nombre: "Respiro", precio: 2000, descripcion: "Una práctica nueva por semana.", incluye: ["Una práctica por semana"], cupo: nil, miembros: 70),
            Nivel(id: "practica", nombre: "Práctica", precio: 4000, descripcion: "Lo de Respiro y una clase en vivo por mes.", incluye: ["Todo lo de Respiro", "Clase en vivo por mes"], cupo: 40, miembros: 26),
        ],
        metas: [Meta(id: "retiro", titulo: "Un retiro gratis en la playa", descripcion: "Un fin de semana para 20 personas que no pueden pagarlo.", objetivo: 500_000, recaudado: 170_000, creada: Fecha.en(dias: -20))],
        posteos: [
            Posteo(id: "f1", creadorId: "flor", titulo: "20 minutos para la mañana", texto: "Una práctica guiada, con la voz y nada más.",
                   tipo: .audio, audioSegundos: 1210, publico: .desde("practica"), fecha: Fecha.en(dias: -1, horas: -6), meGusta: 49, comentarios: 6),
        ],
        mensuales: 96, bancadas: 260, distanciaKm: 400)

    static let nico = Creador(
        id: "nico", nombre: "Nico Paz", usuario: "nicopaz", frase: "Juego en vivo de noche, con la comunidad.", ciudad: "La Plata",
        categoria: .streaming, foto: .asset("foto-streamer", 0.42, 0.5, zoom: 2.8), portada: .asset("foto-streamer", 0.5, 0.5),
        sobreMi: "Hago stream de lunes a jueves desde las 22. Lo más lindo es el chat.",
        redes: ["twitch.tv/nicopaz"],
        niveles: [
            Nivel(id: "lurker", nombre: "Lurker", precio: 1000, descripcion: "Tu nombre en los créditos del stream.", incluye: ["Créditos del stream"], cupo: nil, miembros: 180),
            Nivel(id: "mod", nombre: "Del chat", precio: 3000, descripcion: "Emotes propios y sorteos.", incluye: ["Todo lo de Lurker", "Emotes y sorteos"], cupo: nil, miembros: 64),
            Nivel(id: "vip", nombre: "VIP", precio: 6000, descripcion: "Jugás conmigo una vez por mes.", incluye: ["Todo lo de Del chat", "Una partida por mes"], cupo: 12, miembros: 12),
        ],
        metas: [Meta(id: "silla", titulo: "Una silla que no me mate la espalda", descripcion: "Después de 600 horas de stream, la espalda pide.", objetivo: 400_000, recaudado: 352_000, creada: Fecha.en(dias: -15))],
        posteos: [
            Posteo(id: "n1", creadorId: "nico", titulo: "Horarios de diciembre", texto: "Lunes a jueves a las 22. El 24 y el 31 no hay stream, obvio.",
                   tipo: .texto, publico: .todos, fecha: Fecha.en(dias: -1, horas: -12), meGusta: 130, comentarios: 27),
        ],
        mensuales: 256, bancadas: 1530, destacado: true, distanciaKm: 52, femenino: false)

    static let sol = Creador(
        id: "sol", nombre: "Sol Medina", usuario: "solmedina", frase: "Crónicas escritas en el colectivo.", ciudad: "Buenos Aires",
        categoria: .escritura, foto: .asset("foto-banca", 0.5, 0.42, zoom: 2.8), portada: .asset("foto-banca", 0.5, 0.45),
        sobreMi: "Escribo en el 152, de Olivos a La Boca. Una crónica por semana sobre la gente que viaja conmigo.",
        redes: ["instagram.com/sol.cronicas"],
        niveles: [
            Nivel(id: "lector", nombre: "Lector", precio: 1500, descripcion: "La crónica de la semana, antes que nadie.", incluye: ["La crónica antes que nadie"], cupo: nil, miembros: 48),
            Nivel(id: "pasajero", nombre: "Pasajero", precio: 3000, descripcion: "Lo de Lector y el fanzine impreso en tu casa.", incluye: ["Todo lo de Lector", "El fanzine en tu casa"], cupo: nil, miembros: 15),
        ],
        metas: [Meta(id: "fanzine", titulo: "Publicar el fanzine", descripcion: "40 páginas, riso, 200 copias.", objetivo: 300_000, recaudado: 66_000, creada: Fecha.en(dias: -10))],
        posteos: [
            Posteo(id: "s1", creadorId: "sol", titulo: "El chofer que silba tangos", texto: "Lo escuché tres paradas antes de animarme a preguntarle cuál era.",
                   tipo: .texto, publico: .quienesTeBancan, fecha: Fecha.en(dias: -2, horas: -4), meGusta: 77, comentarios: 10),
        ],
        mensuales: 63, bancadas: 180, distanciaKm: 6.5)

    static let creadores: [Creador] = [ana, tomas, rosa, flor, nico, sol]
}

// MARK: - Panel de la creadora (Ana)

extension DatosDeMuestra {
    static let apoyos: [Apoyo] = [
        Apoyo(id: "ap1", nombre: "Juliana Ríos", monto: 5000, tipo: .mensual, nivelId: "color", mensaje: "Tu gato de la tormenta es mi fondo de pantalla.", fecha: Fecha.en(minutos: -5)),
        Apoyo(id: "ap2", nombre: "Martín Gómez", monto: 2000, tipo: .unaVez, mensaje: "Para los lápices.", fecha: Fecha.en(horas: -1)),
        Apoyo(id: "ap3", nombre: "Carla Fuentes", monto: 12000, tipo: .mensual, nivelId: "original", mensaje: "Quiero un gato con mi perro, ¿se puede?", fecha: Fecha.en(horas: -3)),
        Apoyo(id: "ap4", nombre: "Anónimo", monto: 10000, tipo: .unaVez, mensaje: "Para el libro. Ojalá salga antes de las fiestas.", fecha: Fecha.en(horas: -6), anonimo: true),
        Apoyo(id: "ap5", nombre: "Pedro Salas", monto: 2000, tipo: .mensual, nivelId: "boceto", mensaje: "", fecha: Fecha.en(horas: -9), agradecido: true),
        Apoyo(id: "ap6", nombre: "Lucía Ferro", monto: 3000, tipo: .unaVez, mensaje: "Le regalé un dibujo tuyo a mi vieja y lloró.", fecha: Fecha.en(dias: -1, horas: -2), agradecido: true),
        Apoyo(id: "ap7", nombre: "Diego Arce", monto: 5000, tipo: .mensual, nivelId: "color", mensaje: "", fecha: Fecha.en(dias: -1, horas: -5)),
        Apoyo(id: "ap8", nombre: "Valentina Sosa", monto: 1000, tipo: .unaVez, mensaje: "Poquito pero con amor.", fecha: Fecha.en(dias: -2), agradecido: true),
        Apoyo(id: "ap9", nombre: "Hernán Ibarra", monto: 5000, tipo: .mensual, nivelId: "color", mensaje: "Gracias por los audios del proceso.", fecha: Fecha.en(dias: -3)),
        Apoyo(id: "ap10", nombre: "Mora Quiroga", monto: 2000, tipo: .mensual, nivelId: "boceto", mensaje: "", fecha: Fecha.en(dias: -4), agradecido: true),
        Apoyo(id: "ap11", nombre: "Ignacio Peña", monto: 20000, tipo: .unaVez, mensaje: "Por los 3 años de gatos. ¡Vamos ese libro!", fecha: Fecha.en(dias: -5), agradecido: true),
        Apoyo(id: "ap12", nombre: "Agustina Vera", monto: 12000, tipo: .mensual, nivelId: "original", mensaje: "", fecha: Fecha.en(dias: -6), agradecido: true),
    ]

    static let miembros: [Miembro] = {
        let base: [(String, String, Int, EstadoMiembro, Int)] = [
            ("Juliana Ríos", "color", 14, .alDia, 0), ("Carla Fuentes", "original", 9, .alDia, 0), ("Pedro Salas", "boceto", 22, .alDia, 0),
            ("Diego Arce", "color", 3, .alDia, 0), ("Hernán Ibarra", "color", 11, .alDia, 0), ("Mora Quiroga", "boceto", 6, .alDia, 0),
            ("Agustina Vera", "original", 18, .alDia, 0), ("Tomás Ledesma", "color", 2, .porVencer, 2), ("Paula Medina", "boceto", 5, .porVencer, 1),
            ("Federico Gil", "color", 8, .vencido, -3), ("Camila Ortiz", "original", 12, .alDia, 0), ("Joaquín Ruiz", "boceto", 1, .alDia, 0),
            ("Sofía Paredes", "color", 16, .alDia, 0), ("Bruno Castro", "boceto", 4, .baja, 0), ("Elena Ramos", "color", 7, .alDia, 0),
            ("Martín Gómez", "color", 2, .alDia, 0),
        ]
        let precio = ["boceto": 2000, "color": 5000, "original": 12000]
        return base.enumerated().map { i, b in
            let desde = Fecha.en(dias: -30 * b.2 - i)
            let prox = b.3 == .porVencer || b.3 == .vencido ? Fecha.en(dias: b.4) : Fecha.en(dias: 3 + i % 25)
            let email = Texto.usuario(b.0.replacingOccurrences(of: " ", with: ".")) + "@gmail.com"
            return Miembro(id: "m\(i + 1)", nombre: b.0, email: email, nivelId: b.1, desde: desde, proximoPago: prox,
                           estado: b.3, aportado: (precio[b.1] ?? 0) * b.2, nota: i == 1 ? "Quiere un gato con su perro (Tango, salchicha)." : "")
        }
    }()

    static let conversaciones: [Conversacion] = [
        Conversacion(id: "c1", nombre: "Carla Fuentes", nivel: "Original", mensajes: [
            Mensaje(id: "c1a", deMi: false, texto: "¡Hola Ana! Me sumé a Original por el dibujo del año.", fecha: Fecha.en(horas: -4)),
            Mensaje(id: "c1b", deMi: false, texto: "Quiero un gato con mi perro, ¿se puede? Se llama Tango y es salchicha.", fecha: Fecha.en(horas: -3)),
        ], noLeidos: 2),
        Conversacion(id: "c2", nombre: "Juliana Ríos", nivel: "Color", mensajes: [
            Mensaje(id: "c2a", deMi: true, texto: "¡Gracias Juli! Me alegra que te guste.", fecha: Fecha.en(dias: -1)),
            Mensaje(id: "c2b", deMi: false, texto: "¿Vas a vender el original del gato de la tormenta?", fecha: Fecha.en(horas: -20)),
        ], noLeidos: 1),
        Conversacion(id: "c3", nombre: "Hernán Ibarra", nivel: "Color", mensajes: [
            Mensaje(id: "c3a", deMi: false, texto: "Los audios del proceso son lo mejor.", fecha: Fecha.en(dias: -3)),
            Mensaje(id: "c3b", deMi: true, texto: "¡Gracias! Este mes viene uno largo.", fecha: Fecha.en(dias: -3, horas: 2)),
        ], noLeidos: 0),
        Conversacion(id: "c4", nombre: "Agustina Vera", nivel: "Original", mensajes: [
            Mensaje(id: "c4a", deMi: false, texto: "¿Cuándo sale el libro? Quiero regalarlo para Navidad.", fecha: Fecha.en(dias: -6)),
            Mensaje(id: "c4b", deMi: true, texto: "Si llegamos a la meta este mes, sale a mediados de diciembre.", fecha: Fecha.en(dias: -6, horas: 1)),
        ], noLeidos: 0),
    ]

    static let acreditaciones: [Acreditacion] = {
        let nombres = ["Juliana Ríos", "Martín Gómez", "Carla Fuentes", "Anónimo", "Pedro Salas", "Lucía Ferro", "Diego Arce", "Valentina Sosa",
                       "Hernán Ibarra", "Mora Quiroga", "Ignacio Peña", "Agustina Vera", "Sofía Paredes", "Elena Ramos", "Camila Ortiz",
                       "Joaquín Ruiz", "Tomás Ledesma", "Paula Medina", "Ramiro Lagos", "Inés Ponce", "Gabriel Soto", "Bianca Luna"]
        let montos = [5000, 2000, 12000, 10000, 2000, 3000, 5000, 1000, 5000, 2000, 20000, 12000, 5000, 5000, 12000, 2000, 5000, 2000, 3000, 5000, 2000, 12000]
        let horas: [Double] = [0.1, 1, 3, 6, 9, 26, 29, 48, 72, 96, 120, 144, 160, 170, 190, 210, 260, 300, 340, 380, 420, 470]
        return nombres.indices.map { i in
            Acreditacion(id: "ac\(i)", fecha: Date().addingTimeInterval(-horas[i] * 3600), nombre: nombres[i],
                         tipo: [1, 3, 5, 7, 10, 18].contains(i) ? .unaVez : .mensual, bruto: montos[i], operacionMP: "\(13_802_411_000 + i * 7919)")
        }
    }()

    static let meses: [MesCobros] = {
        let hoy = Date()
        let brutos = [780_000, 920_000, 1_050_000, 1_190_000, 1_312_000, 1_486_000]
        let miembros = [180, 205, 232, 266, 290, 312]
        let apoyos = [41, 47, 52, 55, 60, 64]
        return (0..<6).map { i in
            let d = Calendar.current.date(byAdding: .month, value: i - 5, to: hoy) ?? hoy
            return MesCobros(mes: Fecha.isoMes(d), bruto: brutos[i], apoyos: apoyos[i], miembros: miembros[i],
                             facturaBancamos: i == 5 ? nil : "C 0001-000\(1200 + i)")
        }
    }()

    static let notificaciones: [Notificacion] = [
        Notificacion(id: "no1", tipo: .apoyo, titulo: "Juliana te banca cada mes", texto: "$5.000 en Color. «Tu gato de la tormenta es mi fondo de pantalla.»", fecha: Fecha.en(minutos: -5)),
        Notificacion(id: "no2", tipo: .apoyo, titulo: "Martín te bancó $2.000", texto: "«Para los lápices.»", fecha: Fecha.en(horas: -1)),
        Notificacion(id: "no3", tipo: .mensaje, titulo: "Carla te escribió", texto: "Quiero un gato con mi perro, ¿se puede?", fecha: Fecha.en(horas: -3)),
        Notificacion(id: "no4", tipo: .meta, titulo: "Pasaste el 70 % del libro", texto: "Faltan $238.000. Contale a tu gente cómo viene.", fecha: Fecha.en(dias: -1), leida: true),
        Notificacion(id: "no5", tipo: .baja, titulo: "Bruno se dio de baja", texto: "Estaba en Boceto hace 4 meses.", fecha: Fecha.en(dias: -2), leida: true),
        Notificacion(id: "no6", tipo: .cobro, titulo: "Federico no pudo pagar", texto: "Le avisamos para que pague con otro medio.", fecha: Fecha.en(dias: -3), leida: true),
        Notificacion(id: "no7", tipo: .sistema, titulo: "Tu factura de octubre", texto: "La factura de Bancamos por el 3 % ya está en Cobros.", fecha: Fecha.en(dias: -24), leida: true),
    ]

    static let visitas: [Punto] = {
        let v = [310, 280, 402, 520, 470, 610, 580, 640, 700, 690, 820, 760, 880, 940]
        return v.enumerated().map { i, x in Punto(etiqueta: Fecha.corta(Fecha.en(dias: i - 13)), valor: x) }
    }()

    static var panelCreador: PanelCreador {
        PanelCreador(yo: ana, apoyos: apoyos, miembros: miembros, conversaciones: conversaciones, acreditaciones: acreditaciones,
                     meses: meses, notificaciones: notificaciones,
                     cuentaMP: CuentaMP(conectada: true, email: "ana.mazzei@gmail.com", nombre: "Ana Mazzei", desde: Fecha.en(dias: -400)),
                     fiscal: DatosFiscales(condicion: .monotributo, cuit: "27-34567890-4", razonSocial: "Ana Mazzei", domicilio: "Av. Montes de Oca 1120, CABA"),
                     privacidad: Privacidad(), avisos: AjustesAvisos(), visitas: visitas, email: "ana.mazzei@gmail.com")
    }

    /// La cuenta recién creada desde el onboarding: sin apoyos ni miembros, con los primeros pasos.
    static func panelNuevo(_ p: Perfil) -> PanelCreador {
        var c = ana
        c.id = "yo"
        c.nombre = p.nombre.isEmpty ? "Tu nombre" : p.nombre
        c.usuario = p.usuario.isEmpty ? Texto.usuario(c.nombre.replacingOccurrences(of: " ", with: "")) : p.usuario
        c.frase = p.frase
        c.categoria = p.categorias.first ?? .ilustracion
        c.foto = Archivo.leer("foto.jpg").map { Imagen(datos: $0, fx: 0.5, fy: 0.5, zoom: 1) } ?? .vacia
        c.portada = Archivo.leer("portada.jpg").map { Imagen(datos: $0, fx: 0.5, fy: 0.5, zoom: 1) } ?? .vacia
        c.sobreMi = ""
        c.redes = []
        c.niveles = p.niveles
        c.metas = p.metaTitulo.isEmpty ? [] : [Meta(id: "m1", titulo: p.metaTitulo, descripcion: "", objetivo: p.metaMonto, recaudado: 0, creada: Date())]
        c.posteos = []
        c.mensuales = 0
        c.bancadas = 0
        c.destacado = false
        let hoy = Fecha.isoMes(Date())
        return PanelCreador(yo: c, apoyos: [], miembros: [], conversaciones: [], acreditaciones: [],
                            meses: [MesCobros(mes: hoy, bruto: 0, apoyos: 0, miembros: 0)],
                            notificaciones: [Notificacion(id: "bienvenida", tipo: .sistema, titulo: "Tu página ya está en línea",
                                                          texto: "Compartí \(c.link) para que te empiecen a bancar.", fecha: Date())],
                            cuentaMP: CuentaMP(conectada: p.mpConectado, email: p.mpConectado ? (p.email.isEmpty ? "tu cuenta" : p.email) : "",
                                               nombre: c.nombre, desde: p.mpConectado ? Date() : nil),
                            fiscal: DatosFiscales(condicion: .ninguna, cuit: "", razonSocial: c.nombre, domicilio: ""),
                            privacidad: Privacidad(), avisos: AjustesAvisos(),
                            visitas: (0..<14).map { Punto(etiqueta: Fecha.corta(Fecha.en(dias: $0 - 13)), valor: 0) }, email: p.email)
    }
}

// MARK: - Quien banca (Martín)

extension DatosDeMuestra {
    static let panelFan = PanelFan(
        nombre: "Martín Gómez", email: "martin.gomez@gmail.com",
        membresias: [
            Membresia(id: "mb1", creadorId: "ana", nivelId: "color", monto: 5000, desde: Fecha.en(dias: -62), proximoPago: Fecha.proximoMes(), estado: .alDia),
            Membresia(id: "mb2", creadorId: "tomas", nivelId: "oyente", monto: 2000, desde: Fecha.en(dias: -150), proximoPago: Fecha.en(dias: 7), estado: .porPagar),
            Membresia(id: "mb3", creadorId: "rosa", nivelId: "probador", monto: 2000, desde: Fecha.en(dias: -300), proximoPago: Fecha.en(dias: 18), estado: .alDia),
        ],
        recibos: [
            Recibo(id: "rc1", numero: "BC-418230", creadorId: "ana", concepto: "Bancada", monto: 2000, fecha: Fecha.en(horas: -1), medio: "Visa •••• 4242", tipo: .unaVez, mensaje: "Para los lápices."),
            Recibo(id: "rc2", numero: "BC-417702", creadorId: "ana", concepto: "Cuota mensual · Color", monto: 5000, fecha: Fecha.en(dias: -1), medio: "Dinero en Mercado Pago", tipo: .mensual),
            Recibo(id: "rc3", numero: "BC-401199", creadorId: "rosa", concepto: "Cuota mensual · Probador", monto: 2000, fecha: Fecha.en(dias: -12), medio: "Visa •••• 4242", tipo: .mensual),
            Recibo(id: "rc4", numero: "BC-392410", creadorId: "tomas", concepto: "Cuota mensual · Oyente", monto: 2000, fecha: Fecha.en(dias: -23), medio: "Visa •••• 4242", tipo: .mensual),
            Recibo(id: "rc5", numero: "BC-377001", creadorId: "nico", concepto: "Bancada", monto: 3000, fecha: Fecha.en(dias: -28), medio: "Dinero en Mercado Pago", tipo: .unaVez, mensaje: "Por el stream del sábado."),
            Recibo(id: "rc6", numero: "BC-361548", creadorId: "ana", concepto: "Cuota mensual · Color", monto: 5000, fecha: Fecha.en(dias: -31), medio: "Visa •••• 4242", tipo: .mensual),
        ],
        siguiendo: ["ana", "tomas", "rosa", "nico"], intereses: [.ilustracion, .musica, .cocina], avisos: AjustesAvisos(), medio: "Visa •••• 4242")

    static func fanNuevo(_ p: Perfil) -> PanelFan {
        PanelFan(nombre: p.nombre.isEmpty ? "Vos" : p.nombre, email: p.email, membresias: [], recibos: [],
                 siguiendo: p.siguiendo, intereses: p.intereses, avisos: AjustesAvisos(), medio: "")
    }

    static let perfilCreador = Perfil(lado: .creador, nombre: "Ana Mazzei", email: "ana.mazzei@gmail.com", usuario: "anamazzei",
                                      frase: "Dibujo un gato por día.", categorias: [.ilustracion], metaTitulo: "Imprimir mi primer libro",
                                      metaMonto: 850_000, niveles: ana.niveles, mpConectado: true, conEjemplos: true)
    static let perfilFan = Perfil(lado: .fan, nombre: "Martín Gómez", email: "martin.gomez@gmail.com",
                                  intereses: [.ilustracion, .musica, .cocina], siguiendo: ["ana", "tomas", "rosa", "nico"], conEjemplos: true)
}
