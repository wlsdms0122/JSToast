//
//  ToastModifier.swift
//  
//
//  Created by JSilver on 2023/03/18.
//

import SwiftUI

class ToastWrapper<Content: View> {
    // MARK: - Property
    private(set) var toast: Toast?
    private let content: () -> Content
    
    // MARK: - Initializer
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    // MARK: - Public
    func show(
        withDuration duration: TimeInterval?,
        layouts: [ViewLayout],
        target: UIView?,
        layer: UIView?,
        boundary: UIEdgeInsets,
        scene: UIWindowScene?,
        showAnimation: ToastAnimation,
        hideAnimation: ToastAnimation,
        shown: ((Bool) -> Void)?,
        hidden: ((Bool) -> Void)?
    ) {
        toast = Toast(content())
            .show(
                withDuration: duration,
                layouts: layouts.map { $0.layout(target) },
                layer: layer,
                boundary: boundary,
                ignoresSafeArea: true,
                scene: scene,
                showAnimation: showAnimation,
                hideAnimation: hideAnimation,
                shown: shown,
                hidden: { [weak self] in
                    self?.toast = nil
                    hidden?($0)
                }
            )
    }
    
    func hide(
        animation: ToastAnimation,
        completion: ((Bool) -> Void)? = nil
    ) {
        let toast = toast
        self.toast = nil
        
        toast?.hide(
            animation: animation,
            completion: completion
        )
    }
    
    // MARK: - Private
}

struct ToastView<Content: View>: UIViewRepresentable {
    // MARK: - Property
    @Binding
    private var isShow: Bool
    
    private let duration: TimeInterval?
    private let layouts: [ViewLayout]
    private let layer: UIView?
    private let boundary: UIEdgeInsets
    private let showAnimation: ToastAnimation
    private let hideAnimation: ToastAnimation
    private let shown: ((Bool) -> Void)?
    private let hidden: ((Bool) -> Void)?
    private let content: () -> Content
    
    // MARK: - Initializer
    public init(
        _ isShow: Binding<Bool>,
        duration: TimeInterval?,
        layouts: [ViewLayout],
        layer: UIView?,
        boundary: UIEdgeInsets,
        showAnimation: ToastAnimation,
        hideAnimation: ToastAnimation,
        shown: ((Bool) -> Void)?,
        hidden: ((Bool) -> Void)?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isShow = isShow
        
        self.duration = duration
        self.layouts = layouts
        self.layer = layer
        self.boundary = boundary
        self.showAnimation = showAnimation
        self.hideAnimation = hideAnimation
        self.shown = shown
        self.hidden = hidden
        self.content = content
    }
    
    // MARK: - Lifecycle
    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: some UIView, context: Context) {
        if context.coordinator.toast == nil && isShow {
            // Show toast
            context.coordinator.show(
                withDuration: duration,
                layouts: layouts,
                target: uiView,
                layer: layer,
                boundary: boundary,
                scene: uiView.window?.windowScene,
                showAnimation: showAnimation,
                hideAnimation: hideAnimation,
                shown: shown,
                hidden: {
                    isShow = false
                    hidden?($0)
                }
            )
        } else if context.coordinator.toast != nil && !isShow {
            // Hide toast
            context.coordinator.hide(
                animation: hideAnimation,
                completion: self.hidden
            )
        }
    }
    
    func makeCoordinator() -> ToastWrapper<Content> {
        ToastWrapper(content: content)
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
