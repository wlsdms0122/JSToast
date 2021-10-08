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
    
    private weak var toast: Toast?
    
    // MARK: - Initializer
    private init() { }
    
    // MARK: - Public
    /// Show toast.
    ///
    /// - parameters:
    ///   - toast: The toast will show.
    ///   - duration: The duration informing that the time the toast is exposed. Default value is `nil`, it mean toast doesn't hide.
    ///   - positions: The positions list describe where toast view layouted.
    ///   - target: The target is the reference for where the toast will be shown. Default value is `nil`, if value is `nil`, the target is same as `layer`.
    ///   - layer: The layer where the toast will attach. Default value is `nil`. If value is `nil`, the toast will attach to key window.
    ///   - boundary: The boundary insets is maximum layout guideline. Default value is `.zero`.
    ///   - showAnimation: The animation to be played when appearing. Default value is `fadeIn(duration: 0.3)`.
    ///   - hideAnimation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - cancelAnimation: The animation to be played when cancelled. Default value is `fadeOut(duration: 0.3)`.
    ///   - shown: The shown completion handler with success. Default value is `nil`.
    ///   - hidden: The hidden completion handler with success. Default value is `nil`.
    open func showToast(
        _ toast: Toast,
        withDuration duration: TimeInterval? = nil,
        at positions: [Toast.Position],
        of target: UIView? = nil,
        base layer: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        show showAnimation: Toast.Animation = .fadeIn(duration: 0.3),
        hide hideAnimation: Toast.Animation = .fadeOut(duration: 0.3),
        cancel cancelAnimation: Toast.Animation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) {
        // Hide showing toast.
        hideToast(animation: cancelAnimation)
        
        // Show toast.
        toast.show(
            at: positions,
            of: target,
            base: layer,
            boundary: boundary,
            show: showAnimation,
            shown: shown
        )
        
        if let duration = duration {
            // Set timer if duration set.
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak toast] _ in
                toast?.hide(animation: hideAnimation, completion: hidden)
            }
        }
        
        // Store toast that weak reference.
        self.toast = toast
    }
    
    /// Hide showing toast.
    ///
    /// - parameters:
    ///   - animation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - completion: The hidden completion handler with success. Default value is `nil`.
    open func hideToast(
        animation: Toast.Animation = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        toast?.hide(animation: animation, completion: completion)
    }
    
    // MARK: - Private
}
