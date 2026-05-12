import SwiftUI
import TsumikiComponents
import TsumikiTheme

private struct StyleEntry: Identifiable {
    let id: Int
    let label: String
    let style: TsumikiButtonStyle
}

private struct SizeEntry: Identifiable {
    let id: Int
    let size: TsumikiButtonSize
}

private struct ShapeEntry: Identifiable {
    let id: Int
    let shape: TsumikiButtonShape
}

struct ButtonGallery: View {
    @Environment(\.tsumikiTheme) private var theme

    private let styles: [StyleEntry] = [
        .init(id: 0, label: "Primary",     style: .primary),
        .init(id: 1, label: "Secondary",   style: .secondary),
        .init(id: 2, label: "Tertiary",    style: .tertiary),
        .init(id: 3, label: "Destructive", style: .destructive),
        .init(id: 4, label: "Ghost",       style: .ghost),
    ]
    private let sizes: [SizeEntry] = [
        .init(id: 0, size: .small),
        .init(id: 1, size: .medium),
        .init(id: 2, size: .large),
    ]
    private let shapes: [ShapeEntry] = [
        .init(id: 0, shape: .rounded),
        .init(id: 1, shape: .pill),
        .init(id: 2, shape: .circle),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xl) {
            ForEach(styles) { s in
                section(title: s.label) {
                    ForEach(sizes) { sz in
                        HStack(spacing: theme.spacing.md) {
                            ForEach(shapes) { sh in
                                TsumikiButton(
                                    "Action",
                                    icon: sh.shape == .circle ? Image(systemName: "star.fill") : nil,
                                    style: s.style,
                                    size: sz.size,
                                    shape: sh.shape,
                                    layout: sh.shape == .circle ? .iconOnly : .horizontal
                                ) {}
                            }
                        }
                    }
                }
            }

            section(title: "States") {
                HStack(spacing: theme.spacing.md) {
                    TsumikiButton("Loading", isLoading: true) {}
                    TsumikiButton("Disabled") {}.disabled(true)
                    TsumikiButton("Badge", badge: "3") {}
                }
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(title)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)
            content()
        }
    }
}
