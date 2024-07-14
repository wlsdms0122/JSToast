//
//  Animator.swift
//  JSToast
//
//  Created by jsilver on 2021/10/05.
//

import UIKit

public enum Direction {
    case up
    case right
    case down
    case left
}

public protocol ToastAnimation {
    func play(_ view: UIView, completion: @escaping (Bool) -> Void)
    func cancel(completion: @escaping () -> Void)
}

public extension ToastAnimation where Self == FadeInAnimation {
    static func fadeIn(
        duration: TimeInterval,
        curve: UIView.AnimationCurve = .easeInOut
    ) -> Self {
        FadeInAnimation(
            duration: duration,
            curve: curve
        )
    }
}

public extension ToastAnimation where Self == FadeOutAnimation {
    static func fadeOut(
        duration: TimeInterval,
        curve: UIView.AnimationCurve = .easeInOut
    ) -> Self {
        FadeOutAnimation(
            duration: duration,
            curve: curve
        )
    }
}

public extension ToastAnimation where Self == SlideInAnimation {
    static func slideIn(
        duration: TimeInterval,
        direction: Direction,
        curve: UIView.AnimationCurve = .easeInOut,
        offset: CGFloat? = nil
    ) -> Self {
        SlideInAnimation(
            duration: duration,
            direction: direction,
            curve: curve,
            offset: offset
        )
    }
}

public extension ToastAnimation where Self == SlideOutAnimation {
    static func slideOut(
        duration: TimeInterval,
        direction: Direction,
        curve: UIView.AnimationCurve = .easeInOut,
        offset: CGFloat? = nil
    ) -> Self {
        SlideOutAnimation(
            duration: duration,
            direction: direction,
            curve: curve,
            offset: offset
        )
    }
}

// MARK: - FadeInAnimator
public class FadeInAnimation: ToastAnimation {
    private let duration: TimeInterval
    private let curve: UIView.AnimationCurve
    
    private var animator: UIViewPropertyAnimator?
    
    public init(
        duration: TimeInterval = 0.3,
        curve: UIView.AnimationCurve = .easeInOut
    ) {
        self.duration = duration
        self.curve = curve
    }
    
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        view.alpha = 0
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            view.alpha = 1
        }
        
        animator.addCompletion {
            completion($0 == .end)
        }
        
        animator.startAnimation()
        
        self.animator = animator
    }
    
    public func cancel(completion: @escaping () -> Void) {
        guard animator?.isRunning ?? false else {
            completion()
            return
        }
        
        animator?.addCompletion { _ in
            completion()
        }
        
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
    }
}

// MARK: - FadeOutAnimator
public class FadeOutAnimation: ToastAnimation {
    private let duration: TimeInterval
    private let curve: UIView.AnimationCurve
    
    private var animator: UIViewPropertyAnimator?
    
    public init(
        duration: TimeInterval = 0.3,
        curve: UIView.AnimationCurve = .easeInOut
    ) {
        self.duration = duration
        self.curve = curve
    }
    
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        view.alpha = 1
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            view.alpha = 0
        }
        
        animator.addCompletion {
            completion($0 == .end)
        }
        
        animator.startAnimation()
        
        self.animator = animator
    }
    
    public func cancel(completion: @escaping () -> Void) {
        guard animator?.isRunning ?? false else {
            completion()
            return
        }
        
        animator?.addCompletion { _ in
            completion()
        }
        
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
    }
}

// MARK: - SlideInAnimator
public class SlideInAnimation: ToastAnimation {
    // MARK: - Property
    private let duration: TimeInterval
    private let direction: Direction
    private let curve: UIView.AnimationCurve
    private let offset: CGFloat?
    
    private var animator: UIViewPropertyAnimator?
    
    // MARK: - Initializer
    public init(
        duration: TimeInterval = 0.3,
        direction: Direction,
        curve: UIView.AnimationCurve = .easeInOut,
        offset: CGFloat? = nil
    ) {
        self.duration = duration
        self.direction = direction
        self.curve = curve
        self.offset = offset
    }
    
    // MARK: - Public
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        let offset = offset ?? offset(direction: direction, withTarget: view)
        
        view.alpha = 1
        view.transform = transform(direction: direction, offset: offset)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            view.transform = .identity
        }
        
        animator.addCompletion {
            completion($0 == .end)
        }
        
        animator.startAnimation()
        
        self.animator = animator
    }
    
    public func cancel(completion: @escaping () -> Void) {
        guard animator?.isRunning ?? false else {
            completion()
            return
        }
        
        animator?.addCompletion { _ in
            completion()
        }
        
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
    }
    
    // MARK: - Private
    private func offset(direction: Direction, withTarget view: UIView) -> CGFloat {
        guard let superview = view.superview else { return 0 }
        superview.layoutIfNeeded()
        
        switch direction {
        case .up:
            return superview.bounds.height - view.frame.minY
            
        case .right:
            return view.frame.maxX
            
        case .down:
            return view.frame.maxY
            
        case .left:
            return superview.bounds.width - view.frame.minX
        }
    }
    
    private func transform(direction: Direction, offset: CGFloat) -> CGAffineTransform {
        switch direction {
        case .up:
            return CGAffineTransform(translationX: 0, y: offset)
            
        case .right:
            return CGAffineTransform(translationX: -offset, y: 0)
            
        case .down:
            return CGAffineTransform(translationX: 0, y: -offset)
            
        case .left:
            return CGAffineTransform(translationX: offset, y: 0)
        }
    }
}

// MARK: - SlideOutAnimator
public class SlideOutAnimation: ToastAnimation {
    // MARK: - Property
    private let duration: TimeInterval
    private let direction: Direction
    private let curve: UIView.AnimationCurve
    private let offset: CGFloat?
    
    private var animator: UIViewPropertyAnimator?
    
    // MARK: - Initializer
    public init(
        duration: TimeInterval = 0.3,
        direction: Direction,
        curve: UIView.AnimationCurve = .easeInOut,
        offset: CGFloat? = nil
    ) {
        self.duration = duration
        self.direction = direction
        self.curve = curve
        self.offset = offset
    }
    
    // MARK: - Public
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        let offset = offset ?? offset(direction: direction, withTarget: view)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) { [weak self] in
            guard let self else { return }
            view.transform = self.transform(direction: self.direction, offset: offset)
        }
        
        animator.addCompletion {
            completion($0 == .end)
        }
        
        animator.startAnimation()
        
        self.animator = animator
    }
    
    public func cancel(completion: @escaping () -> Void) {
        guard animator?.isRunning ?? false else {
            completion()
            return
        }
        
        animator?.addCompletion { _ in
            completion()
        }
        
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
    }
    
    // MARK: - Private
    private func offset(direction: Direction, withTarget view: UIView) -> CGFloat {
        guard let superview = view.superview else { return 0 }
        superview.layoutIfNeeded()
        
        switch direction {
        case .up:
            return view.frame.maxY - view.transform.ty
            
        case .right:
            return superview.bounds.width - view.frame.minX + view.transform.tx
            
        case .down:
            return superview.bounds.height - view.frame.minY + view.transform.ty
            
        case .left:
            return view.frame.maxX - view.transform.tx
        }
    }
    
    private func transform(direction: Direction, offset: CGFloat) -> CGAffineTransform {
        switch direction {
        case .up:
            return CGAffineTransform(translationX: 0, y: -offset)
            
        case .right:
            return CGAffineTransform(translationX: offset, y: 0)
            
        case .down:
            return CGAffineTransform(translationX: 0, y: offset)
            
        case .left:
            return CGAffineTransform(translationX: -offset, y: 0)
        }
    }
}
