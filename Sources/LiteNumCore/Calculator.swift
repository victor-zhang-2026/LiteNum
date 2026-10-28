import Foundation

public enum Operation: String, CaseIterable {
    case add = "+", subtract = "−", multiply = "×", divide = "÷"
}

public enum CalculatorKey: Equatable {
    case digit(String), decimal, operation(Operation), equals, backspace, clear, close

    /// macOS key codes are stable hardware codes; characters preserve Shift for + and *.
    public static func map(code: UInt16, characters: String, modified: Bool) -> CalculatorKey? {
        guard !modified else { return nil }
        switch code {
        case 53: return .close
        case 36, 76: return .equals
        case 51: return .backspace
        case 117, 71: return .clear
        default: break
        }
        if characters.count == 1, "0123456789".contains(characters), !characters.isEmpty { return .digit(characters) }
        switch characters {
        case ".", ",": return .decimal
        case "+": return .operation(.add)
        case "-": return .operation(.subtract)
        case "*": return .operation(.multiply)
        case "/": return .operation(.divide)
        case "=": return .equals
        default: return nil
        }
    }
}

public struct Calculator {
    public private(set) var display = "0"
    public private(set) var expression = ""
    public private(set) var error: String?
    public private(set) var notice: String?
    public private(set) var pending: Operation?
    private var accumulator: Decimal?
    private var resultValue: Decimal?
    private var startsNewEntry = true
    private var completed = false
    private var value: Decimal { resultValue ?? Decimal(string: display, locale: Locale(identifier: "en_US_POSIX")) ?? 0 }

    public init() {}

    public mutating func send(_ key: CalculatorKey) {
        notice = nil
        switch key {
        case .clear: self = Calculator()
        case .digit(let digit): input(digit)
        case .decimal: inputDecimal()
        case .backspace: backspace()
        case .operation(let operation): choose(operation)
        case .equals: equals()
        case .close: break
        }
    }

    private mutating func prepareEntry() {
        if error != nil || completed { self = Calculator() }
        if startsNewEntry { display = "0"; resultValue = nil; startsNewEntry = false }
    }
    private mutating func input(_ digit: String) {
        guard digit.count == 1, digit.first?.isASCII == true, digit.first?.isNumber == true else { return }
        prepareEntry()
        guard display.filter({ $0.isNumber }).count < 16 else { notice = "最多输入 16 位数字"; return }
        if display == "0" { display = digit } else { display += digit }
    }
    private mutating func inputDecimal() {
        prepareEntry()
        if !display.contains(".") { display += "." }
    }
    private mutating func backspace() {
        if error != nil { self = Calculator(); return }
        guard !startsNewEntry, !completed else { return }
        display.removeLast()
        if display.isEmpty || display == "-" { display = "0" }
    }
    private mutating func choose(_ operation: Operation) {
        guard error == nil else { return }
        if let previous = pending, let left = accumulator, !startsNewEntry {
            guard let answer = calculate(left, value, previous) else { return }
            display = Self.format(answer); resultValue = answer; accumulator = answer
        } else if pending == nil { accumulator = value }
        pending = operation; startsNewEntry = true; completed = false
        expression = "\(Self.format(accumulator ?? value)) \(operation.rawValue)"
    }
    private mutating func equals() {
        guard error == nil, let operation = pending, let left = accumulator, !startsNewEntry else { return }
        let right = value
        let line = "\(Self.format(left)) \(operation.rawValue) \(Self.format(right)) ="
        guard let result = calculate(left, right, operation) else { return }
        display = Self.format(result); resultValue = result; expression = line
        accumulator = nil; pending = nil; startsNewEntry = true; completed = true
    }
    private mutating func calculate(_ lhs: Decimal, _ rhs: Decimal, _ operation: Operation) -> Decimal? {
        if operation == .divide && rhs == 0 { fail("不能除以零"); return nil }
        var a = lhs, b = rhs, result = Decimal()
        let status: Decimal.CalculationError
        switch operation {
        case .add: status = NSDecimalAdd(&result, &a, &b, .plain)
        case .subtract: status = NSDecimalSubtract(&result, &a, &b, .plain)
        case .multiply: status = NSDecimalMultiply(&result, &a, &b, .plain)
        case .divide: status = NSDecimalDivide(&result, &a, &b, .plain)
        }
        guard status == .noError || status == .lossOfPrecision, !result.isNaN else { fail("超出计算范围"); return nil }
        // Round the stored value and the visible value together, avoiding hidden digits.
        if result != 0 {
            let order = Self.decimalOrder(result)
            var rounded = Decimal()
            NSDecimalRound(&rounded, &result, 15 - order, .plain)
            result = rounded
        }
        guard !result.isNaN else { fail("超出计算范围"); return nil }
        return result
    }
    private mutating func fail(_ message: String) {
        error = message; expression = "按 AC 清除，或输入数字重新开始"
        pending = nil; accumulator = nil; startsNewEntry = true; completed = false
    }
    public static func format(_ number: Decimal) -> String {
        if number == 0 { return "0" }
        var n = number
        let raw = NSDecimalString(&n, Locale(identifier: "en_US_POSIX"))
        // Decimal's own string conversion is exact; scientific notation is only layout.
        if decimalOrder(n) >= 16 || decimalOrder(n) < -9 {
            let negative = raw.hasPrefix("-")
            let unsigned = negative ? String(raw.dropFirst()) : raw
            let parts = unsigned.split(separator: ".", omittingEmptySubsequences: false)
            let digits = unsigned.filter { $0.isNumber }
            guard let first = digits.firstIndex(where: { $0 != "0" }) else { return "0" }
            let offset = digits.distance(from: digits.startIndex, to: first)
            var significant = String(digits[first...])
            while significant.last == "0", significant.count > 1 { significant.removeLast() }
            let exponent = parts[0].count - offset - 1
            let mantissa = String(significant.prefix(1)) + (significant.count > 1 ? "." + significant.dropFirst() : "")
            return (negative ? "-" : "") + mantissa + "e" + String(exponent)
        }
        return raw
    }
    private static func decimalOrder(_ number: Decimal) -> Int {
        var n = number
        let unsigned = NSDecimalString(&n, Locale(identifier: "en_US_POSIX")).replacingOccurrences(of: "-", with: "")
        let wholeCount = unsigned.split(separator: ".", omittingEmptySubsequences: false)[0].count
        let digits = unsigned.filter { $0.isNumber }
        let zeros = digits.prefix { $0 == "0" }.count
        return wholeCount - zeros - 1
    }
}
