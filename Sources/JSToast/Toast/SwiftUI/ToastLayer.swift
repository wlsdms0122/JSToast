//
//  ToastLayer.swift
//
//
//  Created by JSilver on 2023/04/13.
//

import SwiftUI

public final class LayerProxy {
    // MARK: - Property
    public private(set) weak var view: UIView?
    
    public var window: UIWindow? { view?.window }
    
    // MARK: - Initializer
    init(_ view: UIView? = nil) {
        self.view = view
    }
    
    // MARK: - Public
    func set(_ view: UIView?) {
        self.view = view
    }
    
    // MARK: - Private
}

public struct ToastLayer<ID: Hashable, Content: View>: UIViewControllerRepresentable {
    public final class Coordinator {
        // MARK: - Property
        let container = ToastContainer()
        let layer = LayerProxy()
        
        // MARK: - Initializer
        
        // MARK: - Public
        
        // MARK: - Private
    }
    
    // MARK: - Property
    private let id: ID
    private let content: (LayerProxy) -> Content
    
    // MARK: - Initializer
    public init(_ id: ID, @ViewBuilder content: @escaping (LayerProxy) -> Content) {
        self.id = id
        self.content = content
    }
    
    // MARK: - Lifecycle
    public func makeUIViewController(context: Context) -> UIHostingController<AnyView> {
        let viewController = UIHostingController(rootView: AnyView(EmptyView()))
        viewController.view.backgroundColor = .clear
        
        // Set layer
        context.coordinator.layer.set(viewController.view)
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIHostingController<AnyView>, context: Context) {
        let container = context.environment.toastContainer ?? context.coordinator.container
        container.registerTarget(uiViewController.view, id: id)
        
        uiViewController.rootView = AnyView(
            content(context.coordinator.layer)
                .environment(\.toastContainer, container)
        )
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
