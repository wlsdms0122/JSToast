# JSToast
`JSToast` is fully customizable toast package.

- [JSToast](#jstoast)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Pacakge Manager](#swift-pacakge-manager)
- [Getting Started](#getting-started)
  - [Position](#position)
  - [Animation](#animation)
  - [Advanced Usage](#advanced-usage)
  - [SwiftUI Support](#swiftui-support)
- [Contribution](#contribution)
- [License](#license)

# Requirements
- iOS 13.0+
# Installation
## Swift Pacakge Manager
```swift
dependencies: [
    .package(url: "https://github.com/wlsdms0122/JSToast", exact: "2.6.2")
]
```

# Getting Started
```swift
let toastView = UILabel()
toastView.backgroundColor = .black.withAlphaComponent(0.6)
toastView.text = "Hello World!"
toastView.textColor = .white
                
let toast = Toast(toastView)
```

In order to display a toast, we need to first create a view.
This view is created using the Toast initializer and will be used to display the toast.

> ⚠️ It is recommended that the toast view has its own size.

```swift
toast.show(
    withDuration: 3,
    layouts: [
        .inside(of: .bottom), 
        .center(of: .x)
    ]
)
```  

Once you have defined a toast, you can display or hide it on the screen using the show function. 

The show function has many optional parameters, but most of them have default values, making it easy to display a toast message with just a few lines of code.

| <image src="https://user-images.githubusercontent.com/11141077/231676017-c16cdeea-7845-4186-829b-30a80df313f8.gif" /> |
|-|

## Position
```swift
extension Layout {
    static func inside(_ anchor: Anchor, of target: UIView? = nil, offset: CGFloat = 0, ignoresSafeArea: Bool = false) -> Self
    static func outside(_ anchor: Anchor, of target: UIView? = nil, offset: CGFloat = 0) -> Self
    static func center(_ axis: Axis, of target: UIView? = nil, offset: CGFloat = 0, ignoresSafeArea: Bool = false) -> Self
    static func width(_ width: CGFloat) -> Self
    static func height(_ height: CGFloat) -> Self
}
```

`JSToast` offers multiple layout types, including `inside` and `outside` layouts that support a `target` parameter.

When you set the `target` parameter to `nil`, the `target` is the `layer`(if `layer` also `nil`, it to be `window`).

By using `inside` or `outside` layouts with the `target` parameter, you can position the toast `inside` or `outside` of a specific view.


```swift
toast.show(
    withDuration: 3,
    layouts: [
        .outside(of: .top, of: showButton, offset: 8),
        .center(of: .x)
    ]
)
```
| <image src="https://user-images.githubusercontent.com/11141077/231676008-c9f64fe0-ccc8-40ef-b3f7-6394cc41e80d.gif" /> |
|-|

## Animation
```swift
extension ToastAnimation {
    static func fadeIn(duration: TimeInterval, curve: UIView.AnimationCurve = .easeInOut) -> Self
    static func fadeOut(duration: TimeInterval, curve: UIView.AnimationCurve = .easeInOut) -> Self
    static func slideIn(duration: TimeInterval, direction: Direction, curve: UIView.AnimationCurve = .easeInOut, offset: CGFloat? = nil) -> Self
    static func slideOut(duration: TimeInterval, direction: Direction, curve: UIView.AnimationCurve = .easeInOut, offset: CGFloat? = nil) -> Self
}
```

You can set default animations or create your custom animation for the toast to control how it appears and disappears from the screen. The `showAnimation` and `hideAnimation` parameters of the show function can be used to define the animations for the toast.

```swift
toast.show(
    withDuration: 3,
    layouts: [
        .center(.x),
        .outside(.bottom, of: view, offset: 8)
    ],
    showAnimation: .slideIn(duration: 0.3, direction: .up),
    hideAnimation: .slideOut(duration: 0.3, direction: .down)
)
```

| <image src="https://user-images.githubusercontent.com/11141077/231681764-b60dfadb-d2f4-4210-b31f-92732fefa20b.gif" /> |
|-|

If you want to create your custom animation, you can implement the `ToastAnimation` protocol, which requires the implementation of two functions.

```swift
protocol ToastAnimation {
    func play(_ view: UIView, completion: @escaping (Bool) -> Void)
    func cancel(completion: @escaping () -> Void)
}
```

## Advanced Usage
While the `Toast` class can be used standalone, it may be more beneficial to creating a custom manager like `Toaster` if you want to perform more complex tasks or limit your application system operations.

`Toaster` is a custom class that manages the `Toast` instances to make sure that only one toast is visible at a time. This can help to enhance the user experience and prevent too many toasts from being displayed simultaneously.

By creating a custom manager like `Toaster`, developers can control the behavior of the toast within their application and create custom workflows that best suit their project's requirements.

## SwiftUI Support
`JSToast` also supports `SwiftUI`. You can use the `.toast()` modifier to add a toast message to your view.

```swift
struct SampleView: View {
    var body: some View {
        Button("🍞 Show Toast") {
            isShow = true
        }
            .toast(
                $isShow,
                duration: 3,
                layout: [
                    .center(of: .x),
                    .inside(of: .bottom)
                ]
            ) {
                Text("Hello World")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
            }
    }

    @State
    var isShow: Bool = false
}
```

In the above example, the .inside(of: .bottom) layout is automatically set based on the button. 

The `.toast()` modifier automatically assigns the target view for the toast.

```swift
struct SampleView: View {
    var body: some View {
        ToastContainer { layer in
            Button("🍞 Show Toast") {
                isShow = true
            }
                .toast(
                    $isShow,
                    duration: 3,
                    layout: [
                        .center(of: .x),
                        .inside(of: .bottom)
                    ],
                    layer: layer
                ) { ... }
        }
    }

    @State
    var isShow: Bool = false
}
```

If you want to set the layer manually, you can use `ToastContainer`, which receives the layer as a closure parameter.

# Contribution

Any ideas, issues, opinions are welcome.

# License

`JSToast` is available under the MIT license.
