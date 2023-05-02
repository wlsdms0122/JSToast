//
//  View+Toast.swift
//  
//
//  Created by JSilver on 2023/04/13.
//

import SwiftUI

public extension View {
    func toast<Content: View>(
        _ isShow: Binding<Bool>,
        duration: TimeInterval? = nil,
        layouts: [ViewLayout],
        layer: ToastLayer? = nil,
        boundary: UIEdgeInsets = .zero,
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        return overlay(
            ToastView(
                isShow,
                duration: duration,
                layouts: layouts,
                layer: layer,
                boundary: boundary,
                showAnimation: showAnimation,
                hideAnimation: hideAnimation,
                shown: shown,
                hidden: hidden,
                content: content
            )
                .allowsHitTesting(false)
        )
    }
}
