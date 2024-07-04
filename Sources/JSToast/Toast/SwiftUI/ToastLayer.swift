//
//  ToastLayer.swift
//
//
//  Created by JSilver on 2023/04/13.
//

import SwiftUI

public struct ToastLayer<ID: Hashable, Content: View>: UIViewControllerRepresentable {
    public final class Coordinator {
        // MARK: - Property
        let container = ToastContainer()
        
        // MARK: - Initializer
        
        // MARK: - Public
        
        // MARK: - Private
    }
    
    // MARK: - Property
    private let id: ID
    private let content: (UIView) -> Content
    
    // MARK: - Initializer
    public init(_ id: ID, @ViewBuilder content: @escaping (UIView) -> Content) {
        self.id = id
        self.content = content
    }
    
    // MARK: - Lifecycle
    public func makeUIViewController(context: Context) -> UIHostingController<AnyView> {
        let viewController = UIHostingController(rootView: AnyView(EmptyView()))
        viewController.view.backgroundColor = .clear
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIHostingController<AnyView>, context: Context) {
        let container = context.environment.toastContainer ?? context.coordinator.container
        container.registerTarget(uiViewController.view, id: id)
        
        uiViewController.rootView = AnyView(
            content(uiViewController.view)
                .environment(\.toastContainer, container)
        )
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
