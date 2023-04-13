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
    func makeConstraint(from lhs: UIView, to rhs: UIView) -> NSLayoutConstraint
}

public extension Layout {
    static func inside(
        _ anchor: Anchor,
        of target: UIView? = nil,
        offset: CGFloat = 0,
        ignoresSafeArea: Bool = false
    ) -> Self where Self == InsideLayout {
        InsideLayout(
            anchor,
            of: target,
            offset: offset,
            ignoresSafeArea: ignoresSafeArea
        )
    }
    
    static func outside(
        _ anchor: Anchor,
        of target: UIView? = nil,
        offset: CGFloat = 0
    ) -> Self where Self == OutsideLayout {
        OutsideLayout(anchor, of: target, offset: offset)
    }
    
    static func center(
        _ axis: Axis,
        of target: UIView? = nil,
        offset: CGFloat = 0,
        ignoresSafeArea: Bool = false
    ) -> Self where Self == CenterLayout {
        CenterLayout(
            axis,
            of: target,
            offset: offset,
            ignoresSafeArea: ignoresSafeArea
        )
    }
    
    static func width(_ width: CGFloat) -> Self where Self == WidthLayout {
        WidthLayout(width)
    }
    
    static func height(_ height: CGFloat) -> Self where Self == HeightLayout {
        HeightLayout(height)
    }
}

public struct ViewLayout {
    // MARK: - Property
    let layout: (UIView?) -> any Layout
    
    // MARK: - Initializer
    init(_ layout: @escaping (UIView?) -> any Layout) {
        self.layout = layout
    }
    
    // MARK: - Public
    public static func inside(
        _ anchor: Anchor,
        offset: CGFloat = 0
    ) -> ViewLayout {
        ViewLayout { target in
            .inside(anchor, of: target, offset: offset, ignoresSafeArea: true)
        }
    }
    
    public static func outside(
        _ anchor: Anchor,
        offset: CGFloat = 0
    ) -> ViewLayout {
        ViewLayout { target in
            .outside(anchor, of: target, offset: offset)
        }
    }
    
    public static func center(
        _ axis: Axis,
        offset: CGFloat = 0
    ) -> ViewLayout {
        ViewLayout { target in
            .center(axis, of: target, offset: offset, ignoresSafeArea: true)
        }
    }
    
    public static func width(_ width: CGFloat) -> ViewLayout {
        ViewLayout { _ in
            .width(width)
        }
    }
    
    public static func height(_ height: CGFloat) -> ViewLayout {
        ViewLayout { _ in
            .height(height)
        }
    }
    
    // MARK: - Private
}

// MARK: - Inside Layout
public struct InsideLayout: Layout {
    // MARK: - Property
    private let anchor: Anchor
    private let target: UIView?
    private let offset: CGFloat
    private let ignoresSafeArea: Bool
    
    // MARK: - Initializer
    public init(
        _ anchor: Anchor,
        of target: UIView? = nil,
        offset: CGFloat = 0,
        ignoresSafeArea: Bool = false
    ) {
        self.anchor = anchor
        self.target = target
        self.offset = offset
        self.ignoresSafeArea = ignoresSafeArea
    }
    
    // MARK: - Lifecycle
    public func makeConstraint(from lhs: UIView, to rhs: UIView) -> NSLayoutConstraint {
        let rect = target.map { $0.convert($0.bounds, to: rhs) } ?? rhs.bounds
        let safeAreaInsets = target?.safeAreaInsets ?? rhs.safeAreaInsets
        
        let constraint: NSLayoutConstraint
        switch anchor {
        case .top:
            constraint = lhs.topAnchor.constraint(
                equalTo: rhs.topAnchor,
                constant: rect.minY + offset + (ignoresSafeArea ? 0 : safeAreaInsets.top)
            )
            
        case .trailing:
            constraint = lhs.trailingAnchor.constraint(
                equalTo: rhs.trailingAnchor,
                constant: -(rhs.bounds.width - rect.maxX + offset + (ignoresSafeArea ? 0 : safeAreaInsets.right))
            )
            
        case .bottom:
            constraint = lhs.bottomAnchor.constraint(
                equalTo: rhs.bottomAnchor,
                constant: -(rhs.bounds.height - rect.maxY + offset + (ignoresSafeArea ? 0 : safeAreaInsets.bottom))
            )
            
        case .leading:
            constraint = lhs.leadingAnchor.constraint(
                equalTo: rhs.leadingAnchor,
                constant: rect.minX + offset + (ignoresSafeArea ? 0 : safeAreaInsets.left)
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
    private let anchor: Anchor
    private let target: UIView?
    private let offset: CGFloat
    
    // MARK: - Initializer
    public init(
        _ anchor: Anchor,
        of target: UIView? = nil,
        offset: CGFloat = 0
    ) {
        self.anchor = anchor
        self.target = target
        self.offset = offset
    }
    
    // MARK: - Lifecycle
    public func makeConstraint(from lhs: UIView, to rhs: UIView) -> NSLayoutConstraint {
        let rect = target.map { $0.convert($0.bounds, to: rhs) } ?? rhs.bounds
        
        let constraint: NSLayoutConstraint
        switch anchor {
        case .top:
            constraint = lhs.bottomAnchor.constraint(
                equalTo: rhs.topAnchor,
                constant: rect.minY - offset
            )
            
        case .trailing:
            constraint = lhs.leadingAnchor.constraint(
                equalTo: rhs.trailingAnchor,
                constant: -(rhs.bounds.width - rect.maxX) + offset
            )
            
        case .bottom:
            constraint = lhs.topAnchor.constraint(
                equalTo: rhs.bottomAnchor,
                constant: -(rhs.bounds.height - rect.maxY) + offset
            )
            
        case .leading:
            constraint = lhs.trailingAnchor.constraint(
                equalTo: rhs.leadingAnchor,
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
    private let axis: Axis
    private let target: UIView?
    private let offset: CGFloat
    private let ignoresSafeArea: Bool
    
    // MARK: - Initializer
    public init(
        _ axis: Axis,
        of target: UIView? = nil,
        offset: CGFloat = 0,
        ignoresSafeArea: Bool = false
    ) {
        self.axis = axis
        self.target = target
        self.offset = offset
        self.ignoresSafeArea = ignoresSafeArea
    }
    
    // MARK: - Lifecycle
    public func makeConstraint(from lhs: UIView, to rhs: UIView) -> NSLayoutConstraint {
        let rect = target.map { $0.convert($0.bounds, to: rhs) } ?? rhs.bounds
        let safeAreaInsets = target?.safeAreaInsets ?? rhs.safeAreaInsets
        
        let constraint: NSLayoutConstraint
        switch axis {
        case .x:
            constraint = lhs.centerXAnchor.constraint(
                equalTo: rhs.centerXAnchor,
                constant: rect.midX
                    - rhs.bounds.midX
                    + offset
                    + (ignoresSafeArea ? 0 : (safeAreaInsets.left - safeAreaInsets.right) / 2)
            )
            
        case .y:
            constraint = lhs.centerYAnchor.constraint(
                equalTo: rhs.centerYAnchor,
                constant: rect.midY
                    - rhs.bounds.midY
                    + offset
                    + (ignoresSafeArea ? 0 : (safeAreaInsets.top - safeAreaInsets.bottom) / 2)
            )
        }
        
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

// MARK: - Width Layout
public struct WidthLayout: Layout {
    // MARK: - Property
    private let width: CGFloat
    
    // MARK: - Initializer
    public init(_ width: CGFloat) {
        self.width = width
    }
    
    // MARK: - Lifecylcle
    public func makeConstraint(from lhs: UIView, to rhs: UIView) -> NSLayoutConstraint {
        let constraint = lhs.widthAnchor.constraint(equalToConstant: width)
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

// MARK: - Height Layout
public struct HeightLayout: Layout {
    // MARK: - Property
    private let height: CGFloat
    
    // MARK: - Initializer
    public init(_ height: CGFloat) {
        self.height = height
    }
    
    // MARK: - Lifecylcle
    public func makeConstraint(from lhs: UIView, to rhs: UIView) -> NSLayoutConstraint {
        let constraint = lhs.heightAnchor.constraint(equalToConstant: height)
        constraint.priority = .init(rawValue: 999)
        
        return constraint
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
