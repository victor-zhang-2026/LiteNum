#if !STANDALONE_TESTS
import XCTest
@testable import LiteNumCore
#endif

final class CalculatorTests: XCTestCase {
    func run(_ keys: String) -> Calculator {
        var calculator = Calculator()
        for character in keys {
            if let key = CalculatorKey.map(code: 0, characters: String(character), modified: false) { calculator.send(key) }
        }
        return calculator
    }
    func testRequestedExamples() {
        XCTAssertEqual(run("128*0.8=").display, "102.4")
        XCTAssertEqual(run("0.1+0.2=").display, "0.3")
    }
    func testAllOperations() {
        for (keys, answer) in [("12+34=", "46"), ("12-34=", "-22"), ("12*34=", "408"), ("81/9=", "9")] {
            XCTAssertEqual(run(keys).display, answer, keys)
        }
    }
    func testSequentialNotPrecedence() { XCTAssertEqual(run("2+3*4=").display, "20") }
    func testOperatorReplacement() {
        XCTAssertEqual(run("8+*/2=").display, "4")
        XCTAssertEqual(run("9+-3=").display, "6")
    }
    func testDecimalAndLeadingZeros() {
        XCTAssertEqual(run("000.1.2+0.08=").display, "0.2")
        XCTAssertEqual(run(".5*.2=").display, "0.1")
        XCTAssertEqual(run("12.+3.=").display, "15")
    }
    func testContinueResultAndNewEntry() {
        XCTAssertEqual(run("2+3=*4=").display, "20")
        XCTAssertEqual(run("2+3=7").display, "7")
        XCTAssertEqual(run("2+3=.4").display, "0.4")
    }
    func testBackspaceEntryOnly() {
        var c = run("123.4"); c.send(.backspace); XCTAssertEqual(c.display, "123.")
        c.send(.backspace); XCTAssertEqual(c.display, "123")
        for _ in 0..<5 { c.send(.backspace) }; XCTAssertEqual(c.display, "0")
        c = run("12+3"); c.send(.backspace); c.send(.digit("5")); c.send(.equals); XCTAssertEqual(c.display, "17")
        c.send(.backspace); XCTAssertEqual(c.display, "17")
        c = run("12+"); c.send(.backspace); c.send(.digit("4")); c.send(.equals); XCTAssertEqual(c.display, "16")
    }
    func testClearResetsEverything() {
        var c = run("32*4"); c.send(.clear)
        XCTAssertEqual(c.display, "0"); XCTAssertEqual(c.expression, ""); XCTAssertNil(c.pending)
        c.send(.digit("2")); c.send(.equals); XCTAssertEqual(c.display, "2")
    }
    func testDivideZeroRecovery() {
        var c = run("8/0="); XCTAssertEqual(c.error, "不能除以零")
        c.send(.operation(.add)); XCTAssertNotNil(c.error)
        c.send(.digit("4")); XCTAssertNil(c.error); XCTAssertEqual(c.display, "4")
        c = run("0/0+"); XCTAssertNotNil(c.error)
        c.send(.backspace); XCTAssertNil(c.error); XCTAssertEqual(c.display, "0")
    }
    func testEqualsWithoutOperandAndRepeatedEqualsAreNoOps() {
        XCTAssertEqual(run("8+=").display, "8")
        XCTAssertEqual(run("8+2===").display, "10")
        XCTAssertEqual(run("8==").display, "8")
    }
    func testInputLimitAndScientificContinuation() {
        let limited = run("12345678901234567")
        XCTAssertEqual(limited.display, "1234567890123456"); XCTAssertNotNil(limited.notice)
        XCTAssertEqual(run("9999999999999999*10=").display, "9.999999999999999e16")
        XCTAssertEqual(run("9999999999999999*10=/10=").display, "9999999999999999")
        XCTAssertEqual(run("0.0000000001/10=").display, "1e-11")
        XCTAssertEqual(run("0.0000000001/10=*10=").display, "1e-10")
    }
    func testRecurringDecimalAndNegativeZero() {
        XCTAssertEqual(run("1/3=").display, "0.3333333333333333")
        XCTAssertEqual(run("0-0=").display, "0")
        XCTAssertEqual(run("0-0.1-0.2=").display, "-0.3")
    }
    func testOverflowIsRecoverable() {
        var c = run("9999999999999999")
        for _ in 0..<10 {
            c.send(.operation(.multiply))
            for _ in 0..<16 { c.send(.digit("9")) }
            c.send(.equals)
            if c.error != nil { break }
        }
        XCTAssertEqual(c.error, "超出计算范围")
        c.send(.clear); XCTAssertEqual(c.display, "0"); XCTAssertNil(c.error)
    }
    func testKeyboardMappingAndModifiedKeys() {
        XCTAssertEqual(CalculatorKey.map(code: 36, characters: "\r", modified: false), .equals)
        XCTAssertEqual(CalculatorKey.map(code: 76, characters: "", modified: false), .equals)
        XCTAssertEqual(CalculatorKey.map(code: 51, characters: "", modified: false), .backspace)
        XCTAssertEqual(CalculatorKey.map(code: 117, characters: "", modified: false), .clear)
        XCTAssertEqual(CalculatorKey.map(code: 71, characters: "", modified: false), .clear)
        XCTAssertEqual(CalculatorKey.map(code: 53, characters: "", modified: false), .close)
        XCTAssertEqual(CalculatorKey.map(code: 0, characters: "+", modified: false), .operation(.add))
        XCTAssertNil(CalculatorKey.map(code: 0, characters: "1", modified: true))
        XCTAssertNil(CalculatorKey.map(code: 0, characters: "", modified: false))
        XCTAssertNil(CalculatorKey.map(code: 0, characters: "a", modified: false))
    }
}
