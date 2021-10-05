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

public protocol Animator {
    func play(_ view: UIView, completion: @escaping (Bool) -> Void)
}

// MARK: - FadeInAnimator
public struct FadeInAnimator: Animator {
    private let duration: TimeInterval
    
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }
    
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        view.alpha = 0
        
        UIView.animate(withDuration: duration) {
            view.alpha = 1
        } completion: {
            completion($0)
        }
    }
}

// MARK: - FadeOutAnimator
public struct FadeOutAnimator: Animator {
    private let duration: TimeInterval
    
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }
    
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        view.alpha = 1
        
        UIView.animate(withDuration: duration) {
            view.alpha = 0
        } completion: {
            completion($0)
        }
    }
}

// MARK: - SlideInAnimator
public struct SlideInAnimator: Animator {
    // MARK: - Property
    private let duration: TimeInterval
    private let direction: Direction
    private let offset: CGFloat?
    
    // MARK: - Initializer
    public init(duration: TimeInterval = 0.3, direction: Direction, offset: CGFloat? = nil) {
        self.duration = duration
        self.direction = direction
        self.offset = offset
    }
    
    // MARK: - Public
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        let offset = offset ?? offset(direction: direction, withTarget: view)
        
        view.transform = transform(direction: direction, offset: offset)
        
        UIView.animate(withDuration: duration) {
            view.transform = .identity
        } completion: {
            completion($0)
        }
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
public struct SlideOutAnimator: Animator {
    // MARK: - Property
    private let duration: TimeInterval
    private let direction: Direction
    private let offset: CGFloat?
    
    // MARK: - Initializer
    public init(duration: TimeInterval = 0.3, direction: Direction, offset: CGFloat? = nil) {
        self.duration = duration
        self.direction = direction
        self.offset = offset
    }
    
    // MARK: - Public
    public func play(_ view: UIView, completion: @escaping (Bool) -> Void) {
        let offset = offset ?? offset(direction: direction, withTarget: view)
        
        UIView.animate(withDuration: duration) {
            view.transform = transform(direction: direction, offset: offset)
        } completion: {
            completion($0)
        }
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
