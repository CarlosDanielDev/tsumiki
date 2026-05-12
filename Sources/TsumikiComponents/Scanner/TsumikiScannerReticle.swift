import SwiftUI
import TsumikiTheme

public struct TsumikiScannerReticle<Instructions: View, Status: View>: View {
    public enum Shape: Sendable, Equatable {
        case square
        case rectangle(aspect: CGFloat)
        case fill(widthRatio: CGFloat, heightRatio: CGFloat)
    }

    public enum State: Sendable, Equatable, Hashable {
        case idle, scanning, processing, success, error
    }

    public enum CornerStyle: Sendable, Equatable {
        case brackets
        case continuous
        case none
    }

    public let shape: Shape
    public let state: State
    public let cornerStyle: CornerStyle
    public let instructions: Instructions
    public let status: Status

    @Environment(\.tsumikiTheme) private var theme

    public init(shape: Shape = .rectangle(aspect: 16.0 / 9.0),
                state: State = .scanning,
                cornerStyle: CornerStyle = .brackets,
                @ViewBuilder instructions: () -> Instructions,
                @ViewBuilder status: () -> Status) {
        self.shape = shape
        self.state = state
        self.cornerStyle = cornerStyle
        self.instructions = instructions()
        self.status = status()
    }

    public var body: some View {
        GeometryReader { proxy in
            let rect = reticleRect(in: proxy.size)
            ZStack(alignment: .topLeading) {
                scrim(rect: rect, size: proxy.size)
                cornerOverlay(rect: rect)
                placedTexts(rect: rect, size: proxy.size)
            }
            .preference(key: TsumikiReticleRectKey.self, value: rect)
        }
    }

    private func reticleRect(in size: CGSize) -> CGRect {
        let w: CGFloat
        let h: CGFloat
        switch shape {
        case .square:
            let side = min(size.width, size.height) * 0.7
            w = side
            h = side
        case .rectangle(let aspect):
            let available = size.width - 2 * theme.spacing.xl
            let proposedW = max(available, 0)
            let proposedH = proposedW / max(aspect, 0.0001)
            if proposedH > size.height - 2 * theme.spacing.xl {
                h = max(size.height - 2 * theme.spacing.xl, 0)
                w = h * aspect
            } else {
                w = proposedW
                h = proposedH
            }
        case .fill(let widthRatio, let heightRatio):
            w = size.width * widthRatio
            h = size.height * heightRatio
        }
        let x = (size.width - w) / 2
        let y = (size.height - h) / 2
        return CGRect(x: x, y: y, width: w, height: h)
    }

    @ViewBuilder
    private func scrim(rect: CGRect, size: CGSize) -> some View {
        Canvas { ctx, _ in
            var path = Path(CGRect(origin: .zero, size: size))
            let cutout = Path(roundedRect: rect, cornerRadius: theme.radius.md)
            path.addPath(cutout)
            ctx.fill(
                path,
                with: .color(theme.colors.background.opacity(theme.opacity.scrim)),
                style: FillStyle(eoFill: true, antialiased: true)
            )
        }
        .compositingGroup()
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func cornerOverlay(rect: CGRect) -> some View {
        switch cornerStyle {
        case .brackets:
            BracketsOverlay(rect: rect,
                            length: theme.spacing.lg,
                            color: strokeColor)
        case .continuous:
            ContinuousStroke(rect: rect,
                             radius: theme.radius.md,
                             color: strokeColor)
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private func placedTexts(rect: CGRect, size: CGSize) -> some View {
        VStack(spacing: theme.spacing.sm) {
            instructions
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: size.width - 2 * theme.spacing.lg)
        .position(x: size.width / 2,
                  y: max(theme.spacing.lg, rect.minY - theme.spacing.lg))

        status
            .font(theme.typography.caption)
            .foregroundColor(theme.colors.textPrimary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: size.width - 2 * theme.spacing.lg)
            .position(x: size.width / 2,
                      y: min(size.height - theme.spacing.lg,
                             rect.maxY + theme.spacing.lg))
    }

    private var strokeColor: Color {
        switch state {
        case .idle:       return theme.colors.textPrimary
        case .scanning:   return theme.colors.accent
        case .processing: return theme.colors.accent
        case .success:    return theme.colors.success
        case .error:      return theme.colors.danger
        }
    }
}

public extension TsumikiScannerReticle where Instructions == EmptyView, Status == EmptyView {
    init(shape: Shape = .rectangle(aspect: 16.0 / 9.0),
         state: State = .scanning,
         cornerStyle: CornerStyle = .brackets) {
        self.init(shape: shape, state: state, cornerStyle: cornerStyle,
                  instructions: { EmptyView() },
                  status: { EmptyView() })
    }
}

public extension TsumikiScannerReticle where Instructions == Text, Status == Text {
    init(shape: Shape = .rectangle(aspect: 16.0 / 9.0),
         state: State = .scanning,
         cornerStyle: CornerStyle = .brackets,
         instructions: String,
         status: String = "") {
        self.init(shape: shape, state: state, cornerStyle: cornerStyle,
                  instructions: { Text(instructions) },
                  status: { Text(status) })
    }
}

private struct BracketsOverlay: View {
    let rect: CGRect
    let length: CGFloat
    let color: Color

    var body: some View {
        Canvas { ctx, _ in
            let lineWidth: CGFloat = 3
            var path = Path()
            // top-left
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))
            // top-right
            path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))
            // bottom-right
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
            // bottom-left
            path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))

            ctx.stroke(path, with: .color(color),
                       style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
    }
}

private struct ContinuousStroke: View {
    let rect: CGRect
    let radius: CGFloat
    let color: Color

    var body: some View {
        Canvas { ctx, _ in
            let path = Path(roundedRect: rect, cornerRadius: radius)
            ctx.stroke(path, with: .color(color),
                       style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        }
    }
}
