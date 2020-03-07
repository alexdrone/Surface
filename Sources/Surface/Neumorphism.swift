// Forked from https://github.com/hirokimu/EMTNeumorphicView
// Used internally as benchmark.

// The MIT License (MIT)
//
// Copyright (c) 2020 Emotionale (https://www.emotionale.jp/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/// `NeumorphicView` is a subclass of UIView and it provides some Neumorphism style design.
/// Access neumorphicLayer. Change effects via its properties.
public class NeumorphicView: UIView, NeumorphicElementProtocol {
  /// Change effects via its properties.
  public var neumorphicLayer: NeumorphicLayer? {
    return layer as? NeumorphicLayer
  }
  public override class var layerClass: AnyClass {
    return NeumorphicLayer.self
  }
  public override func layoutSubviews() {
    super.layoutSubviews()
    neumorphicLayer?.update()
  }
}

/// `NeumorphicButton` is a subclass of UIView and it provides some Neumorphism style design.
/// Access neumorphicLayer. Change effects via its properties.
public class NeumorphicButton: UIButton, NeumorphicElementProtocol {
  /// Change effects via its properties.
  public var neumorphicLayer: NeumorphicLayer? {
    return layer as? NeumorphicLayer
  }
  public override class var layerClass: AnyClass {
    return NeumorphicLayer.self
  }
  public override func layoutSubviews() {
    super.layoutSubviews()
    neumorphicLayer?.update()
  }
  public override var isHighlighted: Bool {
    didSet {
      if oldValue != isHighlighted {
        neumorphicLayer?.selected = isHighlighted
      }
    }
  }
  public override var isSelected: Bool {
    didSet {
      if oldValue != isSelected {
        neumorphicLayer?.depthType = isSelected ? .concave : .convex
      }
    }
  }
}

/// `NeumorphicTableCell` is a subclass of UITableViewCell and it provides some
/// Neumorphism style design.
/// Access neumorphicLayer. Change effects via its properties.
public class NeumorphicTableCell: UITableViewCell, NeumorphicElementProtocol {
  private var _bg: NeumorphicView?

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = UIColor.clear
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  /// Change effects via its properties.
  public var neumorphicLayer: NeumorphicLayer? {
    if _bg == nil {
      _bg = NeumorphicView(frame: bounds)
      _bg?.neumorphicLayer?.owningView = self
      selectedBackgroundView = UIView()
      layer.masksToBounds = true
      backgroundView = _bg
    }
    return _bg?.neumorphicLayer
  }
  public override func layoutSubviews() {
    super.layoutSubviews()
    neumorphicLayer?.update()
  }
  public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    neumorphicLayer?.selected = highlighted
  }
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    neumorphicLayer?.selected = selected
  }
  public func depthTypeUpdated(to type: NeumorphicLayerDepthType) {
    if let l = _bg?.neumorphicLayer {
      layer.masksToBounds = l.depthType == .concave
    }
  }
}

public protocol NeumorphicElementProtocol : UIView {
  var neumorphicLayer: NeumorphicLayer? { get }
  func depthTypeUpdated(to type: NeumorphicLayerDepthType)
}

public extension NeumorphicElementProtocol {
  func depthTypeUpdated(to type: NeumorphicLayerDepthType) { }
}

public enum NeumorphicLayerCornerType: Int { case all, topRow, middleRow, bottomRow }

public enum NeumorphicLayerDepthType: Int { case concave, convex }

public class NeumorphicLayer: CALayer {
  private var _props: _NeumorphicLayerProps?
  public weak var owningView: NeumorphicElementProtocol?

  /// Default is 1.
  public var lightShadowOpacity: Float = 1 {
    didSet { if oldValue != lightShadowOpacity { setNeedsDisplay() } }
  }

  /// Default is 0.3.
  public var darkShadowOpacity: Float = 0.3 {
    didSet { if oldValue != darkShadowOpacity { setNeedsDisplay() } }
  }

  /// Optional. if it is nil (default), elementBackgroundColor will be used as element color.
  public var elementColor: CGColor? {
    didSet { if oldValue !== elementColor { setNeedsDisplay() } }
  }

  private var elementSelectedColor: CGColor?

  /// It will be used as base color for light/shadow.
  /// If elementColor is nil, elementBackgroundColor will be used as elementColor.
  public var elementBackgroundColor: CGColor = UIColor.white.cgColor {
    didSet { if oldValue !== elementBackgroundColor { setNeedsDisplay() } }
  }

  public var depthType: NeumorphicLayerDepthType = .convex {
    didSet {
      if oldValue != depthType {
        owningView?.depthTypeUpdated(to: depthType)
        setNeedsDisplay()
      }
    }
  }

  /// ".all" is for buttons. ".topRowm" ".middleRow" ".bottomRow" is for table cells.
  public var cornerType: NeumorphicLayerCornerType = .all {
    didSet { if oldValue != cornerType { setNeedsDisplay() } }
  }

  /// Default is 5.
  public var elementDepth: CGFloat = 5 {
    didSet { if oldValue != elementDepth { setNeedsDisplay() } }
  }

  /// Adding a very thin border on the edge of the element.
  public var edged: Bool = false {
    didSet { if oldValue != edged { setNeedsDisplay() } }
  }

  /// If set to true, show element highlight color. Animated.
  public var selected: Bool {
    get {
      return _selected
    }
    set {
      _selected = newValue
      let color = elementColor ?? elementBackgroundColor
      elementSelectedColor =
        UIColor(cgColor: color).getTransformedColor(saturation: 1, brightness: 0.9).cgColor
      _colorLayer?.backgroundColor = _selected ? elementSelectedColor : color
    }
  }

  private var _selected: Bool = false
  private var _colorLayer: CALayer?
  private var _shadowLayer: _ShadowLayer?
  private var _lightLayer: _ShadowLayer?
  private var _edgeLayer: _EdgeLayer?
  private var _darkSideColor: CGColor = UIColor.black.cgColor
  private var _lightSideColor: CGColor = UIColor.white.cgColor


  // MARK: Build Layers

  public override func display() {
    super.display()
    update()
  }

  public func update() {
    // check property update.
    let isBoundsUpdated: Bool = _colorLayer?.bounds != bounds
    var currentProps = _NeumorphicLayerProps()
    currentProps._cornerType = cornerType
    currentProps._depthType = depthType
    currentProps._edged = edged
    currentProps._lightShadowOpacity = lightShadowOpacity
    currentProps._darkShadowOpacity = darkShadowOpacity
    currentProps._elementColor = elementColor
    currentProps._elementBackgroundColor = elementBackgroundColor
    currentProps._elementDepth = elementDepth
    currentProps._cornerRadius = cornerRadius
    let isPropsNotChanged = _props == nil ? true : currentProps == _props!
    if !isBoundsUpdated && isPropsNotChanged {
      return
    }
    _props = currentProps

    // generate shadow color.
    let color = elementColor ?? elementBackgroundColor
    _lightSideColor = UIColor.white.cgColor
    _darkSideColor =
      UIColor(cgColor: elementBackgroundColor)
        .getTransformedColor(saturation: 0.1, brightness: 0).cgColor

    // add sublayers.
    if _colorLayer == nil {
      _colorLayer = CALayer()
      _colorLayer?.cornerCurve = .continuous
      _shadowLayer = _ShadowLayer()
      _lightLayer = _ShadowLayer()
      _edgeLayer = _EdgeLayer()
      insertSublayer(_edgeLayer!, at: 0)
      insertSublayer(_colorLayer!, at: 0)
      insertSublayer(_lightLayer!, at: 0)
      insertSublayer(_shadowLayer!, at: 0)
    }
    _colorLayer?.frame = bounds
    _colorLayer?.backgroundColor = _selected ? elementSelectedColor : color
    if depthType == .convex {
      masksToBounds = false
      _colorLayer?.removeFromSuperlayer()
      insertSublayer(_colorLayer!, at: 2)
      _colorLayer?.masksToBounds = true
      _shadowLayer?.masksToBounds = false
      _lightLayer?.masksToBounds = false
      _edgeLayer?.masksToBounds = false
    }
    else {
      masksToBounds = true
      _colorLayer?.removeFromSuperlayer()
      insertSublayer(_colorLayer!, at: 0)
      _colorLayer?.masksToBounds = true
      _shadowLayer?.masksToBounds = true
      _lightLayer?.masksToBounds = true
      _edgeLayer?.masksToBounds = true
    }

    // initialize sublayers.
    _shadowLayer?.initialize(
      bounds: bounds, mode: .darkSide, props: _props!, color: _darkSideColor)
    _lightLayer?.initialize(
      bounds: bounds, mode: .lightSide, props: _props!, color: _lightSideColor)

    if currentProps._edged {
      _edgeLayer?.initialize(bounds: bounds, props: _props!, color: _lightSideColor)
    }
    else {
      _edgeLayer?.reset()
    }

    // set corners and outer mask.
    switch cornerType {
    case .all:
      if depthType == .convex {
        _colorLayer?.cornerRadius = cornerRadius
      }
    case .topRow:
      maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
      if depthType == .convex {
        _colorLayer?.cornerRadius = cornerRadius
        _colorLayer?.maskedCorners = maskedCorners
        applyOuterMask(bounds: bounds, props: _props!)
      }
      else {
        mask = nil
      }
    case .middleRow:
      maskedCorners = []
      if depthType == .convex {
        applyOuterMask(bounds: bounds, props: _props!)
      }
      else {
        mask = nil
      }
    case .bottomRow:
      maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
      if depthType == .convex {
        _colorLayer?.cornerRadius = cornerRadius
        _colorLayer?.maskedCorners = maskedCorners
        applyOuterMask(bounds: bounds, props: _props!)
      }
      else {
        mask = nil
      }
    }
  }

  private func applyOuterMask(bounds: CGRect, props: _NeumorphicLayerProps) {
    let shadowRadius = props._elementDepth
    let extendWidth = shadowRadius * 2
    var maskFrame = CGRect()
    switch props._cornerType {
    case .all:
      return
    case .topRow:
      maskFrame = CGRect(
        x: -extendWidth,
        y: -extendWidth,
        width: bounds.size.width + extendWidth * 2,
        height: bounds.size.height + extendWidth)
    case .middleRow:
      maskFrame = CGRect(
        x: -extendWidth,
        y: 0,
        width: bounds.size.width + extendWidth * 2,
        height: bounds.size.height)
    case .bottomRow:
      maskFrame = CGRect(
        x: -extendWidth,
        y: 0,
        width: bounds.size.width + extendWidth * 2,
        height: bounds.size.height + extendWidth)
    }
    let maskLayer = CALayer()
    maskLayer.frame = maskFrame
    maskLayer.backgroundColor = UIColor.white.cgColor
    mask = maskLayer
  }
}

// MARK - Private

fileprivate struct _NeumorphicLayerProps {
  var _lightShadowOpacity: Float = 1
  var _darkShadowOpacity: Float = 0.3
  var _elementColor: CGColor?
  var _elementBackgroundColor: CGColor = UIColor.white.cgColor
  var _depthType: NeumorphicLayerDepthType = .convex
  var _cornerType: NeumorphicLayerCornerType = .all
  var _elementDepth: CGFloat = 5
  var _edged: Bool = false
  var _cornerRadius: CGFloat = 0

  static func == (lhs: _NeumorphicLayerProps, rhs: _NeumorphicLayerProps) -> Bool {
    return lhs._lightShadowOpacity == rhs._lightShadowOpacity &&
      lhs._darkShadowOpacity == rhs._darkShadowOpacity &&
      lhs._elementColor === rhs._elementColor &&
      lhs._elementBackgroundColor === rhs._elementBackgroundColor &&
      lhs._depthType == rhs._depthType &&
      lhs._cornerType == rhs._cornerType &&
      lhs._elementDepth == rhs._elementDepth &&
      lhs._edged == rhs._edged &&
      lhs._cornerRadius == rhs._cornerRadius
  }
}

fileprivate enum _ShadowLayerMode: Int { case lightSide, darkSide }

fileprivate class _ShadowLayerBase: CALayer {
  static let corners: [NeumorphicLayerCornerType: UIRectCorner] = [
    .all: [.topLeft, .topRight, .bottomLeft, .bottomRight],
    .topRow: [.topLeft, .topRight],
    .middleRow: [],
    .bottomRow: [.bottomLeft, .bottomRight]
  ]
  func setCorner(props: _NeumorphicLayerProps) {
    switch props._cornerType {
    case .all:
      cornerRadius = props._cornerRadius
      maskedCorners = [
        .layerMinXMinYCorner,
        .layerMaxXMinYCorner,
        .layerMinXMaxYCorner,
        .layerMaxXMaxYCorner]
    case .topRow:
      cornerRadius = props._cornerRadius
      maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    case .middleRow:
      cornerRadius = 0
      maskedCorners = []
    case .bottomRow:
      cornerRadius = props._cornerRadius
      maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
  }
}

fileprivate class _ShadowLayer: _ShadowLayerBase {
  private var _lightLayer: CALayer?

  func initialize(
    bounds: CGRect,
    mode: _ShadowLayerMode,
    props: _NeumorphicLayerProps,
    color: CGColor
  ) {
    cornerCurve = .continuous
    shouldRasterize = true
    rasterizationScale = UIScreen.main.scale
    if props._depthType == .convex {
      applyOuterShadow(bounds: bounds, mode: mode, props: props, color: color)
    }
    else { // .concave
      applyInnerShadow(bounds: bounds, mode: mode, props: props, color: color)
    }
  }

  func applyOuterShadow(
    bounds: CGRect,
    mode: _ShadowLayerMode,
    props: _NeumorphicLayerProps,
    color: CGColor
  ) {
    _lightLayer?.removeFromSuperlayer()
    _lightLayer = nil

    frame = bounds
    cornerRadius = 0
    maskedCorners = []
    masksToBounds = false
    mask = nil

    let shadowCornerRadius = props._cornerType == .middleRow ? 0 : props._cornerRadius

    // prepare shadow parameters.
    let shadowRadius = props._elementDepth
    let offsetWidth: CGFloat = shadowRadius / 2
    let cornerRadii: CGSize = props._cornerRadius <= 0
      ? CGSize.zero
      : CGSize(width: shadowCornerRadius - offsetWidth, height: shadowCornerRadius - offsetWidth)

    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 0
    if mode == .lightSide {
      shadowY = -offsetWidth
      shadowX = -offsetWidth
    }
    else {
      shadowY = offsetWidth
      shadowX = offsetWidth
    }

    setCorner(props: props)
    let corners = _ShadowLayer.corners[props._cornerType]!
    let extendHeight = max(props._cornerRadius, shadowCornerRadius)

    // add shadow.
    var shadowBounds = bounds
    switch props._cornerType {
    case .all:
      break
    case .topRow:
      shadowBounds = CGRect(
        x: bounds.origin.x,
        y: bounds.origin.y,
        width: bounds.size.width,
        height: bounds.size.height + extendHeight)
    case .middleRow:
      shadowY = 0
      shadowBounds = CGRect(
        x: bounds.origin.x,
        y: bounds.origin.y - extendHeight,
        width: bounds.size.width,
        height: bounds.size.height + extendHeight * 2)
    case .bottomRow:
      shadowBounds = CGRect(
        x: bounds.origin.x,
        y: bounds.origin.y - extendHeight,
        width: bounds.size.width,
        height: bounds.size.height + extendHeight)
    }

    let path: UIBezierPath = UIBezierPath(
      roundedRect: shadowBounds.insetBy(dx: offsetWidth, dy: offsetWidth),
        byRoundingCorners: corners,
        cornerRadii: cornerRadii)
    shadowPath = path.cgPath
    shadowColor = color
    shadowOffset = CGSize(width: shadowX, height: shadowY)
    shadowOpacity = mode == .lightSide ? props._lightShadowOpacity : props._darkShadowOpacity
    self.shadowRadius = shadowRadius
  }

  func applyInnerShadow(
    bounds: CGRect,
    mode: _ShadowLayerMode,
    props: _NeumorphicLayerProps,
    color: CGColor
  ) {
    let width = bounds.size.width
    let height = bounds.size.height
    frame = bounds

    // prepare shadow parameters
    let shadowRadius = props._elementDepth * 0.75

    let gap: CGFloat = 1

    let cornerRadii: CGSize = CGSize(
      width: props._cornerRadius + gap, height: props._cornerRadius + gap)
    let cornerRadiusInner = props._cornerRadius - gap
    let cornerRadiiInner: CGSize = CGSize(
      width: cornerRadiusInner, height: cornerRadiusInner)
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 0
    var shadowWidth: CGFloat = width
    var shadowHeight: CGFloat = height

    setCorner(props: props)
    let corners = _ShadowLayer.corners[props._cornerType]!
    switch props._cornerType {
    case .all:
      break
    case .topRow:
      shadowHeight += shadowRadius * 4
    case .middleRow:
      if mode == .lightSide {
        shadowWidth += shadowRadius * 3
        shadowHeight += shadowRadius * 6
        shadowY = -(shadowRadius * 3)
        shadowX = -(shadowRadius * 3)
      }
      else {
        shadowWidth += shadowRadius * 2
        shadowHeight += shadowRadius * 6
        shadowY -= (shadowRadius * 3)
      }
    case .bottomRow:
      shadowHeight += shadowRadius * 4
      shadowY = -shadowRadius * 4
    }

    // add shadow
    let shadowBounds = CGRect(x: 0, y: 0, width: shadowWidth, height: shadowHeight)
    var path: UIBezierPath
    var innerPath: UIBezierPath

    if props._cornerType == .middleRow {
      path = UIBezierPath(rect: shadowBounds.insetBy(dx: -gap, dy: -gap))
      innerPath = UIBezierPath(rect: shadowBounds.insetBy(dx: gap, dy: gap)).reversing()
    }
    else {
      path = UIBezierPath(roundedRect:shadowBounds.insetBy(dx: -gap, dy: -gap),
                          byRoundingCorners: corners,
                          cornerRadii: cornerRadii)
      innerPath = UIBezierPath(roundedRect: shadowBounds.insetBy(dx: gap, dy: gap),
                               byRoundingCorners: corners,
                               cornerRadii: cornerRadiiInner).reversing()
    }
    path.append(innerPath)

    shadowPath = path.cgPath
    masksToBounds = true
    shadowColor = color
    shadowOffset = CGSize(width: shadowX, height: shadowY)
    shadowOpacity = mode == .lightSide ? props._lightShadowOpacity : props._darkShadowOpacity
    self.shadowRadius = shadowRadius

    if mode == .lightSide {
      if _lightLayer == nil {
        _lightLayer = CALayer()
        addSublayer(_lightLayer!)
      }
      _lightLayer?.frame = bounds
      _lightLayer?.shadowPath = path.cgPath
      _lightLayer?.masksToBounds = true
      _lightLayer?.shadowColor = shadowColor
      _lightLayer?.shadowOffset = CGSize(width: shadowX, height: shadowY)
      _lightLayer?.shadowOpacity = props._lightShadowOpacity
      _lightLayer?.shadowRadius = shadowRadius
      _lightLayer?.shouldRasterize = true
    }

    // add mask to shadow.
    if props._cornerType == .middleRow {
      mask = nil
    }
    else {
      let maskLayer = _GradientMaskLayer()
      maskLayer.frame = bounds
      maskLayer.cornerType = props._cornerType
      maskLayer.shadowLayerMode = mode
      maskLayer.shadowCornerRadius = props._cornerRadius
      mask = maskLayer
    }
  }
}

fileprivate class _EdgeLayer: _ShadowLayerBase {
  func initialize(bounds: CGRect, props: _NeumorphicLayerProps, color: CGColor) {

    setCorner(props: props)
    let corners = _EdgeLayer.corners[props._cornerType]!

    cornerCurve = .continuous
    shouldRasterize = true
    frame = bounds

    var shadowY: CGFloat = 0
    var path: UIBezierPath
    var innerPath: UIBezierPath
    let edgeWidth: CGFloat = 0.75

    var edgeBounds = bounds
    let cornerRadii: CGSize = CGSize(width: props._cornerRadius, height: props._cornerRadius)
    let cornerRadiusEdge = props._cornerRadius - edgeWidth
    let cornerRadiiEdge: CGSize = CGSize(width: cornerRadiusEdge, height: cornerRadiusEdge)

    if props._depthType == .convex {

      switch props._cornerType {
      case .all:
        break
      case .topRow:
        edgeBounds = CGRect(
          x: bounds.origin.x,
          y: bounds.origin.y,
          width: bounds.size.width,
          height: bounds.size.height + 2)
      case .middleRow:
        edgeBounds = CGRect(
          x: bounds.origin.x,
          y: bounds.origin.y - 2,
          width: bounds.size.width,
          height: bounds.size.height + 4)
      case .bottomRow:
        edgeBounds = CGRect(
          x: bounds.origin.x,
          y: bounds.origin.y - 2,
          width: bounds.size.width,
          height: bounds.size.height + 2)
      }

      path = UIBezierPath(
        roundedRect: edgeBounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
      let innerPath = UIBezierPath(
        roundedRect: edgeBounds.insetBy(dx: edgeWidth, dy: edgeWidth),
        byRoundingCorners: corners, cornerRadii: cornerRadiiEdge).reversing()
      path.append(innerPath)
      shadowPath = path.cgPath
      shadowColor = color
      shadowOffset = CGSize.zero
      shadowOpacity = min(props._lightShadowOpacity * 1.5, 1)
      shadowRadius = 0
    }
    else {
      // shadow size and y position.
      if props._depthType == .concave {
        switch props._cornerType {
        case .all:
          break
        case .topRow:
          edgeBounds.size.height += 2
        case .middleRow:
          shadowY = -5
          edgeBounds.size.height += 10
        case .bottomRow:
          shadowY = -2
          edgeBounds.size.height += 2
        }
      }
      // shadow path.
      if props._cornerType == .middleRow {
        path = UIBezierPath(rect: edgeBounds)
        innerPath = UIBezierPath(
          rect: edgeBounds.insetBy(dx: edgeWidth, dy: edgeWidth)).reversing()
      }
      else {
        path = UIBezierPath(
          roundedRect: edgeBounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
        innerPath = UIBezierPath(
          roundedRect: edgeBounds.insetBy(dx: edgeWidth, dy: edgeWidth),
          byRoundingCorners: corners, cornerRadii: cornerRadiiEdge).reversing()
      }
      path.append(innerPath)
      shadowPath = path.cgPath
      shadowColor = color
      shadowOffset = CGSize(width: 0, height: shadowY)
      shadowOpacity = min(props._lightShadowOpacity * 1.5, 1)
      shadowRadius = 0
    }
  }
  func reset() {
    shadowPath = nil
    shadowOffset = CGSize.zero
    shadowOpacity = 0
    frame = CGRect()
  }
}

fileprivate class _GradientMaskLayer: CALayer {
  required override init() {
    super.init()
    needsDisplayOnBoundsChange = true
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  required override init(layer: Any) {
    super.init(layer: layer)
  }

  var cornerType: NeumorphicLayerCornerType = .all
  var shadowLayerMode: _ShadowLayerMode = .lightSide
  var shadowCornerRadius: CGFloat = 0

  private func getTopRightCornerRect(size: CGSize, radius: CGFloat) -> CGRect {
    return CGRect(x: size.width - radius, y: 0, width: radius, height: radius)
  }
  private func getBottomLeftCornerRect(size: CGSize, radius: CGFloat) -> CGRect {
    return CGRect(x: 0, y: size.height - radius, width: radius, height: radius)
  }

  override func draw(in ctx: CGContext) {
    let rectTR = getTopRightCornerRect(size: frame.size, radius: shadowCornerRadius)
    let rectTR_BR = CGPoint(x: rectTR.maxX, y: rectTR.maxY)
    let rectBL = getBottomLeftCornerRect(size: frame.size, radius: shadowCornerRadius)
    let rectBL_BR = CGPoint(x: rectBL.maxX, y: rectBL.maxY)

    let color = UIColor.black.cgColor

    guard let gradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: [color, UIColor.clear.cgColor] as CFArray,
      locations: [0, 1]) else { return }

    if cornerType == .all {
      if shadowLayerMode == .lightSide {
        if frame.size.width > shadowCornerRadius * 2 && frame.size.height > shadowCornerRadius * 2 {
          ctx.setFillColor(color)
          ctx.fill(CGRect(
            x: shadowCornerRadius,
            y: shadowCornerRadius,
            width: frame.size.width - shadowCornerRadius,
            height: frame.size.height - shadowCornerRadius)
          )
        }
        ctx.saveGState()
        ctx.addRect(rectTR)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: rectTR_BR, end: rectTR.origin, options: [])
        ctx.restoreGState()
        ctx.saveGState()
        ctx.addRect(rectBL)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: rectBL_BR, end: rectBL.origin, options: [])
        ctx.restoreGState()
      }
      else {
        if frame.size.width > shadowCornerRadius * 2 && frame.size.height > shadowCornerRadius * 2 {
          ctx.setFillColor(color)
          ctx.fill(CGRect(
            x: 0,
            y: 0,
            width: frame.size.width - shadowCornerRadius,
            height: frame.size.height - shadowCornerRadius)
          )
        }
        ctx.saveGState()
        ctx.addRect(rectTR)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: rectTR.origin, end: rectTR_BR, options: [])
        ctx.restoreGState()
        ctx.saveGState()
        ctx.addRect(rectBL)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: rectBL.origin, end: rectBL_BR, options: [])
        ctx.restoreGState()
      }
    }
    else if cornerType == .topRow {
      if shadowLayerMode == .lightSide {
        ctx.setFillColor(color)
        ctx.fill(CGRect(
          x: frame.size.width - shadowCornerRadius,
          y: shadowCornerRadius,
          width: frame.size.width,
          height: frame.size.height - shadowCornerRadius)
        )
        ctx.saveGState()
        ctx.addRect(rectTR)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: rectTR_BR, end: rectTR.origin, options: [])
        ctx.restoreGState()
      }
      else {
        ctx.setFillColor(color)
        ctx.fill(CGRect(
          x: 0,
          y: 0,
          width: frame.size.width - shadowCornerRadius,
          height: frame.size.height)
        )
        ctx.saveGState()
        ctx.addRect(rectTR)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: rectTR.origin, end: rectTR_BR, options: [])
        ctx.restoreGState()
      }
    }
    else if cornerType == .bottomRow {
      ctx.setFillColor(color)
      if shadowLayerMode == .lightSide {
        ctx.fill(CGRect(
          x: shadowCornerRadius,
          y: 0,
          width: frame.size.width - shadowCornerRadius,
          height: frame.size.height)
        )
        ctx.saveGState()
        ctx.addRect(rectBL)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: rectBL_BR, end: rectBL.origin, options: [])
        ctx.restoreGState()
      }
      else {
        ctx.fill(CGRect(
          x: 0,
          y: 0,
          width: shadowCornerRadius,
          height: frame.size.height - shadowCornerRadius)
        )
        ctx.saveGState()
        ctx.addRect(rectBL)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: rectBL.origin, end: rectBL_BR, options: [])
        ctx.restoreGState()
      }
    }
  }
}

// MARK - Extension

extension UIColor {
  public convenience init(RGB: Int) {
    var rgb = RGB
    rgb = rgb > 0xffffff ? 0xffffff : rgb
    let r = CGFloat(rgb >> 16) / 255.0
    let g = CGFloat(rgb >> 8 & 0x00ff) / 255.0
    let b = CGFloat(rgb & 0x0000ff) / 255.0
    self.init(red: r, green: g, blue: b, alpha: 1.0)
  }
  public func getTransformedColor(saturation: CGFloat, brightness: CGFloat) -> UIColor {
    var hsb = getHSBColor()
    hsb.s *= saturation
    hsb.b *= brightness
    if hsb.s > 1 { hsb.s = 1 }
    if hsb.b > 1 { hsb.b = 1 }
    return hsb.uiColor
  }
  private func getHSBColor() -> HSBColor {
    var h: CGFloat = 0
    var s: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return HSBColor(h: h, s: s, b: b, alpha: a)
  }
}

private struct HSBColor {
  var h: CGFloat
  var s: CGFloat
  var b: CGFloat
  var alpha: CGFloat
  init(h: CGFloat, s: CGFloat, b: CGFloat, alpha: CGFloat) {
    self.h = h
    self.s = s
    self.b = b
    self.alpha = alpha
  }
  var uiColor: UIColor {
    get {
      return UIColor(hue: h, saturation: s, brightness: b, alpha: alpha)
    }
  }
}
