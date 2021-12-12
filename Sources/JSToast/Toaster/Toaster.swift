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
        positions: [Toast.Position],
        target: UIView? = nil,
        layer: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        showAnimator: Toast.Animator = .fadeIn(duration: 0.3),
        hideAnimator: Toast.Animator = .fadeOut(duration: 0.3),
        cancelAnimator: Toast.Animator = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) {
        // Hide showing toast.
        hideToast(animation: cancelAnimator)
        
        // Show toast.
        toast.show(
            layouts: positions,
            target: target,
            layer: layer,
            boundary: boundary,
            showAnimation: showAnimator,
            shown: shown
        )
        
        if let duration = duration {
            // Set timer if duration set.
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak toast] _ in
                toast?.hide(animation: hideAnimator, completion: hidden)
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
        animation: Toast.Animator = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        toast?.hide(animation: animation, completion: completion)
    }
    
    // MARK: - Private
}
