import UIKit
import CoreMotion

// MARK: - Extension

public extension CALayer {
  /// The high-level shadow argument.
  var shadow: Shadow {
    get { _containerRef.shadow }
    set { _containerRef.shadow = newValue }
  }
  /// Whether it should use the device motion sensor to cast the shadow angle.
  var useDeviceMotionToCastShadow: Bool {
    get { _containerRef.useDeviceMotionToCastShadow }
    set { _containerRef.useDeviceMotionToCastShadow = newValue }
  }

  /// The layer shadow exposed as a canonical shadow format.
  /// - note: This triggers an implicit layer animation.
  var _appliedLayerShadow: CALayer._CanonicalShadowFormat {
    get { _containerRef._appliedLayerShadow }
    set { _containerRef._appliedLayerShadow = newValue }
  }

  /// Re-apply the shadow to this layer.
  func setNeedsLayoutShadow() {
    _containerRef.shadow = shadow
  }

  /// Updates the shadow path.
  func _layoutShadowPath() {
    guard _containerRef._isShadowPathAutoSizing else { return }
    if !_appliedLayerShadow.isVisible {
      shadowPath = nil
    } else {
      shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
  }
}

// MARK: _CALayerAssociatedContainer

final class _CALayerAssociatedContainer {
  /// A reference to the CALayer.
  private weak var _layer: CALayer?

  /// The associated shadow argument.
  var shadow = Shadow(lightInterfaceStyleShadow: _ShadowPair(bottom: .zero)) {
    didSet {
      guard let layer = _layer else { return }
      shadow.applyToLayer(layer)
      layer.setNeedsLayout()
      layer.setNeedsDisplay()
    }
  }

  var useDeviceMotionToCastShadow: Bool = false {
    didSet {
      guard let layer = _layer else { return }
      if useDeviceMotionToCastShadow {
        _MotionManager.shared.registerLayer(layer)
      } else {
        _MotionManager.shared.deregisterLayer(layer)
      }
    }
  }

  var _isShadowAnimationOngoing: Bool = false

  /// Update the layer shadow animated.
  var _appliedLayerShadow: CALayer._CanonicalShadowFormat = .zero {
    didSet {
      guard let layer = _layer else { return }
      layer.animate()
        .shadowRadius(_appliedLayerShadow.blur / 2.0)
        .shadowOffset(CGSize(
          width: _appliedLayerShadow.offset.x,
          height: _appliedLayerShadow.offset.y))
        .shadowOpacity(Float(_appliedLayerShadow.alpha))
        .duration(0.166)
        .start()
      layer.shadowColor = _appliedLayerShadow.color.cgColor
      layer.shadowRadius = _appliedLayerShadow.blur / 2.0
      layer.shadowOpacity = Float(_appliedLayerShadow.alpha)
      layer.shadowOffset = CGSize(width: _appliedLayerShadow.offset.x, height: _appliedLayerShadow.offset.y)
      layer._layoutShadowPath()
    }
  }

  /// Enables automatic shadowPath sizing.
  var _isShadowPathAutoSizing = true

  init(layer: CALayer?) {
    self._layer = layer
  }
}

extension CALayer {
  /// Layer elevation/ animation state.
  var _containerRef: _CALayerAssociatedContainer {
    get {
      typealias C = _CALayerAssociatedContainer
      let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
      guard let obj = objc_getAssociatedObject(self, &_associatedContainerKey) as? C else {
        let container = _CALayerAssociatedContainer(layer: self)
        objc_setAssociatedObject(self, &_associatedContainerKey, container, nonatomic)
        return container
      }
      return obj
    }
    set(value) {
      let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
      objc_setAssociatedObject(self, &_associatedContainerKey, value, nonatomic)
    }
  }
}

private var _associatedContainerKey: UInt8 = 0
