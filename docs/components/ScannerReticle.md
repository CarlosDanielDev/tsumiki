# TsumikiScannerReticle

Visual reticle overlay for QR / barcode / OCR scanning. **Tsumiki ships the
chrome only.** AVFoundation session setup, permission handling, Vision/OCR
pipelines, and ROI math stay in the consuming app. The app reads the reticle
rect through a `PreferenceKey` and feeds it to AVFoundation as
`regionOfInterest`.

This decision (strategy "c") is documented in
[`docs/superpowers/research/arbiters/CameraScan.md`](../superpowers/research/arbiters/CameraScan.md).

## API

```swift
public struct TsumikiScannerReticle<Instructions: View, Status: View>: View {
    public enum Shape: Sendable, Equatable {
        case square                             // QR-style 1:1 (lucidmate)
        case rectangle(aspect: CGFloat)         // OCR-style (aquabrew/WR)
        case fill(widthRatio: CGFloat, heightRatio: CGFloat)
    }
    public enum State: Sendable, Equatable {
        case idle, scanning, processing, success, error
    }
    public enum CornerStyle: Sendable, Equatable {
        case brackets       // L-shaped corners (lucidmate / WR)
        case continuous     // unbroken rounded stroke (aquabrew)
        case none
    }

    public init(shape: Shape = .rectangle(aspect: 16.0 / 9.0),
                state: State = .scanning,
                cornerStyle: CornerStyle = .brackets,
                @ViewBuilder instructions: () -> Instructions,
                @ViewBuilder status: () -> Status)
}

// Convenience: bare reticle (no captions).
public extension TsumikiScannerReticle where Instructions == EmptyView, Status == EmptyView {
    init(shape: Shape = .rectangle(aspect: 16.0 / 9.0),
         state: State = .scanning,
         cornerStyle: CornerStyle = .brackets)
}

// Convenience: plain-string captions.
public extension TsumikiScannerReticle where Instructions == Text, Status == Text {
    init(shape: Shape = .rectangle(aspect: 16.0 / 9.0),
         state: State = .scanning,
         cornerStyle: CornerStyle = .brackets,
         instructions: String,
         status: String = "")
}

// Preference key the consumer reads to set AVFoundation ROI.
public struct TsumikiReticleRectKey: PreferenceKey {
    public static let defaultValue: CGRect
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect)
    public static func normalized(_ rect: CGRect, in size: CGSize) -> CGRect
}
```

## Example — read the rect for AVFoundation ROI

```swift
struct ScanScreen: View {
    @State private var roi: CGRect = .zero
    @State private var state: TsumikiScannerReticle<Text, Text>.State = .scanning

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CameraPreview()  // your AVFoundation UIViewRepresentable

                TsumikiScannerReticle(
                    shape: .rectangle(aspect: 4.0 / 3.0),
                    state: state,
                    cornerStyle: .brackets,
                    instructions: "Position the receipt in the box",
                    status: state == .processing ? "Reading…" : ""
                )
                .onPreferenceChange(TsumikiReticleRectKey.self) { rect in
                    roi = TsumikiReticleRectKey.normalized(rect, in: proxy.size)
                    cameraSession.regionOfInterest = roi
                }
            }
        }
        .tsumikiTheme(DefaultTheme.dark)
    }
}
```

## Theme tokens consumed
- `colors.accent` — default stroke (idle / scanning / processing)
- `colors.success` — stroke when `state == .success`
- `colors.danger` — stroke when `state == .error`
- `colors.textPrimary` — instructions + status text and `.idle` stroke
- `colors.background` — scrim base (multiplied by `opacity.scrim`)
- `opacity.scrim` — scrim transparency
- `spacing.sm` / `spacing.lg` / `spacing.xl` — text gap + reticle inset
- `radius.md` — reticle corner radius (used by both cutout and `.continuous`)
- `typography.body` — instructions text
- `typography.caption` — status text

## What stays in apps
- `AVCaptureSession` + queue architecture
- `UIViewControllerRepresentable` camera-preview wrapper
- Permission check + denied-state screens (custom copy, paywall routing, etc.)
- OCR pipeline (Vision), zoom binding, torch toggle
- QR pipeline (`AVCaptureMetadataOutput`)
- Capture buttons, scan-type pickers, result review
- `Info.plist` `NSCameraUsageDescription`

## Notes
- The cutout is drawn with `Canvas` + even-odd fill so the reticle window is
  fully transparent (the live camera preview shows through).
- `.compositingGroup()` is applied to the scrim canvas to keep blend ordering
  predictable across Dynamic Type changes.
- AquaBrew's draggable `CropBoxOverlayView` (resizable ROI) was intentionally
  left out — it's an app-specific power-user feature, not framework chrome.
- A future, higher-level `TsumikiCameraScan` (strategy "b") could absorb the
  OCR/QR wrappers if 3+ apps end up duplicating that code. This reticle does
  not foreclose that path.
