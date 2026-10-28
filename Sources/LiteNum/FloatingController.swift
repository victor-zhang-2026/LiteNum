import AppKit
import SwiftUI
import LiteNumCore

final class BallPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
final class InputPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class FloatingController: NSObject {
    let ball: BallPanel
    let panel: InputPanel
    let model = CalculatorModel()
    private let defaults = UserDefaults.standard
    private var keyboardMonitor: Any?
    private var mouseMonitor: Any?
    private var outsideMouseMonitor: Any?
    private var closeWork: DispatchWorkItem?
    private var closeGeneration: UInt = 0
    private var isDragging = false
    private var suppressHover = false
    private var previousApplication: NSRunningApplication?
    private(set) var isOpen = false
    private(set) var isPinned = false
    private let panelSize = CGSize(width: 280, height: 444)

    override init() {
        ball = BallPanel(contentRect: CGRect(x: 0, y: 0, width: 48, height: 48), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel = InputPanel(contentRect: CGRect(origin: .zero, size: CGSize(width: 280, height: 444)), styleMask: [.borderless], backing: .buffered, defer: false)
        super.init()
        for window in [ball, panel] {
            window.isOpaque = false; window.backgroundColor = .clear
            window.isReleasedWhenClosed = false; window.hidesOnDeactivate = false
            window.level = .floating; window.animationBehavior = .none
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.appearance = NSAppearance(named: .aqua)
        }
        ball.title = "LiteNum 悬浮球"; panel.title = "LiteNum 计算器"
        ball.hasShadow = false; panel.hasShadow = true
        ball.becomesKeyOnlyIfNeeded = true
        let trigger = BallView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        trigger.controller = self; ball.contentView = trigger
        let hosting = PanelHostingView(rootView: CalculatorView(model: model, onClose: { [weak self] in self?.close() }, onInput: { [weak self] key in self?.input(key) }))
        hosting.onHover = { [weak self] inside in inside ? self?.cancelClose() : self?.scheduleClose() }
        panel.contentView = hosting
        keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.isOpen, self.isPinned, self.panel.isKeyWindow, event.window === self.panel else { return event }
            let modified = !event.modifierFlags.intersection([.command, .control, .option]).isEmpty
            guard let key = CalculatorKey.map(code: event.keyCode, characters: event.characters ?? "", modified: modified) else { return event }
            self.input(key); return nil
        }
        mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let self {
                if event.window === self.panel { self.pin() }
                else if event.window !== self.ball { self.dismissIfOutside(NSEvent.mouseLocation) }
            }
            return event
        }
        outsideMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] _ in
            self?.dismissIfOutside(NSEvent.mouseLocation)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(screensChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        restorePosition(); ball.orderFrontRegardless()
    }
    deinit {
        for monitor in [keyboardMonitor, mouseMonitor, outsideMouseMonitor].compactMap({ $0 }) { NSEvent.removeMonitor(monitor) }
        closeWork?.cancel(); NotificationCenter.default.removeObserver(self)
    }

    func toggle() { open() }
    /// Hover and trigger click show a preview without taking keyboard focus.
    func open() {
        cancelClose()
        guard !isDragging, !suppressHover, !isOpen else { return }
        isOpen = true; positionPanel()
        panel.orderFrontRegardless(); ball.orderFrontRegardless()
    }
    func pin() {
        guard isOpen else { return }
        cancelClose()
        if !isPinned { previousApplication = NSWorkspace.shared.frontmostApplication }
        isPinned = true
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil); panel.makeFirstResponder(panel.contentView)
        ball.orderFrontRegardless()
    }
    func close(explicit: Bool = true) {
        cancelClose()
        guard isOpen else { return }
        let restore = panel.isKeyWindow && NSApp.isActive
        isOpen = false; isPinned = false; panel.orderOut(nil)
        if explicit { suppressHover = ball.frame.contains(NSEvent.mouseLocation) }
        if restore, let previousApplication, previousApplication.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            previousApplication.activate(options: [])
        }
        previousApplication = nil
    }
    func triggerEntered() { cancelClose(); open() }
    private func dismissIfOutside(_ point: CGPoint) {
        // Geometric exclusions also cover AppKit paths that report a trigger click globally.
        guard isOpen, !isDragging, !ball.frame.contains(point), !panel.frame.contains(point) else { return }
        close()
    }
    func triggerExited() { suppressHover = false; scheduleClose() }
    func cancelClose() { closeGeneration &+= 1; closeWork?.cancel(); closeWork = nil }
    func scheduleClose() {
        cancelClose()
        guard isOpen, !isPinned, !isDragging else { return }
        let generation = closeGeneration
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.closeGeneration == generation, self.isOpen, !self.isPinned, !self.isDragging else { return }
            let pointer = NSEvent.mouseLocation
            guard !self.ball.frame.contains(pointer), !self.panel.frame.contains(pointer) else { return }
            self.close(explicit: false)
        }
        closeWork = work
        // Same grace interval as LiteCal: enough to cross the ball-to-panel gap.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
    }
    func beginDrag() {
        cancelClose(); isDragging = true
        if !isPinned { close(explicit: false) }
    }
    func endDrag() { isDragging = false; savePosition(); if isOpen { positionPanel() } }
    func input(_ key: CalculatorKey) {
        if key == .close { close(); return }
        model.send(key)
        panel.makeFirstResponder(panel.contentView)
    }
    private func currentScreen(pointer: CGPoint? = nil) -> NSScreen? {
        let screens = NSScreen.screens
        return Placement.screenIndex(window: ball.frame, screens: screens.map(\.frame), pointer: pointer).map { screens[$0] }
    }
    private func restorePosition() {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        let point: CGPoint
        if defaults.object(forKey: "ballX") != nil, defaults.object(forKey: "ballY") != nil {
            let x = defaults.double(forKey: "ballX"), y = defaults.double(forKey: "ballY")
            point = x.isFinite && y.isFinite ? CGPoint(x: x, y: y) : CGPoint(x: screen.visibleFrame.maxX - 56, y: screen.visibleFrame.midY)
        } else { point = CGPoint(x: screen.visibleFrame.maxX - 56, y: screen.visibleFrame.midY - 24) }
        ball.setFrameOrigin(point)
        if let target = currentScreen() { ball.setFrame(Placement.clamp(ball.frame, to: target.visibleFrame), display: true) }
    }
    private func positionPanel() {
        guard let screen = currentScreen() else { return }
        panel.setFrame(Placement.panel(trigger: ball.frame, size: panelSize, visible: screen.visibleFrame), display: true)
    }
    func drag(to origin: CGPoint, pointer: CGPoint, ended: Bool) {
        ball.setFrameOrigin(origin)
        if let screen = currentScreen(pointer: pointer) { ball.setFrame(Placement.clamp(ball.frame, to: screen.visibleFrame), display: true) }
        if isOpen { positionPanel() }
        if ended { savePosition() }
    }
    func savePosition() {
        defaults.set(ball.frame.minX, forKey: "ballX"); defaults.set(ball.frame.minY, forKey: "ballY")
    }
    @objc private func screensChanged() {
        if let screen = currentScreen() { ball.setFrame(Placement.clamp(ball.frame, to: screen.visibleFrame), display: true) }
        if isOpen { positionPanel() }; savePosition(); ball.orderFrontRegardless()
    }
    func menu() -> NSMenu {
        let menu = NSMenu()
        let quit = NSMenuItem(title: "退出 LiteNum", action: #selector(quit), keyEquivalent: "q")
        quit.target = self; menu.addItem(quit); return menu
    }
    @objc private func quit() { savePosition(); NSApp.terminate(nil) }
}

final class BallView: NSView {
    weak var controller: FloatingController?
    private var hovering = false
    private var startMouse: CGPoint?
    private var startOrigin: CGPoint?
    private var dragged = false
    private var tracking: NSTrackingArea?
    override var isOpaque: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override init(frame: NSRect) {
        super.init(frame: frame)
        setAccessibilityElement(true); setAccessibilityRole(.button)
        setAccessibilityLabel("LiteNum 悬浮球"); setAccessibilityHelp("移入展开，点击面板固定并输入，拖动调整位置，右键退出")
        toolTip = "移入展开 · 点击面板固定 · 拖动调整位置 · 右键退出"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func accessibilityPerformPress() -> Bool { controller?.toggle(); return true }
    override func draw(_ dirtyRect: NSRect) { BrandArtwork.image(size: 48, hovering: hovering).draw(in: bounds) }
    override func updateTrackingAreas() {
        super.updateTrackingAreas(); if let tracking { removeTrackingArea(tracking) }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self)
        addTrackingArea(area); tracking = area
    }
    override func mouseEntered(with event: NSEvent) { hovering = true; needsDisplay = true; controller?.triggerEntered() }
    override func mouseExited(with event: NSEvent) { hovering = false; needsDisplay = true; controller?.triggerExited() }
    override func mouseDown(with event: NSEvent) { startMouse = NSEvent.mouseLocation; startOrigin = window?.frame.origin; dragged = false }
    override func mouseDragged(with event: NSEvent) {
        guard let startMouse, let startOrigin else { return }
        let pointer = NSEvent.mouseLocation
        let dx = pointer.x - startMouse.x, dy = pointer.y - startMouse.y
        if !dragged && hypot(dx, dy) > 3 { dragged = true; controller?.beginDrag() }
        if dragged { controller?.drag(to: CGPoint(x: startOrigin.x + dx, y: startOrigin.y + dy), pointer: pointer, ended: false) }
    }
    override func mouseUp(with event: NSEvent) {
        if dragged { controller?.endDrag() }
        else { controller?.toggle() }
        startMouse = nil; startOrigin = nil; dragged = false
    }
    override func rightMouseDown(with event: NSEvent) {
        if let menu = controller?.menu() { NSMenu.popUpContextMenu(menu, with: event, for: self) }
    }
}

final class PanelHostingView: NSHostingView<CalculatorView> {
    var onHover: ((Bool) -> Void)?
    private var tracking: NSTrackingArea?
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func updateTrackingAreas() {
        super.updateTrackingAreas(); if let tracking { removeTrackingArea(tracking) }
        let area = NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self)
        addTrackingArea(area); tracking = area
    }
    override func mouseEntered(with event: NSEvent) { onHover?(true) }
    override func mouseExited(with event: NSEvent) { onHover?(false) }
}
