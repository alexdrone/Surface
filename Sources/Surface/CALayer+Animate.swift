import UIKit

// MARK: - Extension

public extension CALayer {
  /// Animation wrapper on CALayer.
  func animate() -> _CALayerAnimate {
    _CALayerAnimate(layer: self)
  }

  func _isShadowAnimationOngoing() -> Bool {
    _containerRef._isShadowAnimationOngoing
  }
}

// MARK: - _CALayerAnimate

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public class _CALayerAnimate {
  private var animations: [String: CAAnimation]
  private var duration: CFTimeInterval
  private let layer: CALayer

  init(layer: CALayer) {
    self.animations = [String: CAAnimation]()
    self.duration = 0.25  // second
    self.layer = layer
  }

  public func shadowOpacity(_ shadowOpacity: Float) -> _CALayerAnimate {
    let key = "shadowOpacity"
    let animation = CABasicAnimation(keyPath: key)
    animation.fromValue = layer.shadowOpacity
    animation.toValue = shadowOpacity
    animation.isRemovedOnCompletion = true
    animation.fillMode = CAMediaTimingFillMode.forwards
    animations[key] = animation
    return self
  }

  public func shadowRadius(_ shadowRadius: CGFloat) -> _CALayerAnimate {
    let key = "shadowRadius"
    let animation = CABasicAnimation(keyPath: key)
    animation.fromValue = layer.shadowRadius
    animation.toValue = shadowRadius
    animation.isRemovedOnCompletion = true
    animation.fillMode = CAMediaTimingFillMode.forwards
    animations[key] = animation
    return self
  }

  public func shadowOffset(_ size: CGSize) -> _CALayerAnimate {
    let key = "shadowOffset"
    let animation = CABasicAnimation(keyPath: key)
    animation.fromValue = NSValue(cgSize: layer.shadowOffset)
    animation.toValue = NSValue(cgSize: size)
    animation.isRemovedOnCompletion = true
    animation.fillMode = CAMediaTimingFillMode.forwards

    animations[key] = animation
    return self
  }

  public func duration(_ duration: CFTimeInterval) -> _CALayerAnimate {
    self.duration = duration
    return self
  }

  /// Apply the layer animation 
  public func start() {
    layer._containerRef._isShadowAnimationOngoing = true
    CATransaction.begin()
    for (key, animation) in animations {
      animation.duration = duration
      layer.removeAnimation(forKey: key)
      layer.add(animation, forKey: key)
    }
    CATransaction.setCompletionBlock {
      self.layer._containerRef._isShadowAnimationOngoing = false
    }
    CATransaction.commit()
  }
}

