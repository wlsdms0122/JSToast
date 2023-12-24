//
//  ToastReader.swift
//
//
//  Created by jsilver on 12/17/23.
//

import SwiftUI

struct ToastContainerEnvironmentKey: EnvironmentKey {
    static var defaultValue: ToastContainer?
}

extension EnvironmentValues {
    var toastContainer: ToastContainer? {
        get {
            self[ToastContainerEnvironmentKey.self]
        }
        set {
            self[ToastContainerEnvironmentKey.self] = newValue
        }
    }
}

final class ToastContainer: ObservableObject {
    // MARK: - Property
    private(set) var toast: Toast?
    
    private var targets: [AnyHashable: UIView] = [:]
    
    // MARK: - Initializer
    init() { }
    
    // MARK: - Public
    func registerTarget(_ view: UIView, id: AnyHashable) {
        targets[id] = view
    }
    
    func show<Content: View>(
        withDuration duration: TimeInterval?,
        layouts: [ViewLayout],
        target: AnyHashable?,
        layer: ToastLayerProxy?,
        scene: ToastLayerProxy?,
        boundary: EdgeInsets,
        showAnimation: ToastAnimation,
        hideAnimation: ToastAnimation,
        shown: ((Bool) -> Void)?,
        hidden: ((Bool) -> Void)?,
        @ViewBuilder content: () -> Content
    ) {
        let target = target.map { id in targets[id] } ?? nil
        
        toast = Toast(content())
            .show(
                withDuration: duration,
                layouts: layouts.map { $0.layout(target) },
                layer: layer?.view,
                boundary: .init(
                    top: boundary.top,
                    left: boundary.leading,
                    bottom: boundary.bottom,
                    right: boundary.trailing
                ),
                ignoresSafeArea: true,
                scene: scene?.scene ?? layer?.scene ?? target?.window?.windowScene,
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
        animation: ToastAnimation = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        toast?.hide(
            animation: animation,
            completion: completion
        )
        
        toast = nil
    }
}

public struct ToastProxy {
    // MARK: - Property
    private var container: ToastContainer?
    
    // MARK: - Initializer
    init(container: ToastContainer? = nil) {
        self.container = container
    }
    
    // MARK: - Public
    public func show<Content: View>(
        withDuration duration: TimeInterval? = nil,
        layouts: [ViewLayout],
        target: AnyHashable? = nil,
        layer: ToastLayerProxy? = nil,
        scene: ToastLayerProxy? = nil,
        boundary: EdgeInsets = .init(.zero),
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        container?.show(
            withDuration: duration,
            layouts: layouts,
            target: target,
            layer: layer,
            scene: scene,
            boundary: boundary,
            showAnimation: showAnimation,
            hideAnimation: hideAnimation,
            shown: shown,
            hidden: hidden,
            content: content
        )
    }
    
    public func hide(
        animation: ToastAnimation = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        container?.hide(
            animation: animation,
            completion: completion
        )
    }
    
    // MARK: - Private
}

public struct ToastReader<Content: View>: View {
    // MARK: - View
    public var body: some View {
        content(ToastProxy(container: container))
            .environment(\.toastContainer, container)
    }
    
    // MARK: - Property
    @StateObject
    private var container = ToastContainer()
    private let content: (ToastProxy) -> Content
    
    // MARK: - Initializer
    public init(@ViewBuilder content: @escaping (ToastProxy) -> Content) {
        self.content = content
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
