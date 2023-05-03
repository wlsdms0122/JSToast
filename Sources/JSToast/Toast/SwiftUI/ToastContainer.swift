//
//  ToastContainer.swift
//  
//
//  Created by JSilver on 2023/04/13.
//

import SwiftUI

public struct ToastLayer {
    // MARK: - Property
    public weak var view: UIView?
    
    // MARK: - Initializer
    init(_ view: UIView? = nil) {
        self.view = view
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

public struct ToastContainer<Content: View>: UIViewRepresentable {
    public class Coordinator {
        // MARK: - Property
        private let controller: UIHostingController<AnyView>
        var view: UIView { controller.view }
        
        // MARK: - Initializer
        init() {
            let viewController = UIHostingController<AnyView>(rootView: AnyView(EmptyView()))
            viewController.view.backgroundColor = .clear
            
            self.controller = viewController
        }
        
        // MARK: - Public
        func update(_ content: (ToastLayer) -> Content) {
            controller.rootView = AnyView(content(ToastLayer(view)))
        }
        
        // MARK: - Private
    }
    
    // MARK: - Property
    /// This property is not used. The state of the closure does not affect the view rendering hash,
    /// so an arbitrary result value is generated to distinguish the views.
    private let _dummyContent: Content
    private let content: (ToastLayer) -> Content
    
    // MARK: - Initializer
    public init(@ViewBuilder content: @escaping (ToastLayer) -> Content) {
        self._dummyContent = content(ToastLayer())
        self.content = content
    }
    
    // MARK: - Lifecycle
    public func makeUIView(context: Context) -> UIView {
        context.coordinator.view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.update(content)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
