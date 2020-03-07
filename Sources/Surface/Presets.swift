import UIKit

public enum DepthPreset {
  case concave5
  case concave4
  case concave3
  case concave2
  case concave1
  case none
  case convex1
  case convex2
  case convex3
  case convex4
  case convex5

  /// Blur value for this depth.
  public var blur: CGFloat {
    switch self {
    case .concave5: return 16
    case .concave4: return 8
    case .concave3: return 4
    case .concave2: return 2
    case .concave1: return 1
    case .none: return 0
    case .convex1: return 1
    case .convex2: return 2
    case .convex3: return 4
    case .convex4: return 8
    case .convex5: return 16
    }
  }

  /// Offset value for this depth.
  public var offset: CGFloat {
    switch self {
    case .concave5: return -8
    case .concave4: return -4
    case .concave3: return -2
    case .concave2: return -1
    case .concave1: return -0.5
    case .none: return 0
    case .convex1: return 0.5
    case .convex2: return 1
    case .convex3: return 2
    case .convex4: return 4
    case .convex5: return 8
    }
  }
}

public struct Defaults {
  public struct Light {
    static var systemBackground = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
    static var background = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
    static var bottomShadowOpacity: CGFloat = 0.16
    static var topShadowOpacity: CGFloat = 0.5
    static var bottomShadowTint: UIColor = .black
    static var topShadowTint: UIColor = .white
  }
  public struct Dark {
    static var systemBackground = UIColor(red:0.13, green:0.13, blue:0.15, alpha:1.0)
    static var background = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
    static var bottomShadowOpacity: CGFloat = 0.18
    static var topShadowOpacity: CGFloat = 0.7
    static var bottomShadowTint: UIColor = .black
    static var topShadowTint: UIColor =  UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
  }
}

/// Default system background color.
public func systemBackground(shouldReactToIntefaceStyleChange: Bool = true) -> UIColor {
  let isDarkAppearance =
    UIScreen.main.traitCollection.userInterfaceStyle == .dark && shouldReactToIntefaceStyleChange
  return isDarkAppearance ? Defaults.Dark.systemBackground : Defaults.Light.systemBackground
}
