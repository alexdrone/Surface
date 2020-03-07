# ＳＵＲＦＡＣＥ [![Swift](https://img.shields.io/badge/swift-5.1-orange.svg?style=flat)](#)

**Neumorphic** shadow example:

```swift

let view = SurfaceView()
view.frame = ...
view.cornerRadius = ...
view.shadowLayer.shadow = Shadow(preset: .convex1)
view.shadowLayer.useDeviceMotionToCastShadow = true
addSubview(view)
```

The cast shadows moves accordingly to the device horizontal axis.

<img src="docs_/button.gif" width=140 alt="screen" />
