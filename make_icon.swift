import Cocoa

// 使い方: swiftc make_icon.swift -o /tmp/make_icon && /tmp/make_icon <出力.iconset のフォルダ>
func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let u = CGFloat(px) / 1024
    // 背景: 角丸の四角(macOS のアイコン枠 824pt)
    let bg = NSBezierPath(roundedRect: NSRect(x: 100*u, y: 100*u, width: 824*u, height: 824*u), xRadius: 185*u, yRadius: 185*u)
    NSGradient(starting: NSColor(white: 1.0, alpha: 1), ending: NSColor(white: 0.88, alpha: 1))!.draw(in: bg, angle: -90)
    // 矢印: 先端を左上に。アプリの矢印と同じ形
    let k = 31 * u
    let ox = 512*u - 6 * k, oy = 512*u + 10 * k      // 矢印(幅12×高さ20)を中央に
    func pt(_ dx: CGFloat, _ dy: CGFloat) -> NSPoint { NSPoint(x: ox + dx * k, y: oy - dy * k) }
    let a = NSBezierPath()
    a.move(to: pt(0, 0)); a.line(to: pt(0, 17)); a.line(to: pt(4, 13)); a.line(to: pt(7.5, 20))
    a.line(to: pt(10, 19)); a.line(to: pt(6.5, 12)); a.line(to: pt(12, 12)); a.close()
    a.lineJoinStyle = .round
    NSColor.systemRed.withAlphaComponent(0.18).setFill(); a.fill()
    NSColor.systemRed.setStroke(); a.lineWidth = 46 * u; a.stroke()
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let dir = CommandLine.arguments[1]
try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
for (name, px) in [("16",16),("16@2x",32),("32",32),("32@2x",64),("128",128),("128@2x",256),("256",256),("256@2x",512),("512",512),("512@2x",1024)] {
    try! render(px).write(to: URL(fileURLWithPath: "\(dir)/icon_\(name.replacingOccurrences(of: "@2x", with: ""))x\(name.replacingOccurrences(of: "@2x", with: ""))\(name.contains("@2x") ? "@2x" : "").png"))
}
