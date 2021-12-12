//
//  Toast.swift
//  JSToast
//
//  Created by jsilver on 2021/10/05.
//

import UIKit

public class Toast: Equatable {
    public struct Position {
        // MARK: - Property
        public let layout: Layout
        
        // MARK: - Initializer
        public init(layout: Layout) {
            self.layout = layout
        }
        
        // MARK: - Public
        
        // MARK: - Private
    }
    
    public struct Animator {
        // MARK: - Property
        public let animation: Animation
        
        // MARK: - Initializer
        public init(animation: Animation) {
            self.animation = animation
        }
        
        // MARK: - Public
        
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
    
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
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
        layouts: [Layout],
        target: UIView? = nil,
        layer: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        showAnimation: Animation,
        hideAnimation: Animation,
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
        updateLayout(
            layouts,
            of: view,
            target: target ?? layer,
            layer: layer,
            boundary: boundary
        )
        
        // Show with animation.
        showAnimation.play(view) { shown?($0) }
        
        // Retain self instance of toast.
        retain = self
        
        if let duration = duration {
            // Set timer if duration set.
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                // Hide
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
        animation: Animation,
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
        positions: [Layout],
        target: UIView? = nil,
        boundary: UIEdgeInsets = .zero
    ) {
        guard let layer = view.superview else { return }
        let target = target ?? layer
        
        UIView.animate(withDuration: 0.3) { [self] in
            // Set layout constraints of toast.
            let layoutConstraints = positions.map {
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
                boundary: boundary
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
        boundary: UIEdgeInsets
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
            boundary: boundary
        )
        
        constraints = layoutConstraints + boundaryConstraints
    }
    
    private func makeBoundaryConstraints(
        view: UIView,
        layer: UIView,
        boundary: UIEdgeInsets
    ) -> [NSLayoutConstraint] {
        [
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
        ]
    }
}

public extension Toast {
    func show(
        withDuration duration: TimeInterval? = nil,
        layouts positions: [Position],
        target: UIView? = nil,
        layer: UIView? = nil,
        boundary: UIEdgeInsets = .zero,
        showAnimation showAnimator: Animator = .fadeIn(duration: 0.3),
        hideAnimation hideAnimator: Animator = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) {
        show(
            withDuration: duration,
            layouts: positions.map { $0.layout },
            target: target,
            layer: layer,
            boundary: boundary,
            showAnimation: showAnimator.animation,
            hideAnimation: hideAnimator.animation,
            shown: shown,
            hidden: hidden
        )
    }
    
    func hide(
        animation animator: Animator = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        hide(
            animation: animator.animation,
            completion: completion
        )
    }
    
    func update(
        layouts positions: [Position],
        target: UIView? = nil,
        boundary: UIEdgeInsets = .zero
    ) {
        update(
            positions: positions.map { $0.layout },
            target: target,
            boundary: boundary
        )
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

extension Toast.Animator {
    public static func fadeIn(duration: TimeInterval) -> Self {
        .init(animation: FadeInAnimation(duration: duration))
    }
    
    public static func fadeOut(duration: TimeInterval) -> Self {
        .init(animation: FadeOutAnimation(duration: duration))
    }
    
    public static func slideIn(duration: TimeInterval, direction: Direction, offset: CGFloat? = nil) -> Self {
        .init(animation: SlideInAnimation(duration: duration, direction: direction, offset: offset))
    }
    
    public static func slideOut(duration: TimeInterval, direction: Direction, offset: CGFloat? = nil) -> Self {
        .init(animation: SlideOutAnimation(duration: duration, direction: direction, offset: offset))
    }
}
