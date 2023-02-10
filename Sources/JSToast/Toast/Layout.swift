//
//  Layout.swift
//  JSToast
//
//  Created by jsilver on 2021/10/05.
//

import UIKit

public enum Anchor {
    case top
    case right
    case bottom
    case left
}

public enum Axis {
    case x
    case y
}

public protocol Layout {
    func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint
}

// MARK: - InsideLayout
public struct InsideLayout: Layout {
    // MARK: - Property
    private let offset: CGFloat
    private let anchor: Anchor
    
    // MARK: - Initializer
    public init(_ offset: CGFloat = 0, of anchor: Anchor) {
        self.offset = offset
        self.anchor = anchor
    }
    
    // MARK: - Public
    public func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint {
        let rect = rhs.convert(rhs.bounds, to: base)
        
        let constraint: NSLayoutConstraint
        switch anchor {
        case .top:
            constraint = lhs.topAnchor.constraint(
                equalTo: base.topAnchor,
                constant: rect.minY + offset + rhs.safeAreaInsets.top
            )
            
        case .right:
            constraint = lhs.rightAnchor.constraint(
                equalTo: base.rightAnchor,
                constant: -(base.bounds.width - rect.maxX + offset + rhs.safeAreaInsets.right)
            )
            
        case .bottom:
            
            constraint = lhs.bottomAnchor.constraint(
                equalTo: base.bottomAnchor,
                constant: -(base.bounds.height - rect.maxY + offset + rhs.safeAreaInsets.bottom)
            )
            
        case .left:
            constraint = lhs.leftAnchor.constraint(
                equalTo: base.leftAnchor,
                constant: rect.minX + offset + rhs.safeAreaInsets.left
            )
        }
        
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Private
}

// MARK: - OutsideLayout
public struct OutsideLayout: Layout {
    // MARK: - Property
    private let offset: CGFloat
    private let anchor: Anchor
    
    // MARK: - Initializer
    public init(_ offset: CGFloat = 0, of anchor: Anchor) {
        self.offset = offset
        self.anchor = anchor
    }
    
    // MARK: - Public
    public func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint {
        let rect = rhs.convert(rhs.bounds, to: base)
        
        let constraint: NSLayoutConstraint
        switch anchor {
        case .top:
            constraint = lhs.bottomAnchor.constraint(
                equalTo: base.topAnchor,
                constant: rect.minY - offset
            )
            
        case .right:
            constraint = lhs.leftAnchor.constraint(
                equalTo: base.rightAnchor,
                constant: -(base.bounds.width - rect.maxX) + offset
            )
            
        case .bottom:
            constraint = lhs.topAnchor.constraint(
                equalTo: base.bottomAnchor,
                constant: -(base.bounds.height - rect.maxY) + offset
            )
            
        case .left:
            constraint = lhs.rightAnchor.constraint(
                equalTo: base.leftAnchor,
                constant: rect.minX - offset
            )
        }
        
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Private
}

// MARK: - CenterLayout
struct CenterLayout: Layout {
    // MARK: - Property
    let offset: CGFloat
    let axis: Axis
    
    // MARK: - Initializer
    init(_ offset: CGFloat = 0, of: Axis) {
        self.offset = offset
        self.axis = of
    }
    
    // MARK: - Public
    func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint {
        let rect = rhs.convert(rhs.bounds, to: base)
        
        let constraint: NSLayoutConstraint
        switch axis {
        case .x:
            constraint = lhs.centerXAnchor.constraint(
                equalTo: base.centerXAnchor,
                constant: rect.midX - base.bounds.midX + offset + (rhs.safeAreaInsets.left - rhs.safeAreaInsets.right) / 2
            )
            
        case .y:
            constraint = lhs.centerYAnchor.constraint(
                equalTo: base.centerYAnchor,
                constant: rect.midY - base.bounds.midY + offset + (rhs.safeAreaInsets.top - rhs.safeAreaInsets.bottom) / 2
            )
        }
        
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Private
}
