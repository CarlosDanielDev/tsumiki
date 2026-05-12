import SwiftUI
import TsumikiTheme

public struct TsumikiOnboardingAction {
    public let title: String
    public let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

public struct TsumikiOnboardingSymbolIllustration: View {
    public let systemImage: String
    public let tint: Color?

    @Environment(\.tsumikiTheme) private var theme

    public init(systemImage: String, tint: Color? = nil) {
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        let accent = tint ?? theme.colors.accent
        ZStack {
            Circle()
                .fill(accent.opacity(0.12))
                .frame(width: 160, height: 160)
            Circle()
                .fill(accent.opacity(0.20))
                .frame(width: 120, height: 120)
            Image(systemName: systemImage)
                .font(.system(size: 56, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(accent)
        }
        .accessibilityHidden(true)
    }
}

public struct TsumikiOnboardingPage<Illustration: View>: View {
    public let title: String
    public let bodyText: String
    public let subtitle: String?
    public let accentTint: Color?
    public let primaryAction: TsumikiOnboardingAction
    public let secondaryAction: TsumikiOnboardingAction?
    public let isActive: Bool
    public let illustration: Illustration

    @Environment(\.tsumikiTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var iconVisible = false
    @State private var subtitleVisible = false
    @State private var titleVisible = false
    @State private var bodyVisible = false

    public init(
        @ViewBuilder illustration: () -> Illustration,
        title: String,
        body: String,
        subtitle: String? = nil,
        accentTint: Color? = nil,
        primaryAction: TsumikiOnboardingAction,
        secondaryAction: TsumikiOnboardingAction? = nil,
        isActive: Bool = true
    ) {
        self.illustration = illustration()
        self.title = title
        self.bodyText = body
        self.subtitle = subtitle
        self.accentTint = accentTint
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.isActive = isActive
    }

    public var body: some View {
        let accent = accentTint ?? theme.colors.accent

        VStack(spacing: theme.spacing.lg) {
            Spacer(minLength: theme.spacing.lg)

            illustration
                .opacity(iconVisible ? 1 : 0)
                .scaleEffect(iconVisible ? 1 : 0.85)

            VStack(spacing: theme.spacing.md) {
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.headline)
                        .foregroundStyle(accent)
                        .opacity(subtitleVisible ? 1 : 0)
                        .offset(y: subtitleVisible ? 0 : 6)
                }

                Text(title)
                    .font(theme.typography.largeTitle.weight(.bold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 8)

                Text(bodyText)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .opacity(bodyVisible ? 1 : 0)
                    .offset(y: bodyVisible ? 0 : 8)
            }
            .padding(.horizontal, theme.spacing.lg)
            .accessibilityElement(children: .combine)

            Spacer(minLength: theme.spacing.lg)

            VStack(spacing: theme.spacing.sm) {
                Button(action: { primaryAction.action() }) {
                    Text(primaryAction.title)
                        .font(theme.typography.headline)
                        .foregroundStyle(theme.colors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                .fill(accent)
                        )
                }

                if let secondaryAction {
                    Button(action: { secondaryAction.action() }) {
                        Text(secondaryAction.title)
                            .font(theme.typography.body)
                            .foregroundStyle(accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacing.sm)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.bottom, theme.spacing.lg)
        }
        .onAppear { runEntrance() }
        .onChange(of: isActive) { _, newValue in
            if newValue { runEntrance() } else { resetEntrance() }
        }
    }

    private func runEntrance() {
        if reduceMotion {
            iconVisible = true
            subtitleVisible = true
            titleVisible = true
            bodyVisible = true
            return
        }
        resetEntrance()
        let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
        withAnimation(spring.delay(0.10)) { iconVisible = true }
        withAnimation(spring.delay(0.15)) { subtitleVisible = true }
        withAnimation(spring.delay(0.25)) { titleVisible = true }
        withAnimation(spring.delay(0.35)) { bodyVisible = true }
    }

    private func resetEntrance() {
        iconVisible = false
        subtitleVisible = false
        titleVisible = false
        bodyVisible = false
    }
}

public extension TsumikiOnboardingPage where Illustration == TsumikiOnboardingSymbolIllustration {
    init(
        systemImage: String,
        title: String,
        body: String,
        subtitle: String? = nil,
        accentTint: Color? = nil,
        primaryAction: TsumikiOnboardingAction,
        secondaryAction: TsumikiOnboardingAction? = nil,
        isActive: Bool = true
    ) {
        self.init(
            illustration: { TsumikiOnboardingSymbolIllustration(systemImage: systemImage, tint: accentTint) },
            title: title,
            body: body,
            subtitle: subtitle,
            accentTint: accentTint,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction,
            isActive: isActive
        )
    }
}
