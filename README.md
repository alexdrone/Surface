# ＳＵＲＦＡＣＥ [![Swift](https://img.shields.io/badge/swift-5.1-orange.svg?style=flat)](#)

Neumorphic shadow example:
```swift

let view = SurfaceView()
view.frame = ...
view.cornerRadius = ...
view.shadowLayer.shadow = Shadow(preset: .depth1)
view.shadowLayer.useDeviceMotionToCastShadow = true
addSubview(view)
```

<img src="docs_/button.gif" width=70 alt="screen" />
