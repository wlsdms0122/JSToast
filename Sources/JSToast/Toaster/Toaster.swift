//
//  Toaster.swift
//  JSToaster
//
//  Created by jsilver on 2021/10/02.
//

import UIKit

open class Toaster {
    // MARK: - Property
    public static let shared = Toaster()
    
    private var toast: Toast?
    
    // MARK: - Initializer
    private init() { }
    
    // MARK: - Public
    /// Show toast.
    ///
    /// - parameters:
    ///   - duration: The duration informing that the time the toast is exposed. Default value is `nil`, it mean toast doesn't hide.
    ///   - layouts: The positions list describe where toast view layouted.
    ///   - layer: The view to which the toast view should be attached. The default value is `nil`. If the value is nil, the toast view will be attached to the topmost window.
    ///   - boundary: The boundary insets is maximum layout guideline. Default value is `.zero`.
    ///     The boundary work on safe area default. If you want to change base to superview, sset `ignoresSafeArea` parameter to `true`.
    ///   - ignoresSafeArea: Ignores safe area to set boundary. Default value is `false`.
    ///   - scene: The scene to which the toast will be attached. The default value is `nil`. If the value is `nil`, then the toast will be attached to the scene whose state is currently in the foreground and active.
    ///   - showAnimation: The animation to be played when appearing. Default value is `fadeIn(duration: 0.3)`.
    ///   - hideAnimation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - shown: The shown completion handler with success. Default value is `nil`.
    ///   - hidden: The hidden completion handler with success. Default value is `nil`.
    open func showToast(
        _ toast: Toast,
        withDuration duration: TimeInterval? = nil,
        layouts: [Layout],
        layer: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        ignoresSafeArea: Bool = false,
        scene: UIWindowScene? = nil,
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        cancelAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) {
        // Hide showing toast.
        hideToast(animation: cancelAnimation)
        
        // Show toast.
        self.toast = toast.show(
            layouts: layouts,
            layer: layer,
            boundary: boundary,
            ignoresSafeArea: ignoresSafeArea,
            scene: scene,
            showAnimation: showAnimation,
            shown: shown
        )
        
        if let duration = duration {
            // Set timer if duration set.
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self, weak toast] _ in
                guard self?.toast == toast else { return }
                toast?.hide(animation: hideAnimation, completion: hidden)
                self?.toast = nil
            }
        }
    }
    
    /// Hide showing toast.
    ///
    /// - parameters:
    ///   - animation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - completion: The hidden completion handler with success. Default value is `nil`.
    open func hideToast(
        animation: ToastAnimation = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        let toast = self.toast
        self.toast = nil
        
        toast?.hide(animation: animation, completion: completion)
    }
    
    // MARK: - Private
}
