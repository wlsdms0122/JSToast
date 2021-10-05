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
    open func showToast(
        _ toast: Toast,
        withDuration duration: TimeInterval? = nil,
        at positions: [Toast.Position],
        of target: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        show showAnimation: Toast.Animation = .fadeIn(duration: 0.3),
        hide hideAnimation: Toast.Animation = .fadeOut(duration: 0.3),
        cancel cancelAnimation: Toast.Animation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) {
        hideToast(animation: cancelAnimation)
        
        toast.show(
            at: positions,
            of: target,
            boundary: boundary,
            show: showAnimation,
            shown: shown
        )
                
        if let duration = duration {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak toast] _ in
                toast?.hide(animation: hideAnimation, completion: hidden)
            }
        }
        
        self.toast = toast
    }
    
    open func hideToast(
        animation: Toast.Animation = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        toast?.hide(animation: animation, completion: completion)
    }
    
    // MARK: - Private
}
