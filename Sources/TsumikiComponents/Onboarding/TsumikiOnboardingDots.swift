import SwiftUI
import TsumikiTheme

public struct TsumikiOnboardingDots: View {
    public let total: Int
    public let current: Int
    public let accentTint: Color?
    public let onSelect: ((Int) -> Void)?

    @Environment(\.tsumikiTheme) private var theme

    public init(total: Int,
                current: Int,
                accentTint: Color? = nil,
                onSelect: ((Int) -> Void)? = nil) {
        self.total = max(total, 0)
        self.current = current
        self.accentTint = accentTint
        self.onSelect = onSelect
    }

    public static func clampedCurrent(_ value: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return min(max(value, 0), total - 1)
    }

    public var body: some View {
        let accent = accentTint ?? theme.colors.accent
        let active = Self.clampedCurrent(current, total: total)
        HStack(spacing: theme.spacing.sm) {
            ForEach(0..<max(total, 0), id: \.self) { i in
                dot(for: i, active: active, accent: accent)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: active)
        .accessibilityElement(children: onSelect == nil ? .ignore : .contain)
    }

    @ViewBuilder
    private func dot(for i: Int, active: Int, accent: Color) -> some View {
        let isCurrent = i == active
        let isPast = i < active

        let shape = Group {
            if isCurrent {
                Circle().fill(accent).frame(width: 10, height: 10)
            } else if isPast {
                Circle().fill(accent.opacity(0.5)).frame(width: 7, height: 7)
            } else {
                Circle()
                    .stroke(accent.opacity(0.25), lineWidth: 1)
                    .frame(width: 7, height: 7)
            }
        }

        Group {
            if let onSelect {
                Button(action: { onSelect(i) }) {
                    shape.frame(width: 44, height: 44, alignment: .center).contentShape(Rectangle())
                }
                .accessibilityLabel(Text("Page \(i + 1) of \(total)"))
                .accessibilityAddTraits(isCurrent ? .isSelected : [])
            } else {
                shape
            }
        }
    }
}
