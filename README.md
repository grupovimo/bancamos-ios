# Bancamos · iOS

Maqueta navegable de alta fidelidad de la app (SwiftUI, iOS 17+, sólo iPhone y vertical). No tiene backend: todo corre en memoria con los datos del diseño aprobado (`propuestas/apoyo/pantallas/app.html`).

## Generar y compilar

```sh
brew install xcodegen          # una vez
xcodegen generate              # crea Bancamos.xcodeproj (no se versiona)
xcodebuild -project Bancamos.xcodeproj -scheme Bancamos \
  -destination 'platform=iOS Simulator,name=<tu simulador>' CODE_SIGNING_ALLOWED=NO test
```

Tests de humo en Release: sumá `-configuration Release ENABLE_TESTABILITY=YES`. Para ver expresiones lentas (el Xcode de GitHub falla con ellas): `OTHER_SWIFT_FLAGS='-Xfrontend -warn-long-expression-type-checking=1000'`.

Capturas: `./capturar.sh` (o `./capturar.sh inicio cobros`). Quedan en `capturas/`. Para abrir una pantalla directo: argumento `-pantalla <nombre>` (ver `Arranque` en `App/BancamosApp.swift`); el onboarding, con `-pantalla onboarding -paso N -ladoOnb creador|fan`.

## Estructura

- `Bancamos/App`: entrada, `Arranque` (capturas), bienvenida (tres pantallas con la meta que se llena), elección del lado y los pasos del onboarding de cada lado. Al final se elige entre la cuenta nueva (vacía, con «Primeros pasos») o los datos de ejemplo.
- `Bancamos/Nucleo`: modelos, `Perfil` (lo del onboarding, guardado en el teléfono), el protocolo `Datos`, `DatosDeMuestra` y `Estado` (`@Observable`, lo único que leen las pantallas; las acciones del creador en `EstadoCreador`).
- `Bancamos/Tema`: colores (esmeralda), Outfit variable y medidas.
- `Bancamos/Componentes`: tarjetas, la barra de la meta, chips, campos, estados vacío/carga/error, la barra flotante, botones, el ticket «Hoy pagás», las hojas simuladas de Mercado Pago (OAuth y checkout), QR, papelitos y las promos «De Grupo Vimo».
- `Bancamos/Pantallas/Creador`: Inicio · Gente · + · Posteos · Más. Niveles, posteos (texto, fotos con PhotosPicker, audio, programados, quién lo ve), metas (con «¡Meta cumplida!»), apoyos y miembros (ficha, agradecer, CSV), mensajes, avisos, estadísticas (Swift Charts), cobros (comisión, historial, CSV), Mi página (editor por partes, «Así te ven», QR), ajustes (Mercado Pago, datos fiscales, privacidad, avisos), plan y ayuda.
- `Bancamos/Pantallas/Fan`: Explorar · Novedades · Bancás · Perfil. Página del creador, bancar una vez o cada mes, revisá y pagá, checkout, gracias con la meta actualizada, membresía (cambiar de nivel, baja con un toque), recibos.

## Conectar datos reales

1. Escribí otra implementación del protocolo `Datos` (`Nucleo/Datos.swift`), por ejemplo `DatosApi`: lecturas (`panelCreador`, `panelFan`, `creadores`) y cada acción (publicar, agradecer, `apoyar` con `marketplace_fee`, `conectarMercadoPago` por OAuth…).
2. Pasala al crear el estado: en `BancamosApp`, `Estado(datos: DatosApi())`.

Las pantallas no cambian: `Estado` aplica cada acción en memoria al instante y después llama a `datos`.

Regla: nunca `async let` (cierra la app en Release). Las cargas van una detrás de otra.
