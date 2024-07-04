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
    class WeakRef<T: AnyObject> {
        // MARK: - Property
        weak var value: T?
        
        // MARK: - Initializer
        init(_ value: T?) {
            self.value = value
        }
        
        // MARK: - Public
        
        // MARK: - Private
    }
    
    // MARK: - Property
    private var toasts: [AnyHashable: Toast] = [:]
    
    private var targets: [AnyHashable: WeakRef<UIView>] = [:]
    
    // MARK: - Initializer
    init() { }
    
    // MARK: - Public
    func sync(with container: ToastContainer) {
        targets.merge(container.targets) { lhs, rhs in rhs }
    }
    
    func registerTarget(_ view: UIView, id: AnyHashable) {
        targets[id] = WeakRef(view)
    }
    
    func target(_ id: some Hashable) -> UIView? {
        targets[id]?.value
    }
    
    func show<Content: View>(
        _ id: some Hashable,
        withDuration duration: TimeInterval?,
        layouts: [ViewLayout],
        target: (some Hashable)?,
        layer: (some Hashable)?,
        scene: UIWindowScene?,
        boundary: EdgeInsets,
        showAnimation: ToastAnimation,
        hideAnimation: ToastAnimation,
        shown: ((Bool) -> Void)?,
        hidden: ((Bool) -> Void)?,
        @ViewBuilder content: () -> Content
    ) {
        let target = target.map { id in targets[id]?.value } ?? nil
        let layer = layer.map { id in targets[id]?.value } ?? nil
        
        toasts[id] = Toast(content())
            .show(
                withDuration: duration,
                layouts: layouts.map { $0.layout(target) },
                layer: layer,
                boundary: .init(
                    top: boundary.top,
                    left: boundary.leading,
                    bottom: boundary.bottom,
                    right: boundary.trailing
                ),
                ignoresSafeArea: true,
                scene: scene ?? layer?.window?.windowScene ?? target?.window?.windowScene,
                showAnimation: showAnimation,
                hideAnimation: hideAnimation,
                shown: shown,
                hidden: { [weak self] in
                    self?.toasts.removeValue(forKey: id)
                    hidden?($0)
                }
            )
    }
    
    func hide(
        _ id: some Hashable,
        animation: ToastAnimation = .fadeOut(duration: 0.3),
        completion: ((Bool) -> Void)? = nil
    ) {
        toasts[id]?.hide(
            animation: animation,
            completion: completion
        )
        
        toasts.removeValue(forKey: id)
    }
}

@dynamicMemberLookup
public struct ToastProxy {
    public struct ToasterProxy {
        // MARK: - Property
        private let id: String
        private let container: ToastContainer
        
        // MARK: - Initializer
        init(_ id: String, container: ToastContainer) {
            self.container = container
            self.id = id
        }
        
        // MARK: - Public
        public func show<Content: View>(
            withDuration duration: TimeInterval? = nil,
            layouts: [ViewLayout],
            target: (some Hashable)? = Optional<Int>.none,
            layer: (some Hashable)? = Optional<Int>.none,
            scene: UIWindowScene? = nil,
            boundary: EdgeInsets = .init(.zero),
            showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
            hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
            shown: ((Bool) -> Void)? = nil,
            hidden: ((Bool) -> Void)? = nil,
            @ViewBuilder content: () -> Content
        ) {
            container.show(
                id,
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
            container.hide(
                id,
                animation: animation,
                completion: completion
            )
        }
        
        // MARK: - Private
    }
    
    // MARK: - Property
    private let container: ToastContainer
    
    // MARK: - Initializer
    init(container: ToastContainer) {
        self.container = container
    }
    
    // MARK: - Public
    public subscript(dynamicMember id: String) -> ToasterProxy {
        ToasterProxy(id, container: container)
    }
    
    public func target(_ id: some Hashable) -> UIView? {
        container.target(id)
    }
    
    public func show<Content: View>(
        withDuration duration: TimeInterval? = nil,
        layouts: [ViewLayout],
        target: (some Hashable)? = Optional<Int>.none,
        layer: (some Hashable)? = Optional<Int>.none,
        scene: UIWindowScene? = nil,
        boundary: EdgeInsets = .init(.zero),
        showAnimation: ToastAnimation = .fadeIn(duration: 0.3),
        hideAnimation: ToastAnimation = .fadeOut(duration: 0.3),
        shown: ((Bool) -> Void)? = nil,
        hidden: ((Bool) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        container.show(
            "_default",
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
        container.hide(
            "_default",
            animation: animation,
            completion: completion
        )
    }
    
    // MARK: - Private
}

public struct ToastReader<Content: View>: View {
    // MARK: - View
    public var body: some View {
        let container: ToastContainer = {
            guard let toastContainer else { return self.container }
            
            self.container.sync(with: toastContainer)
            return self.container
        }()
        
        content(ToastProxy(container: container))
            .environment(\.toastContainer, container)
    }
    
    // MARK: - Property
    @Environment(\.toastContainer)
    private var toastContainer: ToastContainer?
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
