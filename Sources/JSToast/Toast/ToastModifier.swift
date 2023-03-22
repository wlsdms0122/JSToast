//
//  ToastModifier.swift
//  
//
//  Created by JSilver on 2023/03/18.
//

import SwiftUI

@available(iOS 14.0, *)
class ToastContainer<ToastContent: View>: ObservableObject {
    private var toast: Toast?
    private let content: () -> ToastContent
    
    init(@ViewBuilder content: @escaping () -> ToastContent) {
        self.content = content
    }
    
    func show(
        withDuration duration: TimeInterval? = nil,
        layouts: [Layout],
        target: UIView? = nil,
        scene: UIWindowScene? = nil,
        boundary: EdgeInsets = .init(.zero),
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil
    ) {
        toast = Toast(content).show(
            withDuration: duration,
            layouts: layouts,
            target: target,
            scene: scene,
            boundary: UIEdgeInsets(boundary),
            ignoresSafeArea: true,
            showAnimation: showAnimation,
            hideAnimation: hideAnimation,
            shown: shown,
            hidden: { [weak self] in
                self?.toast = nil
                hidden?($0)
            }
        )
    }
    open func hide(
        animation: ToastAnimation,
        completion: ((Bool) -> Void)? = nil
    ) {
        toast?.hide(
            animation: animation,
            completion: { [weak self] in
                self?.toast = nil
                completion?($0)
            }
        )
    }
}

@available(iOS 14.0, *)
public struct ToastModifier<ToastContent: View>: ViewModifier {
    private let duration: TimeInterval?
    private let layouts: [Layout]
    private let boundary: EdgeInsets
    private let showAnimation: ToastAnimation
    private let hideAnimation: ToastAnimation
    private let shown: ((Bool) -> Void)?
    private let hidden: ((Bool) -> Void)?
    
    @Binding
    private var isShow: Bool
    @StateObject
    private var container: ToastContainer<ToastContent>
    
    @State
    private var frame: CGRect = .zero
    
    public init(
        _ isShow: Binding<Bool>,
        duration: TimeInterval? = nil,
        layouts: [ViewLayout],
        boundary: EdgeInsets = .init(.zero),
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> ToastContent
    ) {
        self._isShow = isShow
        self._container = .init(wrappedValue: ToastContainer(content: content))
        
        self.duration = duration
        self.layouts = layouts
        self.boundary = boundary
        self.showAnimation = showAnimation
        self.hideAnimation = hideAnimation
        self.shown = shown
        self.hidden = hidden
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
                
                container.show(
                    withDuration: duration,
                    layouts: layouts,
                    target: dummyView,
                    boundary: boundary,
                    showAnimation: showAnimation,
                    hideAnimation: hideAnimation,
                    shown: shown,
                    hidden: {
                        isShow = false
                        hidden?($0)
                    }
                )
            } else {
                container.hide(
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
        layouts: [ViewLayout],
        boundary: EdgeInsets = .init(.zero),
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil,
        @ViewBuilder toastContent: @escaping () -> ToastContent
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
            content: toastContent
        ))
    }
}
