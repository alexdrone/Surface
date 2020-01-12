import Foundation
import CoreMotion
import UIKit

private let _sharedMotionManager: CMMotionManager = CMMotionManager()

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
final class _MotionManager {

  private struct WeakLayerRef { weak var layer: CALayer? }

  static let shared = _MotionManager()

  private let _motionManager = CMMotionManager()
  private var _displayLink: CADisplayLink?
  private let _queue = OperationQueue()
  private var _layers: [WeakLayerRef] = []
  private var _angle: CGFloat = 1.0

  func registerLayer(_ layer: CALayer) {
    guard _layers.filter({ $0.layer === layer }).isEmpty else { return }
    _layers.append(WeakLayerRef(layer: layer))
    _startOrStopGyroUpdates()
  }

  func deregisterLayer(_ layer: CALayer) {
    _layers = _layers.filter { $0.layer != nil && $0.layer !== layer }
    _startOrStopGyroUpdates()
  }

  private func _startOrStopGyroUpdates() {
    _layers = _layers.filter { $0.layer != nil }
    if _layers.isEmpty {
      _motionManager.stopDeviceMotionUpdates()
      _displayLink = nil
    } else {
      guard _displayLink == nil else { return }
      _displayLink = CADisplayLink(target: self, selector: #selector(_onDisplayLinkFire))
      _displayLink?.add(to: .current, forMode: .default)
      _displayLink?.preferredFramesPerSecond = 10
      _motionManager.startDeviceMotionUpdates(to: _queue) { [weak self] data, error in
        guard let value = self?._motionManager.deviceMotion?.attitude.roll else { return }
        self?._angle = CGFloat(value)
      }
    }
  }

  @objc dynamic private func _onDisplayLinkFire() {
    let layers = _layers.compactMap { $0.layer }
    let angle = max(-1, min(1, _angle * 2))
    for layer in layers {
      guard !layer._isShadowAnimationOngoing() else { continue }
      layer.shadow = layer.shadow.withAngle(xt: angle, yt: 1)
    }
  }

}
