//
//  ViewLayout.swift
//
//
//  Created by jsilver on 7/9/24.
//

import UIKit

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
        offset: CGFloat = 0,
        ignoresSafeArea: Bool = false
    ) -> ViewLayout {
        ViewLayout { target in
            .inside(anchor, of: target, offset: offset, ignoresSafeArea: ignoresSafeArea)
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
        offset: CGFloat = 0,
        ignoresSafeArea: Bool = false
    ) -> ViewLayout {
        ViewLayout { target in
            .center(axis, of: target, offset: offset, ignoresSafeArea: ignoresSafeArea)
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
