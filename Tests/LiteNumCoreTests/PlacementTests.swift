import CoreGraphics
#if !STANDALONE_TESTS
import XCTest
@testable import LiteNumCore
#endif

final class PlacementTests: XCTestCase {
    let main = CGRect(x: 0, y: 30, width: 1440, height: 850)
    let left = CGRect(x: -1920, y: -200, width: 1920, height: 1080)
    func testRestoreUsesSavedDisplayNotPointer() {
        XCTAssertEqual(Placement.screenIndex(window: CGRect(x: -1000, y: 300, width: 48, height: 48), screens: [main, left]), 1)
    }
    func testDragSelectsPointerDisplay() {
        XCTAssertEqual(Placement.screenIndex(window: CGRect(x: -20, y: 300, width: 48, height: 48), screens: [main, left], pointer: CGPoint(x: -10, y: 320)), 1)
    }
    func testRemovedDisplayChoosesNearest() {
        XCTAssertEqual(Placement.screenIndex(window: CGRect(x: 1800, y: 200, width: 48, height: 48), screens: [left, main]), 1)
        XCTAssertNil(Placement.screenIndex(window: .zero, screens: []))
    }
    func testClampAllEdges() {
        for screen in [main, left] {
            for x in [screen.minX - 200, screen.maxX + 200] {
                for y in [screen.minY - 200, screen.maxY + 200] {
                    let result = Placement.clamp(CGRect(x: x, y: y, width: 48, height: 48), to: screen)
                    XCTAssertTrue(screen.contains(result)); XCTAssertEqual(result.size, CGSize(width: 48, height: 48))
                }
            }
        }
    }
    func testPanelAtEveryEdgeAndNegativeOrigins() {
        for screen in [main, left, CGRect(x: 0, y: 900, width: 1280, height: 800)] {
            for x in [screen.minX + 8, screen.maxX - 56] {
                for y in [screen.minY + 8, screen.maxY - 56] {
                    let trigger = CGRect(x: x, y: y, width: 48, height: 48)
                    let result = Placement.panel(trigger: trigger, size: CGSize(width: 280, height: 444), visible: screen)
                    XCTAssertTrue(screen.contains(result)); XCTAssertFalse(result.intersects(trigger))
                }
            }
        }
    }
    func testPanelSideAndGap() {
        let trigger = CGRect(x: 100, y: 500, width: 48, height: 48)
        XCTAssertEqual(Placement.panel(trigger: trigger, size: CGSize(width: 280, height: 444), visible: main).minX, 160)
        let rightTrigger = CGRect(x: 1376, y: 500, width: 48, height: 48)
        XCTAssertEqual(Placement.panel(trigger: rightTrigger, size: CGSize(width: 280, height: 444), visible: main).maxX, 1364)
    }
}
