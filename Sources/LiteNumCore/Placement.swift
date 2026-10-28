import Foundation
import CoreGraphics

public enum Placement {
    public static func screenIndex(window: CGRect, screens: [CGRect], pointer: CGPoint? = nil) -> Int? {
        guard !screens.isEmpty else { return nil }
        if let pointer, let index = screens.firstIndex(where: { $0.contains(pointer) }) { return index }
        let areas = screens.map { frame -> CGFloat in
            let rect = frame.intersection(window)
            return rect.isNull ? 0 : rect.width * rect.height
        }
        if let largest = areas.max(), largest > 0 { return areas.firstIndex(of: largest) }
        return screens.indices.min { distance(window, screens[$0]) < distance(window, screens[$1]) }
    }
    private static func distance(_ window: CGRect, _ screen: CGRect) -> CGFloat {
        let dx = max(screen.minX - window.midX, 0, window.midX - screen.maxX)
        let dy = max(screen.minY - window.midY, 0, window.midY - screen.maxY)
        return dx * dx + dy * dy
    }
    public static func clamp(_ rect: CGRect, to screen: CGRect, margin: CGFloat = 8) -> CGRect {
        let safe = screen.insetBy(dx: margin, dy: margin)
        return CGRect(x: min(max(rect.minX, safe.minX), max(safe.minX, safe.maxX - rect.width)),
                      y: min(max(rect.minY, safe.minY), max(safe.minY, safe.maxY - rect.height)),
                      width: rect.width, height: rect.height)
    }
    public static func panel(trigger: CGRect, size: CGSize, visible: CGRect) -> CGRect {
        let gap: CGFloat = 12
        let right = trigger.maxX + gap
        let left = trigger.minX - gap - size.width
        let x = right + size.width <= visible.maxX - 8 ? right : left
        return clamp(CGRect(x: x, y: trigger.maxY - size.height, width: size.width, height: size.height), to: visible)
    }
}
