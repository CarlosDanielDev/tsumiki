# Arbiter: CameraScan

## Strategy: (c) overlay chrome only — `TsumikiScannerReticle`

Tsumiki provides ONLY the visual reticle overlay. AVFoundation, Vision, permissions, and lifecycle stay in apps. Apps overlay the reticle on their preview view and read a `PreferenceKey` for the normalized rect to set as AVFoundation region of interest.

## Why
- AVFoundation coupling is heavy and divergent: aquabrew/WR use `CameraPreviewView` (UIViewControllerRepresentable) + Vision OCR pipeline with crop ROI, zoom binding, flashlight toggle, per-frame `onTextDetected` callbacks; lucidmate uses `QRCameraViewController` + `AVCaptureMetadataOutput`. Unifying = god component.
- Consumer state non-portable: `CameraScanViewModel` owns cropRegion, zoomLevel, scanType, dailyLimitManager, paywall flow, manual-input fallback, analytics.
- Permission UX, lifecycle, queue architecture all consumer-owned (and stay that way).
- The overlap that IS truly duplicated and visual is the reticle: cutout rectangle, stroke border, four corner brackets, status text.
- Option (c) keeps Tsumiki dependency-light (no AVFoundation, no Vision, no Info.plist requirements). One PR.

## Proposed Tsumiki API

```swift
public struct TsumikiScannerReticle<Instructions: View, Status: View>: View {
    public enum Shape: Sendable, Equatable {
        case square                         // QR-style: 1:1 centered (lucidmate)
        case rectangle(aspect: CGFloat)     // OCR-style (aquabrew/WR)
        case fill(widthRatio: CGFloat, heightRatio: CGFloat)
    }
    public enum State: Sendable, Equatable { case idle, scanning, processing, success, error }
    public enum CornerStyle: Sendable, Equatable {
        case brackets       // L-shaped (lucidmate / WR)
        case continuous     // unbroken rounded stroke (aquabrew)
        case none
    }

    public init(
        shape: Shape = .rectangle(aspect: 16.0/9.0),
        state: State = .scanning,
        cornerStyle: CornerStyle = .brackets,
        @ViewBuilder instructions: @escaping () -> Instructions = { EmptyView() },
        @ViewBuilder status: @escaping () -> Status = { EmptyView() }
    )
}

// Plain-string convenience overload:
public extension TsumikiScannerReticle where Instructions == Text, Status == Text {
    init(shape: Shape, state: State, cornerStyle: CornerStyle,
         instructions: String, status: String = "")
}

// Preference key consumers read for ROI:
public struct TsumikiReticleRectKey: PreferenceKey {
    public static var defaultValue: CGRect { .zero }
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect)
}
```

Layout: fills container, dims outside reticle rect using `Canvas` + `.destinationOut` (lucidmate's pattern), draws stroke + brackets in state-driven colour, places `instructions` above + `status` below with theme spacing.

## Theme tokens consumed
- colors.accent (default scanning stroke), success/warning/danger (state-driven), textPrimary, background (scrim)
- spacing.md/lg/xl, radius.md
- typography.body, typography.caption
- **NEW token needed**: `TsumikiOpacity.scrim: CGFloat` (default ~0.5)

## What stays in apps
- AVCaptureSession + queue architecture
- UIViewControllerRepresentable wrappers
- Permission check + denied/requesting screens (custom copy + paywall routing)
- OCR pipeline (Vision), crop ROI math, zoom, flashlight
- QR pipeline (AVCaptureMetadataOutput)
- Capture button, scan-type pickers, processing overlays, result review
- `Info.plist` `NSCameraUsageDescription`

## Risks / open questions
- Reticle-rect-as-preference: needs normalized coordinates in AVFoundation space (top-left origin, 0–1). Expose both view-space `CGRect` + `normalized(in:)` helper.
- AquaBrew's draggable `CropBoxOverlayView` (resizable ROI) NOT in scope — stays app-side.
- LucidMate `.success`/`.error` carry a message; current API uses separate `status` view builder (state stays pure).
- `Canvas` + `.destinationOut` requires `compositingGroup()` discipline; verify pixel alignment across Dynamic Type + landscape.
- Future option (b) not foreclosed: if 3+ apps duplicate same OCR/QR wrapper, higher-level `TsumikiCameraScan` could be added later.
