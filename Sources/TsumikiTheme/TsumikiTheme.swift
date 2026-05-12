public protocol TsumikiTheme: Sendable {
    var colors:     TsumikiColors      { get }
    var typography: TsumikiTypography  { get }
    var spacing:    TsumikiSpacing     { get }
    var radius:     TsumikiRadius      { get }
    var shadow:     TsumikiShadow      { get }
    var opacity:    TsumikiOpacity     { get }
}
