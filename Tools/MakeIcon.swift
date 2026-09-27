// Generates AppIcon.iconset (run by build.sh, then fed to iconutil).
// Keeps the project dependency-free: no binary assets checked in.
import AppKit

let outputDirectory = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true)

func render(pixels: Int) -> Data? {
    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                     pixelsWide: pixels, pixelsHigh: pixels,
                                     bitsPerSample: 8, samplesPerPixel: 4,
                                     hasAlpha: true, isPlanar: false,
                                     colorSpaceName: .deviceRGB,
                                     bytesPerRow: 0, bitsPerPixel: 0),
          let context = NSGraphicsContext(bitmapImageRep: rep) else { return nil }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let side = CGFloat(pixels)
    let inset = side * 0.055
    let plate = NSRect(x: inset, y: inset, width: side - inset * 2, height: side - inset * 2)
    let squircle = NSBezierPath(roundedRect: plate,
                                xRadius: plate.width * 0.2237,
                                yRadius: plate.width * 0.2237)

    NSGradient(colors: [NSColor(srgbRed: 0.40, green: 0.33, blue: 0.96, alpha: 1),
                        NSColor(srgbRed: 0.24, green: 0.58, blue: 0.99, alpha: 1)])?
        .draw(in: squircle, angle: -62)

    // Markdown mark: heavy "M" with a downward triangle beside it.
    let glyph = NSAttributedString(string: "M", attributes: [
        .font: NSFont.systemFont(ofSize: side * 0.44, weight: .black),
        .foregroundColor: NSColor.white
    ])
    let glyphSize = glyph.size()
    glyph.draw(at: NSPoint(x: side * 0.395 - glyphSize.width / 2,
                           y: side * 0.5 - glyphSize.height / 2))

    let triangleWidth = side * 0.19
    let triangleHeight = side * 0.155
    let centerX = side * 0.665
    let centerY = side * 0.5
    let triangle = NSBezierPath()
    triangle.move(to: NSPoint(x: centerX - triangleWidth / 2, y: centerY + triangleHeight / 2))
    triangle.line(to: NSPoint(x: centerX + triangleWidth / 2, y: centerY + triangleHeight / 2))
    triangle.line(to: NSPoint(x: centerX, y: centerY - triangleHeight / 2))
    triangle.close()
    NSColor.white.setFill()
    triangle.fill()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

let variants: [(name: String, pixels: Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024)
]

for variant in variants {
    guard let data = render(pixels: variant.pixels) else {
        FileHandle.standardError.write(Data("failed to render \(variant.name)\n".utf8))
        exit(1)
    }
    let path = (outputDirectory as NSString).appendingPathComponent("\(variant.name).png")
    try data.write(to: URL(fileURLWithPath: path))
}

print("wrote \(variants.count) icon sizes to \(outputDirectory)")
