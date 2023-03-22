//
//  Layout.swift
//  JSToast
//
//  Created by jsilver on 2021/10/05.
//

import UIKit

public enum Anchor {
    case top
    case trailing
    case bottom
    case leading
}

public enum Axis {
    case x
    case y
}

public protocol Layout {
    func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint
}

public extension Layout {
    static func inside(
        _ offset: CGFloat = 0,
        of anchor: Anchor,
        ignoresSafeArea: Bool = false
    ) -> Self where Self == InsideLayout {
        InsideLayout(offset, of: anchor, ignoresSafeArea: ignoresSafeArea)
    }
    
    static func outside(
        _ offset: CGFloat = 0,
        of anchor: Anchor
    ) -> Self where Self == OutsideLayout {
        OutsideLayout(offset, of: anchor)
    }
    
    static func center(
        _ offset: CGFloat = 0,
        of axis: Axis,
        ignoresSafeArea: Bool = false
    ) -> Self where Self == CenterLayout {
        CenterLayout(offset, of: axis, ignoresSafeArea: ignoresSafeArea)
    }
}

public struct ViewLayout: Layout {
    // MARK: - Property
    private let layout: any Layout
    
    // MARK: - Initializer
    init(_ layout: any Layout) {
        self.layout = layout
    }
    
    // MARK: - Lifecycle
    public func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint {
        layout.makeConstraint(from: lhs, to: rhs, in: base)
    }
    
    // MARK: - Public
    public static func inside(
        _ offset: CGFloat = 0,
        of anchor: Anchor,
        ignoresSafeArea: Bool = false
    ) -> ViewLayout {
        ViewLayout(.inside(offset, of: anchor, ignoresSafeArea: true))
    }
    
    public static func outside(
        _ offset: CGFloat = 0,
        of anchor: Anchor
    ) -> ViewLayout {
        ViewLayout(.outside(offset, of: anchor))
    }
    
    public static func center(
        _ offset: CGFloat = 0,
        of axis: Axis
    ) -> ViewLayout {
        ViewLayout(.center(offset, of: axis, ignoresSafeArea: true))
    }
    
    // MARK: - Private
}

// MARK: - Inside Layout
public struct InsideLayout: Layout {
    // MARK: - Property
    private let offset: CGFloat
    private let anchor: Anchor
    private let ignoresSafeArea: Bool
    
    // MARK: - Initializer
    public init(
        _ offset: CGFloat = 0,
        of anchor: Anchor,
        ignoresSafeArea: Bool = false
    ) {
        self.offset = offset
        self.anchor = anchor
        self.ignoresSafeArea = ignoresSafeArea
    }
    
    // MARK: - Lifecycle
    public func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint {
        let rect = rhs.convert(rhs.bounds, to: base)
        let safeArea = base.safeAreaLayoutGuide
        
        let constraint: NSLayoutConstraint
        switch anchor {
        case .top:
            constraint = lhs.topAnchor.constraint(
                equalTo: ignoresSafeArea ? base.topAnchor : safeArea.topAnchor,
                constant: rect.minY + offset
            )
            
        case .trailing:
            constraint = lhs.trailingAnchor.constraint(
                equalTo: ignoresSafeArea ? base.trailingAnchor : safeArea.trailingAnchor,
                constant: -(base.bounds.width - rect.maxX + offset)
            )
            
        case .bottom:
            constraint = lhs.bottomAnchor.constraint(
                equalTo: ignoresSafeArea ? base.bottomAnchor: safeArea.bottomAnchor,
                constant: -(base.bounds.height - rect.maxY + offset)
            )
            
        case .leading:
            constraint = lhs.leadingAnchor.constraint(
                equalTo: ignoresSafeArea ? base.leadingAnchor : safeArea.leadingAnchor,
                constant: rect.minX + offset
            )
        }
        
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

// MARK: - Outside Layout
public struct OutsideLayout: Layout {
    // MARK: - Property
    private let offset: CGFloat
    private let anchor: Anchor
    
    // MARK: - Initializer
    public init(_ offset: CGFloat = 0, of anchor: Anchor) {
        self.offset = offset
        self.anchor = anchor
    }
    
    // MARK: - Lifecycle
    public func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint {
        let rect = rhs.convert(rhs.bounds, to: base)
        
        let constraint: NSLayoutConstraint
        switch anchor {
        case .top:
            constraint = lhs.bottomAnchor.constraint(
                equalTo: base.topAnchor,
                constant: rect.minY - offset
            )
            
        case .trailing:
            constraint = lhs.leadingAnchor.constraint(
                equalTo: base.trailingAnchor,
                constant: -(base.bounds.width - rect.maxX) + offset
            )
            
        case .bottom:
            constraint = lhs.topAnchor.constraint(
                equalTo: base.bottomAnchor,
                constant: -(base.bounds.height - rect.maxY) + offset
            )
            
        case .leading:
            constraint = lhs.trailingAnchor.constraint(
                equalTo: base.leadingAnchor,
                constant: rect.minX - offset
            )
        }
        
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

// MARK: - Center Layout
public struct CenterLayout: Layout {
    // MARK: - Property
    private let offset: CGFloat
    private let axis: Axis
    private let ignoresSafeArea: Bool
    
    // MARK: - Initializer
    init(_ offset: CGFloat = 0, of: Axis, ignoresSafeArea: Bool = false) {
        self.offset = offset
        self.axis = of
        self.ignoresSafeArea = ignoresSafeArea
    }
    
    // MARK: - Lifecycle
    public func makeConstraint(from lhs: UIView, to rhs: UIView, in base: UIView) -> NSLayoutConstraint {
        let rect = rhs.convert(rhs.bounds, to: base)
        let safeAreaInsets = UIEdgeInsets(
            top: max(base.safeAreaInsets.top - rect.minY, 0),
            left: max(base.safeAreaInsets.left - rect.minX, 0),
            bottom: max(rect.maxY - base.frame.maxY - base.safeAreaInsets.bottom, 0),
            right: max(rect.maxX - base.frame.maxX - base.safeAreaInsets.right, 0)
        )
        
        let constraint: NSLayoutConstraint
        switch axis {
        case .x:
            let calibratedMidX = rect.midX
                + (ignoresSafeArea ? 0 : (safeAreaInsets.left - safeAreaInsets.right) / 2)
            
            constraint = lhs.centerXAnchor.constraint(
                equalTo: base.centerXAnchor,
                constant: calibratedMidX - base.bounds.midX + offset
            )
            
        case .y:
            let calibratedMidY = rect.midY
                + (ignoresSafeArea ? 0 : (safeAreaInsets.top - safeAreaInsets.bottom) / 2)
            
            constraint = lhs.centerYAnchor.constraint(
                equalTo: base.centerYAnchor,
                constant: calibratedMidY - base.bounds.midY + offset
            )
        }
        
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Public

    // MARK: - Private
}
