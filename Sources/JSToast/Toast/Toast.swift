//
//  Toast.swift
//  JSToast
//
//  Created by jsilver on 2021/10/05.
//

import UIKit
import SwiftUI

public class Toast: Equatable {
    // MARK: - Property
    private static var scene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene) }
            .first { $0.activationState == .foregroundActive }
    }
    
    public let view: UIView
    private var window: UIWindow?
    private var constraints: [NSLayoutConstraint] = [] {
        didSet {
            NSLayoutConstraint.deactivate(oldValue)
            NSLayoutConstraint.activate(constraints)
        }
    }
    private var currentAnimation: ToastAnimation?
    
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    // MARK: - Initializer
    public init(_ view: UIView) {
        self.view = view
    }
    
    // MARK: - Public
    public static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.view == rhs.view
    }
    
    /// Show toast.
    ///
    /// - parameters:
    ///   - duration: The duration informing that the time the toast is exposed. Default value is `nil`, it mean toast doesn't hide.
    ///   - layouts: The positions list describe where toast view layouted.
    ///   - target: The target is the reference for where the toast will be shown. Default value is `nil`, if value is `nil`, the target is same as `layer`.
    ///   - scene: The scene where the toast will attach. Default value is `nil`. If value is `nil`, the toast will attach to scene in foreground active state.
    ///   - boundary: The boundary insets is maximum layout guideline. Default value is `.zero`.
    ///     The boundary work on safe area default. If you want to change base to superview, sset `ignoresSafeArea` parameter to `true`.
    ///   - ignoresSafeArea: Ignores safe area to set boundary. Default value is `false`.
    ///   - showAnimation: The animation to be played when appearing. Default value is `fadeIn(duration: 0.3)`.
    ///   - hideAnimation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - shown: The shown completion handler with success. Default value is `nil`.
    ///   - hidden: The hidden completion handler with success. Default value is `nil`.
    @discardableResult
    open func show(
        withDuration duration: TimeInterval? = nil,
        layouts: [Layout],
        target: UIView? = nil,
        scene: UIWindowScene? = nil,
        boundary: UIEdgeInsets = .zero,
        ignoresSafeArea: Bool = false,
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) -> Toast {
        guard let scene = scene ?? Toast.scene else {
            shown?(false)
            return self
        }
        
        let window = self.window ?? ContentResponderWindow(windowScene: scene)
        window.isHidden = false
        
        self.window = window
        
        // Attach toast view.
        [view].forEach {
            $0.removeFromSuperview()
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview($0)
        }
        
        // Set layout constraints of toast view.
        updateLayout(
            layouts,
            of: view,
            target: target ?? window,
            layer: window,
            boundary: boundary,
            ignoresSafeArea: ignoresSafeArea
        )
        
        // Show with animation.
        currentAnimation?.cancel()
        showAnimation.play(view) { shown?($0) }
        
        if let duration = duration {
            // Set timer if duration set.
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [self] _ in
                // Hide
                hide(animation: hideAnimation) { hidden?($0) }
            }
        }
        
        self.currentAnimation = showAnimation
        
        return self
    }
    
    /// Hide toast.
    ///
    /// - parameters:
    ///   - animation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - completion: The hidden completion handler with success.
    open func hide(
        animation: ToastAnimation,
        completion: ((Bool) -> Void)? = nil
    ) {
        // Hide whith animation.
        currentAnimation?.cancel()
        animation.play(view) { [self] in
            view.removeFromSuperview()
            completion?($0)
        }
        
        currentAnimation = animation
    }
    
    /// Update toast layout.
    ///
    /// - parameters:
    ///   - layouts: The positions list describe where toast view layouted.
    ///   - target: The target is the reference for where the toast will be shown. Default value is `nil`, if value is `nil`, the target is same as `layer`.
    ///   - boundary: The boundary insets is maximum layout guideline. Default value is `.zero`.
    open func update(
        layouts: [Layout],
        target: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        ignoresSafeArea: Bool = false
    ) {
        guard let layer = view.superview else { return }
        let target = target ?? layer
        
        UIView.animate(withDuration: 0.3) { [self] in
            // Set layout constraints of toast.
            let layoutConstraints = layouts.map {
                $0.makeConstraint(
                    from: view,
                    to: target,
                    in: layer
                )
            }
            
            // Set toast boundary constraints.
            let boundaryConstraints = makeBoundaryConstraints(
                view: view,
                layer: layer,
                boundary: boundary,
                ignoresSafeArea: ignoresSafeArea
            )
            
            constraints = layoutConstraints + boundaryConstraints
            
            layer.layoutIfNeeded()
        }
    }
    
    // MARK: - Private
    private func updateLayout(
        _ layouts: [Layout],
        of view: UIView,
        target: UIView,
        layer: UIView,
        boundary: UIEdgeInsets,
        ignoresSafeArea: Bool
    ) {
        // Set layout constraints of toast.
        let layoutConstraints = layouts.map {
            $0.makeConstraint(
                from: view,
                to: target,
                in: layer
            )
        }
        
        // Set toast boundary constraints.
        let boundaryConstraints = makeBoundaryConstraints(
            view: view,
            layer: layer,
            boundary: boundary,
            ignoresSafeArea: ignoresSafeArea
        )
        
        constraints = layoutConstraints + boundaryConstraints
    }
    
    private func makeBoundaryConstraints(
        view: UIView,
        layer: UIView,
        boundary: UIEdgeInsets,
        ignoresSafeArea: Bool
    ) -> [NSLayoutConstraint] {
        let safeArea = layer.safeAreaLayoutGuide
        
        return [
            view.topAnchor.constraint(
                greaterThanOrEqualTo: ignoresSafeArea ? layer.topAnchor : safeArea.topAnchor,
                constant: boundary.top
            ),
            view.trailingAnchor.constraint(
                lessThanOrEqualTo: ignoresSafeArea ? layer.trailingAnchor : safeArea.trailingAnchor,
                constant: -boundary.right
            ),
            view.bottomAnchor.constraint(
                lessThanOrEqualTo: ignoresSafeArea ? layer.bottomAnchor : safeArea.bottomAnchor,
                constant: -boundary.bottom
            ),
            view.leadingAnchor.constraint(
                greaterThanOrEqualTo: ignoresSafeArea ? layer.leadingAnchor : safeArea.leadingAnchor,
                constant: boundary.left
            )
        ]
    }
    
    deinit {
        window?.isHidden = true
    }
}

public extension Toast {
    convenience init<V: View>(_ view: V) {
        let viewController = UIHostingController(rootView: view)
        viewController._disableSafeArea = true
        viewController.view.backgroundColor = .clear
        
        self.init(viewController.view)
    }
    
    convenience init<V: View>(@ViewBuilder _ content: () -> V) {
        self.init(content())
    }
}
