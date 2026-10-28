import Foundation

class XCTestCase {}
var failures = 0
var checks = 0
func XCTAssertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    checks += 1
    if actual != expected { failures += 1; print("FAIL \(file):\(line) \(message): \(actual) != \(expected)") }
}
func XCTAssertTrue(_ value: Bool, file: StaticString = #filePath, line: UInt = #line) { XCTAssertEqual(value, true, file: file, line: line) }
func XCTAssertFalse(_ value: Bool, file: StaticString = #filePath, line: UInt = #line) { XCTAssertEqual(value, false, file: file, line: line) }
func XCTAssertNil<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) { XCTAssertTrue(value == nil, file: file, line: line) }
func XCTAssertNotNil<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) { XCTAssertTrue(value != nil, file: file, line: line) }

@main struct Runner {
    static func main() {
        let c = CalculatorTests(), p = PlacementTests()
        let cases: [(String, () -> Void)] = [
            ("Requested examples", c.testRequestedExamples),
            ("Four operations", c.testAllOperations),
            ("Sequential calculation", c.testSequentialNotPrecedence),
            ("Operator replacement", c.testOperatorReplacement),
            ("Decimal input", c.testDecimalAndLeadingZeros),
            ("Continue result", c.testContinueResultAndNewEntry),
            ("Backspace", c.testBackspaceEntryOnly),
            ("Clear", c.testClearResetsEverything),
            ("Division by zero", c.testDivideZeroRecovery),
            ("Equals behavior", c.testEqualsWithoutOperandAndRepeatedEqualsAreNoOps),
            ("Limits and scientific notation", c.testInputLimitAndScientificContinuation),
            ("Recurring decimals", c.testRecurringDecimalAndNegativeZero),
            ("Overflow recovery", c.testOverflowIsRecoverable),
            ("Keyboard mapping", c.testKeyboardMappingAndModifiedKeys),
            ("Saved display selection", p.testRestoreUsesSavedDisplayNotPointer),
            ("Drag display selection", p.testDragSelectsPointerDisplay),
            ("Removed display", p.testRemovedDisplayChoosesNearest),
            ("Clamp all edges", p.testClampAllEdges),
            ("Panel boundaries", p.testPanelAtEveryEdgeAndNegativeOrigins),
            ("Panel side and gap", p.testPanelSideAndGap)
        ]
        for (name, test) in cases {
            let before = failures; test(); print("\(failures == before ? "PASS" : "FAIL") \(name)")
        }
        print("\(cases.count) test cases, \(checks) assertions, \(failures) failures")
        exit(failures == 0 ? 0 : 1)
    }
}
