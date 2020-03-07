import UIKit

public struct Shadow {
  /// Default shadow descriptor.
  public let lightInterfaceStyleShadow: _ShadowPair
  /// Dark shadow descriptor.
  public let darkInterfaceStyleShadow: _ShadowPair
  /// Whether the shadow should change when the appearance changed.
  public let shouldReactToIntefaceStyleChange: Bool
  /// Whether the overlay (highlight) shadow should be applied.
  public let shouldUseOverlayShadow: Bool
  /// Optional — Whether the view surface should be tinted accordingly to the shadow.
  public let shouldApplySurfaceBackground: Bool
  /// Optional — This dynamically controls background color of the view.
  public let lightSurfaceBackground: UIColor?
  /// Optional — This dynamically controls background color of the view.
  public let darkSurfaceBackground: UIColor?

  private var _horizontalCastAngle: CGFloat = 0
  private var _verticalCastAngle: CGFloat = 1
  private var _preset: DepthPreset?

  public init(
    lightInterfaceStyleShadow: _ShadowPair,
    darkInterfaceStyleShadow: _ShadowPair? = nil,
    shouldReactToIntefaceStyleChange: Bool = true,
    shouldUseOverlayShadow: Bool = true,
    shouldApplySurfaceBackground: Bool = true,
    lightSurfaceBackground: UIColor? = nil,
    darkSurfaceBackground: UIColor? = nil
  ) {
    self.lightInterfaceStyleShadow = lightInterfaceStyleShadow
    self.darkInterfaceStyleShadow = darkInterfaceStyleShadow ?? lightInterfaceStyleShadow
    self.shouldReactToIntefaceStyleChange = shouldReactToIntefaceStyleChange
    self.shouldUseOverlayShadow = shouldUseOverlayShadow
    self.lightSurfaceBackground = lightSurfaceBackground
    self.darkSurfaceBackground = darkSurfaceBackground
    self.shouldApplySurfaceBackground = shouldApplySurfaceBackground
  }

  public init(
    preset: DepthPreset,
    horizontalCastAngle: CGFloat = 0,
    verticalCastAngle: CGFloat = 1,
    shouldReactToIntefaceStyleChange: Bool = true,
    shouldUseOverlayShadow: Bool = true,
    shouldApplySurfaceBackground: Bool = true
  ) {
    let xt = horizontalCastAngle
    let yt = verticalCastAngle
    let lightBottomShadow = CALayer._CanonicalShadowFormat(
      color: Defaults.Light.bottomShadowTint,
      alpha: Defaults.Light.bottomShadowOpacity,
      offset: CGPoint(x: xt * preset.offset, y: yt * preset.offset),
      blur: preset.blur,
      spread: 1)
    let lightTopShadow = CALayer._CanonicalShadowFormat(
      color: Defaults.Light.topShadowTint,
      alpha: Defaults.Light.topShadowOpacity,
      offset: CGPoint(x: -xt * preset.offset, y: -yt * preset.offset),
      blur: preset.blur,
      spread: 1)
    let darkBottomShadow = CALayer._CanonicalShadowFormat(
      color: Defaults.Dark.bottomShadowTint,
      alpha: Defaults.Dark.bottomShadowOpacity,
      offset: CGPoint(x: xt * preset.offset, y: yt * preset.offset),
      blur: preset.blur,
      spread: 1)
    let darkTopShadow = CALayer._CanonicalShadowFormat(
      color: Defaults.Dark.topShadowTint,
      alpha: Defaults.Dark.topShadowOpacity,
      offset: CGPoint(x: -xt * preset.offset, y: -yt * preset.offset),
      blur: preset.blur,
      spread: 1)

    let lightInterfaceStyleShadow = _ShadowPair(
      bottom: lightBottomShadow,
      top: lightTopShadow)
    let darkInterfaceStyleShadow = _ShadowPair(
      bottom: darkBottomShadow,
      top: darkTopShadow)

    self.init(
      lightInterfaceStyleShadow: lightInterfaceStyleShadow,
      darkInterfaceStyleShadow: darkInterfaceStyleShadow,
      shouldReactToIntefaceStyleChange: shouldReactToIntefaceStyleChange,
      shouldUseOverlayShadow: shouldUseOverlayShadow,
      lightSurfaceBackground: shouldApplySurfaceBackground ? Defaults.Light.background : nil,
      darkSurfaceBackground: shouldApplySurfaceBackground ? Defaults.Dark.background : nil)
    _preset = preset
    _horizontalCastAngle = xt
    _verticalCastAngle = yt
  }

  public func applyToLayer(_ layer: CALayer) {
    let isDarkAppearance =
      UIScreen.main.traitCollection.userInterfaceStyle == .dark && shouldReactToIntefaceStyleChange
    let background = isDarkAppearance ? darkSurfaceBackground : lightSurfaceBackground
    let shadow = isDarkAppearance ? darkInterfaceStyleShadow : lightInterfaceStyleShadow

    layer._appliedLayerShadow = shadow.bottom
    if shouldUseOverlayShadow, let layer = layer as? SurfaceLayer, let top = shadow.top {
      layer._appliedOverlayLayerShadow = top
    }
    if shouldApplySurfaceBackground {
      layer.backgroundColor = background?.cgColor
    }
  }

  public func withAngle(xt: CGFloat, yt: CGFloat) -> Self {
    guard let preset = _preset else { return self }
    return Shadow(
      preset: preset,
      horizontalCastAngle: xt,
      verticalCastAngle: yt,
      shouldReactToIntefaceStyleChange: shouldReactToIntefaceStyleChange,
      shouldUseOverlayShadow: shouldUseOverlayShadow,
      shouldApplySurfaceBackground: shouldApplySurfaceBackground)
  }

  public func withPreset(_ preset: DepthPreset) -> Self {
    return Shadow(
      preset: preset,
      horizontalCastAngle: _horizontalCastAngle,
      verticalCastAngle: _verticalCastAngle,
      shouldReactToIntefaceStyleChange: shouldReactToIntefaceStyleChange,
      shouldUseOverlayShadow: shouldUseOverlayShadow,
      shouldApplySurfaceBackground: shouldApplySurfaceBackground)
  }
}

public struct _ShadowPair {
  /// The overlay (highlight) shadow.
  public let top: CALayer._CanonicalShadowFormat?
  /// The main box shadow.
  public let bottom: CALayer._CanonicalShadowFormat

  public init(bottom: CALayer._CanonicalShadowFormat, top: CALayer._CanonicalShadowFormat? = nil) {
    self.bottom = bottom
    self.top = top
  }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension CALayer {
  /// Shadow format (as used in most design tools such as Sketch).
  struct _CanonicalShadowFormat {
    /// Global constant for no shadows.
    static let zero =
      _CanonicalShadowFormat(color: .clear, alpha: 0, offset: .zero, blur: 0, spread: 0)

    public var color: UIColor
    public var alpha: CGFloat
    public var offset: CGPoint
    public var blur: CGFloat
    public var spread: CGFloat

    /// Whether the shadow should be drawn or not.
    public var isVisible: Bool {
      self.alpha == 0
    }

    public init(
      color: UIColor,
      alpha: CGFloat = 0.16,
      offset: CGPoint,
      blur: CGFloat,
      spread: CGFloat = 0
    ) {
      self.color = color
      self.alpha = alpha
      self.offset = offset
      self.blur = blur
      self.spread = spread
    }
  }
}
