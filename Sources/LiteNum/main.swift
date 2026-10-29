import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: FloatingController?
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let root = NSMenu(); let item = NSMenuItem(); let menu = NSMenu()
        menu.addItem(withTitle: "退出 LiteNum", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.submenu = menu; root.addItem(item); NSApp.mainMenu = root
        controller = FloatingController()
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        controller?.ball.orderFrontRegardless()
        return false
    }
}

if CommandLine.arguments.count == 3 && CommandLine.arguments[1] == "--export-artwork" {
    _ = NSApplication.shared
    do { try BrandArtwork.export(to: URL(fileURLWithPath: CommandLine.arguments[2])); exit(0) }
    catch { fputs("Artwork export failed: \(error)\n", stderr); exit(1) }
}
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
