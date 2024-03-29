//
//  Toast.swift
//  JSToast
//
//  Created by jsilver on 2021/10/05.
//

import UIKit
import SwiftUI
import Combine

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
    private var currentAnimation: (any ToastAnimation)?
    
    private var timerCancellable: AnyCancellable?
    private var frameObserveCancellable: AnyCancellable?
    
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
    ///   - layer: The view to which the toast view should be attached. The default value is `nil`. If the value is nil, the toast view will be attached to the topmost window.
    ///   - boundary: The boundary insets is maximum layout guideline. Default value is `.zero`.
    ///     The boundary work on safe area default. If you want to change base to superview, sset `ignoresSafeArea` parameter to `true`.
    ///   - ignoresSafeArea: Ignores safe area to set boundary. Default value is `false`.
    ///   - scene: The scene to which the toast will be attached. The default value is `nil`. If the value is `nil`, then the toast will be attached to the scene whose state is currently in the foreground and active.
    ///   - showAnimation: The animation to be played when appearing. Default value is `fadeIn(duration: 0.3)`.
    ///   - hideAnimation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - shown: The shown completion handler with success. Default value is `nil`.
    ///   - hidden: The hidden completion handler with success. Default value is `nil`.
    @discardableResult
    open func show(
        withDuration duration: TimeInterval? = nil,
        layouts: [any Layout],
        layer: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        ignoresSafeArea: Bool = false,
        scene: UIWindowScene? = nil,
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) -> Toast {
        // Make the toast window should be attached.
        guard let layer = makeToastWindow(layer: layer, scene: scene) else {
            shown?(false)
            return self
        }
        
        // Attach the toast to layer.
        let toast = view
        attachTaost(
            toast,
            layouts: layouts,
            layer: layer,
            boundary: boundary,
            ignoresSafeArea: ignoresSafeArea
        )
        
        // Show the toast with animation
        playAnimation(showAnimation, toast: toast) {
            shown?($0)
        }
        
        if let duration = duration {
            // Set timer if duration set.
            timerCancellable = Timer.publish(every: duration, on: .main, in: .default)
                .autoconnect()
                .prefix(1)
                .sink { [self] _ in
                    // Hide the toast with animation.
                    hide(animation: hideAnimation) {
                        hidden?($0)
                    }
                }
        }
        
        return self
    }
    
    /// Hide toast.
    ///
    /// - parameters:
    ///   - animation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - completion: The hidden completion handler with success.
    open func hide(
        animation: ToastAnimation = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        timerCancellable = nil
        
        playAnimation(animation, toast: view) { [self] in
            self.frameObserveCancellable = nil
            self.view.removeFromSuperview()
            
            completion?($0)
        }
    }
    
    /// Update toast layout.
    ///
    /// - parameters:
    ///   - layouts: The positions list describe where toast view layouted.
    ///   - target: The target is the reference for where the toast will be shown. Default value is `nil`, if value is `nil`, the target is same as `layer`.
    ///   - boundary: The boundary insets is maximum layout guideline. Default value is `.zero`.
    open func update(
        layouts: [Layout],
        boundary: UIEdgeInsets = .zero,
        ignoresSafeArea: Bool = false
    ) {
        guard let layer = view.superview else { return }
        
        UIView.animate(withDuration: 0.3) { [self] in
            // Set layout constraints of toast.
            let layoutConstraints = layouts.map {
                $0.makeConstraint(
                    from: view,
                    to: layer
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
    private func makeToastWindow(
        layer: UIView?,
        scene: UIWindowScene?
    ) -> UIView? {
        if let layer = layer {
            // Clear window when toast layer are specified.
            window?.isHidden = true
            window = nil
            
            return layer
        } else {
            guard let scene = scene ?? Toast.scene else { return nil }
            
            // Restore or create new window to attach toast.
            let window = self.window ?? ContentResponderWindow(windowScene: scene)
            window.isHidden = false
            self.window = window
            
            return window
        }
    }
    
    private func attachTaost(
        _ toast: UIView,
        layouts: [any Layout],
        layer: UIView,
        boundary: UIEdgeInsets,
        ignoresSafeArea: Bool
    ) {
        // Attach toast view into layer.
        [toast].forEach {
            $0.removeFromSuperview()
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            layer.addSubview($0)
        }
        
        // Set layout constraints of toast view.
        updateLayout(
            layouts,
            of: toast,
            layer: layer,
            boundary: boundary,
            ignoresSafeArea: ignoresSafeArea
        )
        
        // Update layout when layer frame changed.
        frameObserveCancellable = layer.publisher(for: \.frame)
            .sink { [weak self] _ in
                self?.updateLayout(
                    layouts,
                    of: toast,
                    layer: layer,
                    boundary: boundary,
                    ignoresSafeArea: ignoresSafeArea
                )
            }
    }
    
    private func updateLayout(
        _ layouts: [Layout],
        of view: UIView,
        layer: UIView,
        boundary: UIEdgeInsets,
        ignoresSafeArea: Bool
    ) {
        // Set layout constraints of toast.
        let layoutConstraints = layouts.map {
            $0.makeConstraint(
                from: view,
                to: layer
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
    
    private func playAnimation(
        _ animation: any ToastAnimation,
        toast: UIView,
        completion: @escaping (Bool) -> Void
    ) {
        if let currentAnimation {
            currentAnimation.cancel {
                animation.play(toast) {
                    self.currentAnimation = nil
                    completion($0)
                }
            }
        } else {
            animation.play(toast) {
                self.currentAnimation = nil
                completion($0)
            }
        }
        
        currentAnimation = animation
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
