import UIKit

open class SurfaceView: UIView {
  /// Returns its layer properly casted to `SurfaceLayer`.
  open var surfaceLayer: SurfaceLayer { layer as! SurfaceLayer }

  /// Returns the class used to create the layer for instances of this class.
  open override class var layerClass: AnyClass {
    SurfaceLayer.self
  }
}

public final class SurfaceLayer: CALayer {
  /// The shadow applied to the overlay layer.
  public var _appliedOverlayLayerShadow:  CALayer._CanonicalShadowFormat {
    get { _overlayLayer._appliedLayerShadow }
    set { _overlayLayer._appliedLayerShadow = newValue }
  }

  /// The overlay layer adding a second shadow to it.
  private lazy var _overlayLayer: CALayer = {
    let layer = CALayer()
    addSublayer(layer)
    return layer
  }()

  /// The radius to use when drawing rounded corners for the layer’s background. Animatable.
  public override var cornerRadius: CGFloat {
    didSet {
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  /// Tells the layer to update its layout.
  public override func layoutSublayers() {
    _overlayLayer.frame = bounds
    _overlayLayer.backgroundColor = backgroundColor
    _overlayLayer.cornerRadius = cornerRadius
  }
}
