//
//  Toast.swift
//  JSToast
//
//  Created by jsilver on 2021/10/05.
//

import UIKit

public class Toast {
    public struct Position: Layout {
        // MARK: - Property
        private let layout: Layout
        
        public init(layout: Layout) {
            self.layout = layout
        }
        
        // MARK: - Public
        public func setUp(from lhs: UIView, to rhs: UIView, in base: UIView) {
            layout.setUp(from: lhs, to: rhs, in: base)
        }
        
        // MARK: - Private
    }
    
    public struct Animation: Animator {
        // MARK: - Property
        private let animator: Animator
        
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
    let toast: UIView
    
    private var retain: Toast?
    
    // MARK: - Initializer
    public init(_ toast: UIView) {
        self.toast = toast
    }
    
    // MARK: - Public
    func show(
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
        guard let layer = layer ?? getLayer() else {
            shown?(false)
            return
        }
        
        attachToast(
            toast,
            positions: positions,
            of: target,
            base: layer,
            withBoundary: boundary
        )
        
        showAnimation.play(toast) { shown?($0) }
        
        retain = self
        
        if let duration = duration {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.hide(animation: hideAnimation) { hidden?($0) }
                self?.retain = nil
            }
        }
    }
    
    func hide(animation: Animation = .fadeOut(duration: 0.3), completion: ((Bool) -> Void)? = nil) {
        guard retain != nil else {
            completion?(false)
            return
        }
        
        animation.play(toast) { [toast] in
            toast.removeFromSuperview()
            completion?($0)
        }
        
        retain = nil
    }
    
    // MARK: - Private
    private func attachToast(
        _ toast: UIView,
        positions: [Position],
        of target: UIView?,
        base layer: UIView,
        withBoundary boundary: UIEdgeInsets
    ) {
        let target = target ?? layer
        
        [toast].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            layer.addSubview($0)
        }
        
        // Layout toast
        positions.forEach { $0.setUp(from: toast, to: target, in: layer) }
        
        // Set toast boundary constraints
        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(
                greaterThanOrEqualTo: layer.safeAreaLayoutGuide.topAnchor,
                constant: boundary.top
            ),
            toast.trailingAnchor.constraint(
                lessThanOrEqualTo: layer.safeAreaLayoutGuide.trailingAnchor,
                constant: -boundary.right
            ),
            toast.bottomAnchor.constraint(
                lessThanOrEqualTo: layer.safeAreaLayoutGuide.bottomAnchor,
                constant: -boundary.bottom
            ),
            toast.leadingAnchor.constraint(
                greaterThanOrEqualTo: layer.safeAreaLayoutGuide.leadingAnchor,
                constant: boundary.left
            )
        ])
    }
    
    private func getLayer() -> UIView? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    deinit {
        print("deinited \(self)")
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
