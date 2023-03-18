# JSToast
`JSToast` is fully customizable toast package.

- [JSToast](#jstoast)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Pacakge Manager](#swift-pacakge-manager)
- [How to use](#how-to-use)
  - [Position](#position)
  - [Animation](#animation)
  - [Advanced](#advanced)
  - [SwiftUI support](#swiftui-support)
- [Contribution](#contribution)
- [License](#license)

# Requirements
- iOS 13.0+ (needs 14.0+ on `SwiftUI`)
# Installation
## Swift Pacakge Manager
```swift
dependencies: [
    .package(url: "https://github.com/wlsdms0122/JSToast", exact: "2.2.0")
]
```

# How to use
```swift
let toastView = UILabel()
toastView.backgroundColor = .black.withAlphaComponent(0.6)
toastView.layer.cornerRadius = 16
toastView.text = "Hello World!"
toastView.textColor = .white
                
let toast = Toast(toastView)
```

When you want to show a toast, you first instantiate the `Toast` class. 

You also need to pass a `UIView` instance as the view on which the toast will be displayed.

⚠️ It is recommended that the toast view has its own size.

```swift
toast.show(
    withDuration: 3,
    layouts: [
        .inside(of: .bottom), 
        .center(of: .x)
    ]
)
```  

`Toast` has `show` & `hide` functions.

`show` function handle many parameters. but most of it has default value. 

<img src="https://user-images.githubusercontent.com/11141077/136569217-2651f483-4acb-40fa-88e7-846e75ba6a72.gif" width=300 />

## Position
```swift
public extension Layout where Self == InsideLayout {
    static func inside(_ offset: CGFloat = 0, of anchor: Anchor) -> Self {
        InsideLayout(offset, of: anchor)
    }
}

public extension Layout where Self == OutsideLayout {
    static func outside(_ offset: CGFloat = 0, of anchor: Anchor) -> Self {
        OutsideLayout(offset, of: anchor)
    }
}

public extension Layout where Self == CenterLayout {
    static func center(_ offset: CGFloat = 0, of axis: Axis) -> Self {
        CenterLayout(offset, of: axis)
    }
}
```

To set the position of the `Toast`, the `show` method uses the `layouts` parameter.

It describes the position where the toast will be displayed.


```swift
// `Toast` will show `someView`'s inside of bottom & `someView`'s center of x axis.
toast.show(
    withDuration: 3,
    layouts: [
        .outside(of: .top), 
        .center(of: .x)
    ],
    target: showButton
)
```
<img src="https://user-images.githubusercontent.com/11141077/136571290-fd792ec8-51c8-4929-a4b5-a6ffdd9e635a.gif" width=300 />

And let's see toast `show` function again.

In actuality, the Toast is reflected onto a full-screen window and attached to it.

## Animation
```swift
public extension Animation where Self == FadeInAnimation {
    static func fadeIn(duration: TimeInterval) -> Self {
        FadeInAnimation(duration: duration)
    }
}

public extension Animation where Self == FadeOutAnimation {
    static func fadeOut(duration: TimeInterval) -> Self {
        FadeOutAnimation(duration: duration)
    }
}

public extension Animation where Self == SlideInAnimation {
    static func slideIn(duration: TimeInterval, direction: Direction, offset: CGFloat? = nil) -> Self {
        SlideInAnimation(duration: duration, direction: direction, offset: offset)
    }
}
```

You can set animations for the Toast to control how it appears and disappears.

The `JSToast` provides default animations for appearing and disappearing the toast.

```swift
toast.show(
    withDuration: 3,
    // `Toast` will show `someView`'s inside of bottom & `someView`'s center of x axis. 
    layouts: [
        .inside(of: .bottom),
        .center(of: .x)
    ],
    showAnimation: .fadeIn(duration: 0.3),
    hideAnimation: .fadeOut(duration: 0.3)
)
```

If you want to customize toast animation, define animation through adapt `Animation`
   
```swift
public protocol Animation {
    func play(_ view: UIView, completion: @escaping (Bool) -> Void)
}
```

## Advanced
`Toast` is work standalone. But if you want to more complex work or limit operations for your application system, I recommended to create own `Toast` manager like `Toaster`.

`Toaster` is manage `Toast` to ensure that showing only one.

## SwiftUI support
```swift
struct SampleView: View {
    var body: some View {
        Text("Hello World")
            .toast(
                $isShow,
                duration: 2,
                layout: [
                    .outside(of: .top),
                    .center(of: .x)
                ]
            ) {
                Text("Toast View")
                    .background(Color.blue)
            }
    }

    @State
    var isShow: Bool = false
}
```

You can use `JSToast` on `SwiftUI` using `.toast(_:layouts:)` view modifier.

All interface equal with `UIKit`. See more [How to use](#how-to-use) section.

# Contribution

Any ideas, issues, opinions are welcome.

# License

`JSToast` is available under the MIT license.
