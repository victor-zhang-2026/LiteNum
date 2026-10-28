import SwiftUI
import LiteNumCore

final class CalculatorModel: ObservableObject {
    @Published var calculator = Calculator()
    func send(_ key: CalculatorKey) { calculator.send(key) }
}

struct CalculatorView: View {
    @ObservedObject var model: CalculatorModel
    let onClose: () -> Void
    let onInput: (CalculatorKey) -> Void
    private let ink = Color(red: 37/255, green: 37/255, blue: 37/255)
    private let red = Color(nsColor: BrandArtwork.main)
    private let pale = Color(red: 248/255, green: 234/255, blue: 230/255)
    private let keyWidth: CGFloat = 56

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                BrandIcon(size: 26)
                Text("LiteNum").font(.system(size: 14, weight: .semibold))
                Spacer()
                Button(action: onClose) { Image(systemName: "xmark").font(.system(size: 11, weight: .semibold)).frame(width: 26, height: 26) }
                    .buttonStyle(KeyStyle(fill: Color.black.opacity(0.045), foreground: .secondary))
                    .accessibilityLabel("收起计算器").help("收起 · Esc")
            }.frame(height: 28)
            Spacer().frame(height: 14)
            VStack(alignment: .trailing, spacing: 9) {
                Text(model.calculator.expression.isEmpty ? " " : model.calculator.expression)
                    .font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                    .lineLimit(1).minimumScaleFactor(0.65).frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityIdentifier("expression")
                Text(model.calculator.error ?? model.calculator.display)
                    .font(.system(size: model.calculator.error == nil ? 36 : 25, weight: .medium, design: .rounded))
                    .monospacedDigit().foregroundColor(model.calculator.error == nil ? ink : red)
                    .lineLimit(1).minimumScaleFactor(0.38).frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityIdentifier("result").textSelection(.disabled)
            }.frame(height: 74, alignment: .bottom)
            Text(model.calculator.notice ?? " ").font(.system(size: 10)).foregroundColor(red).frame(height: 24)
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    key("AC", .clear, label: "清除 AC", special: true)
                    key("⌫", .backspace, label: "退格", special: true)
                    key("÷", .operation(.divide), special: true)
                    key("×", .operation(.multiply), special: true)
                }
                HStack(spacing: 8) { digit("7"); digit("8"); digit("9"); key("−", .operation(.subtract), special: true) }
                HStack(spacing: 8) { digit("4"); digit("5"); digit("6"); key("+", .operation(.add), special: true) }
                HStack(spacing: 8) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) { digit("1"); digit("2"); digit("3") }
                        HStack(spacing: 8) { key("0", .digit("0"), width: 120); key(".", .decimal, label: "小数点") }
                    }
                    Button { onInput(.equals) } label: { Text("=").font(.system(size: 27, weight: .medium)).frame(width: keyWidth, height: 104) }
                        .buttonStyle(KeyStyle(fill: red, foreground: .white, gradient: true))
                        .accessibilityLabel("等于").help("等于 · Enter / =")
                }
            }
        }
        .padding(16).frame(width: 280, height: 444)
        .foregroundColor(ink).background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.07), lineWidth: 1))
        .environment(\.colorScheme, .light)
    }
    private func digit(_ value: String) -> some View { key(value, .digit(value)) }
    private func key(_ title: String, _ input: CalculatorKey, label: String? = nil, special: Bool = false, width: CGFloat = 56) -> some View {
        let selected: Bool = { if case .operation(let operation) = input { return model.calculator.pending == operation }; return false }()
        return Button { onInput(input) } label: {
            Text(title).font(.system(size: title == "AC" ? 15 : 23, weight: title == "AC" ? .semibold : .regular))
                .frame(width: width, height: 48)
        }
        .buttonStyle(KeyStyle(fill: selected ? red : (special ? pale : Color(red: 245/255, green: 245/255, blue: 245/255)), foreground: selected ? .white : (special ? red : ink)))
        .accessibilityLabel(label ?? title)
    }
}

private struct KeyStyle: ButtonStyle {
    let fill: Color
    let foreground: Color
    var gradient = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.foregroundColor(foreground)
            .background {
                if gradient { LinearGradient(colors: [Color(nsColor: BrandArtwork.light), Color(nsColor: BrandArtwork.dark)], startPoint: .topLeading, endPoint: .bottomTrailing) }
                else { fill }
            }
            .overlay(Color.black.opacity(configuration.isPressed ? 0.09 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
