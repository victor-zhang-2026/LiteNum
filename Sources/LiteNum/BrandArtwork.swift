import AppKit
import SwiftUI

enum BrandArtwork {
    static let main = NSColor(srgbRed: 180/255, green: 71/255, blue: 59/255, alpha: 1)
    static let light = NSColor(srgbRed: 201/255, green: 95/255, blue: 76/255, alpha: 1)
    static let dark = NSColor(srgbRed: 158/255, green: 56/255, blue: 47/255, alpha: 1)
    // A frame, a distinct reckoning beam, three rods, and asymmetrically placed beads.
    // Every surface and exported SVG uses these same 100-unit primitives.
    static let rods: [CGFloat] = [30, 50, 70]
    static let beads: [(CGFloat, CGFloat)] = [(30, 31), (50, 31), (70, 31), (30, 56), (30, 70), (50, 70), (70, 56), (70, 70)]
    static func mark(in rect: CGRect) {
        NSGraphicsContext.saveGraphicsState()
        let t = NSAffineTransform(); t.translateX(by: rect.minX, yBy: rect.minY); t.scale(by: rect.width / 100); t.concat()
        NSColor.white.setStroke(); NSColor.white.setFill()
        let frame = NSBezierPath(roundedRect: CGRect(x: 14, y: 17, width: 72, height: 66), xRadius: 5, yRadius: 5)
        frame.lineWidth = 4; frame.stroke()
        let beam = NSBezierPath(); beam.lineWidth = 5; beam.lineCapStyle = .round
        beam.move(to: CGPoint(x: 15, y: 44)); beam.line(to: CGPoint(x: 85, y: 44)); beam.stroke()
        let lines = NSBezierPath(); lines.lineWidth = 2.5
        for x in rods { lines.move(to: CGPoint(x: x, y: 19)); lines.line(to: CGPoint(x: x, y: 81)) }; lines.stroke()
        for (x, y) in beads { NSBezierPath(roundedRect: CGRect(x: x - 7, y: y - 4, width: 14, height: 8), xRadius: 4, yRadius: 4).fill() }
        NSGraphicsContext.restoreGraphicsState()
    }
    static func image(size: CGFloat, appIcon: Bool = false, hovering: Bool = false) -> NSImage {
        NSImage(size: CGSize(width: size, height: size), flipped: true) { bounds in
            let outer = bounds.insetBy(dx: size * (appIcon ? 0.07 : 0.0625), dy: size * (appIcon ? 0.07 : 0.0625))
            let shell = appIcon ? NSBezierPath(roundedRect: outer, xRadius: size * 0.19, yRadius: size * 0.19) : NSBezierPath(ovalIn: outer)
            NSGraphicsContext.saveGraphicsState()
            let shadow = NSShadow(); shadow.shadowColor = NSColor.black.withAlphaComponent(0.16)
            shadow.shadowBlurRadius = size * 0.045; shadow.shadowOffset = CGSize(width: 0, height: size * 0.018); shadow.set()
            NSColor.white.setFill(); shell.fill(); NSGraphicsContext.restoreGraphicsState()
            let inset = size * (appIcon ? 0.155 : (hovering ? 0.125 : 7.0/48.0))
            let inner = NSBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
            NSGradient(starting: light, ending: dark)!.draw(in: inner, angle: 90)
            mark(in: bounds.insetBy(dx: size * 0.20, dy: size * 0.20))
            return true
        }
    }
    static var svg: String {
        let rodPaths = rods.map { "<path d=\"M\($0) 19V81\" stroke-width=\"2.5\"/>" }.joined()
        let beadPaths = beads.map { "<rect x=\"\($0.0 - 7)\" y=\"\($0.1 - 4)\" width=\"14\" height=\"8\" rx=\"4\" fill=\"white\" stroke=\"none\"/>" }.joined()
        return """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
        <defs><linearGradient id="red" x2="0" y2="1"><stop stop-color="#C95F4C"/><stop offset="1" stop-color="#9E382F"/></linearGradient></defs>
        <circle cx="50" cy="50" r="44" fill="white"/>
        <circle cx="50" cy="50" r="34" fill="url(#red)"/>
        <g transform="translate(20 20) scale(.6)" fill="none" stroke="white">
        <rect x="14" y="17" width="72" height="66" rx="5" stroke-width="4"/>
        <path d="M15 44H85" stroke-width="5" stroke-linecap="round"/>
        \(rodPaths)\(beadPaths)</g></svg>
        """
    }
    static func export(to directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try svg.write(to: directory.appendingPathComponent("litenum-logo.svg"), atomically: true, encoding: .utf8)
        let iconset = directory.appendingPathComponent("LiteNum.iconset")
        try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
        for size in [16, 32, 128, 256, 512] {
            for scale in [1, 2] {
                let pixels = size * scale
                try png(image: image(size: CGFloat(pixels), appIcon: true), pixels: pixels).write(to: iconset.appendingPathComponent("icon_\(size)x\(size)\(scale == 2 ? "@2x" : "").png"))
            }
        }
        for size in [32, 48, 56] {
            try png(image: image(size: CGFloat(size * 2)), pixels: size * 2).write(to: directory.appendingPathComponent("floating-\(size)@2x.png"))
        }
        try png(image: image(size: 1024, appIcon: true), pixels: 1024).write(to: directory.appendingPathComponent("app-icon-1024.png"))
    }
    static func png(image: NSImage, pixels: Int) throws -> Data {
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        image.draw(in: CGRect(x: 0, y: 0, width: pixels, height: pixels))
        NSGraphicsContext.restoreGraphicsState()
        return bitmap.representation(using: .png, properties: [:])!
    }
}

struct BrandIcon: View {
    let size: CGFloat
    var body: some View { Image(nsImage: BrandArtwork.image(size: size)).frame(width: size, height: size).accessibilityHidden(true) }
}
