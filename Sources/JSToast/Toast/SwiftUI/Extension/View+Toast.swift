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
        layer: ToastLayerProxy? = nil,
        boundary: EdgeInsets = .init(.zero),
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        overlay(
            ToastReader { proxy in
                Color.clear
                    .toastTarget(1)
                    .onChange(of: isShow.wrappedValue) {
                        if $0 {
                            proxy.show(
                                withDuration: duration,
                                layouts: layouts,
                                target: 1,
                                layer: layer,
                                boundary: boundary,
                                showAnimation: showAnimation,
                                hideAnimation: hideAnimation,
                                shown: shown,
                                hidden: {
                                    isShow.wrappedValue = false
                                    hidden?($0)
                                },
                                content: content
                            )
                        } else {
                            proxy.hide(
                                animation: hideAnimation,
                                completion: hidden
                            )
                        }
                    }
            }
                .allowsHitTesting(false)
        )
    }
}
