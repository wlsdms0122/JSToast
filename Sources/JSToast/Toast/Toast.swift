//
//  Toast.swift
//  JSToast
//
//  Created by jsilver on 2021/10/05.
//

import UIKit

public class Toast: Equatable {
    public struct Position: Layout {
        // MARK: - Property
        private let layout: Layout
        
        // MARK: - Initializer
        public init(layout: Layout) {
            self.layout = layout
        }
        
        // MARK: - Public
        public func setUp(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint {
            layout.setUp(from: lhs, to: rhs, in: base)
        }
        
        // MARK: - Private
    }
    
    public struct Animation: Animator {
        // MARK: - Property
        private let animator: Animator
        
        // MARK: - Initializer
        public init(animator: Animator) {
            self.animator = animator
        }
        
        // MARK: - Public
        public func play(_ toast: UIView, completion: @escaping (Bool) -> Void) {
            animator.play(toast) { completion($0) }
        }
        
        // MARK: - Private
    }
    
    // MARK: - Property
    public static var layer: UIView? = {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }()
    
    public let view: UIView
    private var constraints: [NSLayoutConstraint] = [] {
        didSet {
            NSLayoutConstraint.deactivate(oldValue)
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    private var retain: Toast?
    
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
    ///   - positions: The positions list describe where toast view layouted.
    ///   - target: The target is the reference for where the toast will be shown. Default value is `nil`, if value is `nil`, the target is same as `layer`.
    ///   - layer: The layer where the toast will attach. Default value is `nil`. If value is `nil`, the toast will attach to key window.
    ///   - boundary: The boundary insets is maximum layout guideline. Default value is `.zero`.
    ///   - showAnimation: The animation to be played when appearing. Default value is `fadeIn(duration: 0.3)`.
    ///   - hideAnimation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - shown: The shown completion handler with success. Default value is `nil`.
    ///   - hidden: The hidden completion handler with success. Default value is `nil`.
    open func show(
        withDuration duration: TimeInterval? = nil,
        at positions: [Position],
        of target: UIView? = nil,
        base layer: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        show showAnimation: Animation = .fadeIn(duration: 0.3),
        hide hideAnimation: Animation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) {
        guard let layer = layer ?? Self.layer else {
            shown?(false)
            return
        }
        
        // Attach toast view.
        [view].forEach {
            $0.removeFromSuperview()
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            layer.addSubview($0)
        }
        
        // Set layout constraints of toast view.
        setUpLayout(
            view,
            positions: positions,
            of: target ?? layer,
            base: layer,
            withBoundary: boundary
        )
        
        // Show with animation.
        showAnimation.play(view) { shown?($0) }
        
        // Retain self instance of toast.
        retain = self
        
        if let duration = duration {
            // Set timer if duration set.
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                // Hid
                self?.hide(animation: hideAnimation) { hidden?($0) }
                self?.retain = nil
            }
        }
    }
    
    /// Hide toast.
    ///
    /// - parameters:
    ///   - animation: The animation to be played when disappearing. Default value is `fadeOut(duration: 0.3)`.
    ///   - completion: The hidden completion handler with success.
    open func hide(
        animation: Animation = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        guard retain != nil else {
            // Complete if instance not retained. (not shown tey.)
            completion?(false)
            return
        }
        
        // Hide whith animation.
        animation.play(view) { [view] in
            view.removeFromSuperview()
            completion?($0)
        }
        
        // Release self instance of toast.
        retain = nil
    }
    
    /// Update toast layout.
    ///
    /// - parameters:
    ///   - positions: The positions list describe where toast view layouted.
    ///   - target: The target is the reference for where the toast will be shown. Default value is `nil`, if value is `nil`, the target is same as `layer`.
    ///   - boundary: The boundary insets is maximum layout guideline. Default value is `.zero`.
    open func update(
        at positions: [Position],
        of target: UIView? = nil,
        boundary: UIEdgeInsets = .zero
    ) {
        guard let layer = view.superview else { return }
        let target = target ?? layer
        
        UIView.animate(withDuration: 0.3) { [self] in
            // Set layout constraints of toast
            constraints = positions.map { $0.setUp(from: view, to: target, in: layer) }
            
            // Set toast boundary constraints
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(
                    greaterThanOrEqualTo: layer.safeAreaLayoutGuide.topAnchor,
                    constant: boundary.top
                ),
                view.trailingAnchor.constraint(
                    lessThanOrEqualTo: layer.safeAreaLayoutGuide.trailingAnchor,
                    constant: -boundary.right
                ),
                view.bottomAnchor.constraint(
                    lessThanOrEqualTo: layer.safeAreaLayoutGuide.bottomAnchor,
                    constant: -boundary.bottom
                ),
                view.leadingAnchor.constraint(
                    greaterThanOrEqualTo: layer.safeAreaLayoutGuide.leadingAnchor,
                    constant: boundary.left
                )
            ])
            
            layer.layoutIfNeeded()
        }
    }
    
    // MARK: - Private
    private func setUpLayout(
        _ view: UIView,
        positions: [Position],
        of target: UIView,
        base layer: UIView,
        withBoundary boundary: UIEdgeInsets
    ) {
        // Set layout constraints of toast.
        constraints = positions.map { $0.setUp(from: view, to: target, in: layer) }
        
        // Set toast boundary constraints.
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(
                greaterThanOrEqualTo: layer.safeAreaLayoutGuide.topAnchor,
                constant: boundary.top
            ),
            view.trailingAnchor.constraint(
                lessThanOrEqualTo: layer.safeAreaLayoutGuide.trailingAnchor,
                constant: -boundary.right
            ),
            view.bottomAnchor.constraint(
                lessThanOrEqualTo: layer.safeAreaLayoutGuide.bottomAnchor,
                constant: -boundary.bottom
            ),
            view.leadingAnchor.constraint(
                greaterThanOrEqualTo: layer.safeAreaLayoutGuide.leadingAnchor,
                constant: boundary.left
            )
        ])
    }
}

extension Toast.Position {
    public static func inside(_ offset: CGFloat = 0, of anchor: Anchor) -> Self {
        .init(layout: InsideLayout(offset, of: anchor))
    }
    
    public static func outside(_ offset: CGFloat = 0, of anchor: Anchor) -> Self {
        .init(layout: OutsideLayout(offset, of: anchor))
    }
    
    public static func center(_ offset: CGFloat = 0, of axis: Axis) -> Self {
        .init(layout: CenterLayout(offset, of: axis))
    }
    
}

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
