// Generates AppIcon.icns for Hidecons.
// Called by install.sh — do not run directly.
import AppKit

func makeIcon(size: Int) -> Data? {
    let s = CGFloat(size)
    guard let cs = CGColorSpace(name: CGColorSpace.sRGB),
          let ctx = CGContext(
              data: nil, width: size, height: size,
              bitsPerComponent: 8, bytesPerRow: 0, space: cs,
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
          )
    else { return nil }

    // Rounded-rect background — macOS system blue
    let corner = s * 0.22
    ctx.setFillColor(CGColor(srgbRed: 0.10, green: 0.41, blue: 0.95, alpha: 1.0))
    ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: s, height: s),
                       cornerWidth: corner, cornerHeight: corner, transform: nil))
    ctx.fillPath()

    // 2×2 white rounded squares
    let pad  = s * 0.175
    let gap  = s * 0.085
    let cell = (s - 2 * pad - gap) / 2
    let cr   = cell * 0.20
    ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.93))
    for col in 0..<2 {
        for row in 0..<2 {
            let x = pad + CGFloat(col) * (cell + gap)
            let y = pad + CGFloat(row) * (cell + gap)
            ctx.addPath(CGPath(roundedRect: CGRect(x: x, y: y, width: cell, height: cell),
                               cornerWidth: cr, cornerHeight: cr, transform: nil))
        }
    }
    ctx.fillPath()

    guard let cgImage = ctx.makeImage() else { return nil }
    let ns = NSImage(cgImage: cgImage, size: NSSize(width: s, height: s))
    guard let tiff = ns.tiffRepresentation,
          let rep  = NSBitmapImageRep(data: tiff) else { return nil }
    return rep.representation(using: .png, properties: [:])
}

let iconset = "/tmp/AppIcon.iconset"
try? FileManager.default.removeItem(atPath: iconset)
try? FileManager.default.createDirectory(atPath: iconset, withIntermediateDirectories: true)

let specs: [(Int, String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

for (size, name) in specs {
    if let data = makeIcon(size: size) {
        try? data.write(to: URL(fileURLWithPath: "\(iconset)/\(name)"))
    }
}
