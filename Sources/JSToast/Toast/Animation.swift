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

public protocol Animation {
    func play(_ view: UIView, completion: @escaping (Bool) -> Void)
    func cancel()
}

public extension Animation where Self == FadeInAnimation {
    static func fadeIn(duration: TimeInterval) -> Self {
        FadeInAnimation(duration: duration)
    }
}

public extension Animation where Self == FadeOutAnimation {
    static func fadeOut(duration: TimeInterval) -> Self {
        FadeOutAnimation(duration: duration)
    }
}

public extension Animation where Self == SlideInAnimation {
    static func slideIn(duration: TimeInterval, direction: Direction, offset: CGFloat? = nil) -> Self {
        SlideInAnimation(duration: duration, direction: direction, offset: offset)
    }
}

public extension Animation where Self == SlideOutAnimation {
    static func slideOut(duration: TimeInterval, direction: Direction, offset: CGFloat? = nil) -> Self {
        SlideOutAnimation(duration: duration, direction: direction, offset: offset)
    }
}

// MARK: - FadeInAnimator
public class FadeInAnimation: Animation {
    private let duration: TimeInterval
    
    private var animator: UIViewPropertyAnimator?
    
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }
    
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        view.alpha = 0
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            view.alpha = 1
        }
        
        animator.addCompletion {
            completion($0 == .end)
        }
        
        animator.startAnimation()
        
        self.animator = animator
    }
    
    public func cancel() {
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
    }
}

// MARK: - FadeOutAnimator
public class FadeOutAnimation: Animation {
    private let duration: TimeInterval
    
    private var animator: UIViewPropertyAnimator?
    
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }
    
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        view.alpha = 1
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            view.alpha = 0
        }
        
        animator.addCompletion {
            completion($0 == .end)
        }
        
        animator.startAnimation()
        
        self.animator = animator
    }
    
    public func cancel() {
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
    }
}

// MARK: - SlideInAnimator
public class SlideInAnimation: Animation {
    // MARK: - Property
    private let duration: TimeInterval
    private let direction: Direction
    private let offset: CGFloat?
    
    private var animator: UIViewPropertyAnimator?
    
    // MARK: - Initializer
    public init(duration: TimeInterval = 0.3, direction: Direction, offset: CGFloat? = nil) {
        self.duration = duration
        self.direction = direction
        self.offset = offset
    }
    
    // MARK: - Public
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        let offset = offset ?? offset(direction: direction, withTarget: view)
        
        view.alpha = 1
        view.transform = transform(direction: direction, offset: offset)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            view.transform = .identity
        }
        
        animator.addCompletion {
            completion($0 == .end)
        }
        
        animator.startAnimation()
        
        self.animator = animator
    }
    
    public func cancel() {
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
public class SlideOutAnimation: Animation {
    // MARK: - Property
    private let duration: TimeInterval
    private let direction: Direction
    private let offset: CGFloat?
    
    private var animator: UIViewPropertyAnimator?
    
    // MARK: - Initializer
    public init(duration: TimeInterval = 0.3, direction: Direction, offset: CGFloat? = nil) {
        self.duration = duration
        self.direction = direction
        self.offset = offset
    }
    
    // MARK: - Public
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        let offset = offset ?? offset(direction: direction, withTarget: view)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) { [weak self] in
            guard let self else { return }
            view.transform = self.transform(direction: self.direction, offset: offset)
        }
        
        animator.addCompletion {
            completion($0 == .end)
        }
        
        animator.startAnimation()
        
        self.animator = animator
    }
    
    public func cancel() {
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
            return view.frame.maxY
            
        case .right:
            return superview.bounds.width - view.frame.minX
            
        case .down:
            return superview.bounds.height - view.frame.minY
            
        case .left:
            return view.frame.maxX
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
