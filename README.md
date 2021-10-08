# JSToaster
`JSToaster` is fully customizable toast package.

# Installation
### Swift Pacakge Manager
```swift
dependencies: [
    .package(name: "JSToast", path: "https://github.com/wlsdms0122/JSToast", from: "1.0.0")
]
```

# How to use
When you want to show toast, first you instantiate `Toast`.

```swift
let toastView = UILabel()
toastView.backgroundColor = .black.withAlphaComponent(0.6)
toastView.layer.cornerRadius = 16
toastView.text = "Hello World!"
toastView.textColor = .white
                
let toast = Toast(toastView)
```

`Toast` need a view. It can be any `UIView` instance.

⚠️ It is recommended that the toast view has its own size.

```swift
toast.show(
    withDuration: 3,
    at: [.inside(of: .bottom), .center(of: .x)]
)
```  

`Toast` has `show` & `hide` functions.

`show` function handle many parameters. but most of it has default value. 

<img src="https://user-images.githubusercontent.com/11141077/136569217-2651f483-4acb-40fa-88e7-846e75ba6a72.gif" width=300 />

## Position
`Toast`'s `show` function receive `Position` parameter.

It describe about where the toast will appear.

```swift
extension Toast.Position {
    // Toast will locate inside of target view with offset.
    public static func inside(_ offset: CGFloat = 0, of anchor: Anchor) -> Self {
        .init(layout: InsideLayout(offset, of: anchor))
    }
    
    // Toast will locate outside of target view with offset.
    public static func outside(_ offset: CGFloat = 0, of anchor: Anchor) -> Self {
        .init(layout: OutsideLayout(offset, of: anchor))
    }
    
    // Toast will locate center of axis of target view with offset.
    public static func center(_ offset: CGFloat = 0, of axis: Axis) -> Self {
        .init(layout: CenterLayout(offset, of: axis))
    }
}
```

And let's see toast `show` function again.

```swift
toast.show(
    withDuration: 3,
    // `Toast` will show `someView`'s inside of bottom & `someView`'s center of x axis. 
    at: [.inside(of: .bottom), .center(of: .x)],
    of: someView
)
```

<img src="https://user-images.githubusercontent.com/11141077/136571290-fd792ec8-51c8-4929-a4b5-a6ffdd9e635a.gif" width=300 />

In actually `Toast` reflect to base layer and attached.

## Animation
You can set animations about how to appear the toast, how to disappear the toast.

```swift
toast.show(
    withDuration: 3,
    // `Toast` will show `someView`'s inside of bottom & `someView`'s center of x axis. 
    at: [.inside(of: .bottom), .center(of: .x)],
    show: .fadeIn(duration: 0.3),
    hide: .fadeOut(duration: 0.3)
)
```

`JSToast` serve default animations below.

```swift
extension Toast.Animation {
    public static func fadeIn(duration: TimeInterval) -> Self {
        .init(animator: FadeInAnimator(duration: duration))
    }
    
    public static func fadeOut(duration: TimeInterval) -> Self {
        .init(animator: FadeOutAnimator(duration: duration))
    }
    
    public static func slideIn(duration: TimeInterval, direction: Direction, offset: CGFloat? = nil) -> Self {
        .init(animator: SlideInAnimator(duration: duration, direction: direction, offset: offset))
    }
    
    public static func slideOut(duration: TimeInterval, direction: Direction, offset: CGFloat? = nil) -> Self {
        .init(animator: SlideOutAnimator(duration: duration, direction: direction, offset: offset))
    }
}
```

If you want to customize toast animation, define animation through adapt `Animator`
   
```swift
public protocol Animator {
    func play(_ view: UIView, completion: @escaping (Bool) -> Void)
}
```

And add your animation into extension like this.

```swift
extension Toast.Animation {
    public static func your_in_animation(duration: TimeIntervale) -> Self {
        .init(animator: YourInAnimation(duration: duration))
    }
    
    public static func your_out_animation(duration: TimeIntervale) -> Self {
        .init(animator: YourOutAnimation(duration: duration))
    }
}
```
```swift
toast.show(
    withDuration: 3, 
    at: [.inside(of: .bottom), .center(of: .x)],
    show: .your_in_animation(duration: 0.3),
    hide: .your_out_animation(duration: 0.3),
)
```

## Advanced
`Toast` is work standalone. But if you want to more complex work or limit operations for your application system, I recommended to create own `Toast` manager like `Toaster`.

`Toaster` is manage `Toast` to ensure that showing only one.

# Contribution

Any ideas, issues, opinions are welcome.

# License

`JSToast` is available under the MIT license.
