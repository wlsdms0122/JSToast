//
//  ToastModifier.swift
//  
//
//  Created by JSilver on 2023/03/18.
//

import SwiftUI

extension Toast: ObservableObject {
    
}

@available(iOS 14.0, *)
public struct ToastModifier<ToastContent: View>: ViewModifier {
    @Binding
    public var isShow: Bool
    public var duration: TimeInterval?
    public var layouts: [JSToast.Layout]
    public var boundary: EdgeInsets
    public var showAnimation: JSToast.Animation
    public var hideAnimation: JSToast.Animation
    public var shown: ((Bool) -> Void)?
    public var hidden: ((Bool) -> Void)?
    
    @StateObject
    private var toast: Toast
    @State
    private var frame: CGRect = .zero
    
    public init(
        _ isShow: Binding<Bool>,
        duration: TimeInterval? = nil,
        layouts: [JSToast.Layout],
        boundary: EdgeInsets = .init(.zero),
        showAnimation: JSToast.Animation = .fadeIn(duration: 0.3),
        hideAnimation: JSToast.Animation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil,
        @ViewBuilder toast: @escaping () -> ToastContent
    ) {
        self._isShow = isShow
        self.duration = duration
        self.layouts = layouts
        self.boundary = boundary
        self.showAnimation = showAnimation
        self.hideAnimation = hideAnimation
        self.shown = shown
        self.hidden = hidden
        self._toast = .init(wrappedValue: Toast(toast))
    }
    
    public func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { reader in
                let frame = reader.frame(in: .global)
                
                Color.clear
                    .onAppear {
                        self.frame = frame
                    }
                    .onChange(of: frame) {
                        self.frame = $0
                    }
            }
        )
        .onChange(of: isShow) {
            if $0 {
                let dummyView = UIView(frame: frame)
                
                toast.show(
                    withDuration: duration,
                    layouts: layouts,
                    target: dummyView,
                    boundary: UIEdgeInsets(boundary),
                    showAnimation: showAnimation,
                    hideAnimation: hideAnimation,
                    shown: shown,
                    hidden: {
                        isShow = false
                        hidden?($0)
                    }
                )
            } else {
                toast.hide(
                    animation: hideAnimation,
                    completion: hidden
                )
            }
        }
    }
}

public extension View {
    @available(iOS 14.0, *)
    func toast<ToastContent: View>(
        _ isShow: Binding<Bool>,
        duration: TimeInterval? = nil,
        layouts: [JSToast.Layout],
        boundary: EdgeInsets = .init(.zero),
        showAnimation: JSToast.Animation = .fadeIn(duration: 0.3),
        hideAnimation: JSToast.Animation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil,
        @ViewBuilder toast: @escaping () -> ToastContent
    ) -> some View {
        modifier(ToastModifier(
            isShow,
            duration: duration,
            layouts: layouts,
            boundary: boundary,
            showAnimation: showAnimation,
            hideAnimation: hideAnimation,
            shown: shown,
            hidden: hidden,
            toast: toast
        ))
    }
}
