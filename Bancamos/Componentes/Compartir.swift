import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

/// Hoja de compartir del sistema para algo que se genera recién al tocar (un CSV, un QR).
struct ActividadCompartir: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ c: UIActivityViewController, context: Context) {}
}

private struct Paquete: Identifiable { let id = UUID(); let items: [Any] }

/// Botón que arma el archivo al tocarlo y abre «Compartir». Así no se generan archivos en cada dibujo.
struct CompartirBoton<Etiqueta: View>: View {
    let generar: () -> Any
    @ViewBuilder var etiqueta: () -> Etiqueta
    @State private var paquete: Paquete?

    var body: some View {
        Button { Haptico.seleccion(); paquete = Paquete(items: [generar()]) } label: { etiqueta() }
            .buttonStyle(Apretable())
            .sheet(item: $paquete) { p in
                ActividadCompartir(items: p.items).presentationDetents([.medium, .large]).ignoresSafeArea()
            }
    }
}

enum QR {
    /// QR en tinta sobre blanco, con corrección alta (para poner el isotipo en el medio).
    static func imagen(_ texto: String, tamano: CGFloat = 900) -> UIImage? {
        let f = CIFilter.qrCodeGenerator()
        f.message = Data(texto.utf8)
        f.correctionLevel = "H"
        guard let salida = f.outputImage else { return nil }
        let esc = tamano / salida.extent.width
        let color = CIFilter.falseColor()
        color.inputImage = salida.transformed(by: CGAffineTransform(scaleX: esc, y: esc))
        color.color0 = CIColor(red: 17 / 255, green: 20 / 255, blue: 24 / 255)
        color.color1 = CIColor(red: 1, green: 1, blue: 1)
        guard let out = color.outputImage, let cg = CIContext().createCGImage(out, from: out.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}
