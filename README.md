# JSToast
`JSToast` is fully customizable toast package.

- [JSToast](#jstoast)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Pacakge Manager](#swift-pacakge-manager)
- [Getting Started](#getting-started)
  - [Layout](#position)
  - [Animation](#animation)
    - [Custom Animation](#custom-animation)
  - [Advanced Usage](#advanced-usage)
  - [SwiftUI Support](#swiftui-support)
- [Contribution](#contribution)
- [License](#license)

# Requirements
- iOS 14.0+

# Installation
## Swift Pacakge Manager
```swift
dependencies: [
    .package(url: "https://github.com/wlsdms0122/JSToast.git", from: "2.0.0")
]
```

# Getting Started
To display a toast, you first need to create a view. This view is created using the `Toast` initializer and will be used to display the toast message.

```swift
let toastView = UILabel()
toastView.backgroundColor = .black.withAlphaComponent(0.6)
toastView.text = "Hello World!"
toastView.textColor = .white
                
let toast = Toast(toastView)
```

> ⚠️ It is recommended that the toast view has its own size.

Once you have defined a toast, you can display or hide it on the screen using the show function.

```swift
toast.show(
    withDuration: 3,
    layouts: [
        .center(of: .x),
        .inside(of: .bottom, of: button, offset: 16)
    ]
)
```  

The show function has many optional parameters, but most of them have default values. This makes it easy to display a toast message with just a few lines of code.

<image src="https://github.com/user-attachments/assets/02d011e3-1b7f-4454-a709-abddbf199b03" width=300 />

## Layout
`JSToast` offers multiple layout types for positioning your toast messages. These layouts include options to position the toast inside or outside a target view, or to center it along a specific axis.

Below are the available layout methods.

```swift
extension Layout {
    /// Positions the toast inside the specified anchor of the target view.
    static func inside(_ anchor: Anchor, of target: UIView? = nil, offset: CGFloat = 0, ignoresSafeArea: Bool = false) -> Self
    /// Positions the toast outside the specified anchor of the target view.
    static func outside(_ anchor: Anchor, of target: UIView? = nil, offset: CGFloat = 0) -> Self
    /// Centers the toast along the specified axis of the target view.
    static func center(_ axis: Axis, of target: UIView? = nil, offset: CGFloat = 0, ignoresSafeArea: Bool = false) -> Self
    /// Sets a fixed width for the toast.
    static func width(_ width: CGFloat) -> Self
    /// Sets a fixed height for the toast.
    static func height(_ height: CGFloat) -> Self
}
```

When specifying a layout, the `target` parameter determines the view relative to which the toast will be positioned. If the `target` parameter is not specified (i.e., set to nil), the toast will reference its `layer` for positioning. If the `layer` is also nil, the toast will default to referencing the `window` for its positioning.

By using `inside` or `outside` layouts with the `target` parameter, you can position the toast relative to a specific view.

```swift
toast.show(
    withDuration: 3,
    layouts: [
        .center(of: .x),
        .outside(of: .top, of: button, offset: 16)
    ]
)
```
<image src="https://github.com/user-attachments/assets/39f80546-2f39-496f-8f36-f00ca9acd285" width=300 />

## Animation
`JSToast` allows you to set default animations or create custom animations for controlling how the toast appears and disappears from the screen. The `showAnimation` and `hideAnimation` parameters of the show function are used to define these animations.

```swift
extension ToastAnimation {
    static func fadeIn(duration: TimeInterval, curve: UIView.AnimationCurve = .easeInOut) -> Self
    static func fadeOut(duration: TimeInterval, curve: UIView.AnimationCurve = .easeInOut) -> Self
    static func slideIn(duration: TimeInterval, direction: Direction, curve: UIView.AnimationCurve = .easeInOut, offset: CGFloat? = nil) -> Self
    static func slideOut(duration: TimeInterval, direction: Direction, curve: UIView.AnimationCurve = .easeInOut, offset: CGFloat? = nil) -> Self
}
```

You can easily apply animations to your toast messages.

Below is an example where a toast slides in from left and out to the right.

```swift
toast.show(
    withDuration: 3,
    layouts: [
        .center(.x),
        .outside(.bottom, of: button, offset: 16)
    ],
    showAnimation: .slideIn(duration: 0.3, direction: .right),
    hideAnimation: .slideOut(duration: 0.3, direction: .right)
)
```

<image src="https://github.com/user-attachments/assets/b49a76e5-40fb-4b08-9801-3c21f62b2209" width=300 />

### Custom Animation
If you want to create a custom animation, you can implement the `ToastAnimation` protocol. This requires the implementation of two functions.

```swift
protocol ToastAnimation {
    func play(_ view: UIView, completion: @escaping (Bool) -> Void)
    func cancel(completion: @escaping () -> Void)
}
```

To create custom animations, reference the default animations for guidance.

## Advanced Usage
While the `Toast` class can be used on its own, creating a custom manager like `Toaster` can be more beneficial for performing complex tasks or limiting operations within your application.

`Toaster` is a custom class that manages `Toast` instances to ensure that only one toast is visible at a time. This enhances the user experience by preventing multiple toasts from being displayed simultaneously.

By implementing a custom manager like `Toaster`, developers can control the behavior of toasts within their application, allowing for the creation of custom workflows that best suit their project's requirements.

## SwiftUI Support
`JSToast` supports `SwiftUI` through the `ToastReader` component. While the interface provided is similar to the `UIKit` version, it is implemented in a way that is more suitable for `SwiftUI`.

```swift
struct SampleView: View {
    var body: some View {
        ToastReader { toaster in
            Button("Show Toast") {
                isShow = true
            }
                .toastTarget("button")
                .onChange(of: isShow) { isShow in
                    if isShow {
                        toaster.show(
                            withDuration: 3,
                            layouts: [
                                .center(.x),
                                .outside(.bottom, offset: 16)
                            ],
                            target: "button"
                        ) {
                            Text("Hello World")
                                .foregroundStyle(.white)
                                .background(.black.opacity(0.6))
                        }
                    } else {
                        toaster.hide()
                    }
                }
        }
    }

    @State
    var isShow: Bool = false
}
```

If you want the toast to be part of a specific view hierarchy rather than appearing at the top level (window), you can use `ToastLayer`. This allows you to manage the positioning of the toast within a particular part of your view hierarchy.

```swift
struct SampleView: View {
    var body: some View {
        ToastReader { toaster in
            ToastLayer("toastLayer") {
                Button("Show Toast") {
                    isShow = true
                }
                    .toastTarget("button")
            }
                .onChange(of: isShow) { isShow in
                    if isShow {
                        toaster.show(
                            withDuration: 3,
                            layouts: [
                                .center(.x),
                                .outside(.bottom, offset: 16)
                            ],
                            target: "button",
                            layer: "toastLayer"
                        ) {
                            Text("Hello World")
                                .foregroundStyle(.white)
                                .background(.black.opacity(0.6))
                        }
                    } else {
                        toaster.hide()
                    }
                }
        }
    }

    @State
    var isShow: Bool = false
}
```

You can also easily display a `.toast()` using the toast view modifier. For more details, check out the code examples.

# Contribution

Any ideas, issues, opinions are welcome.

# License

`JSToast` is available under the MIT license.
