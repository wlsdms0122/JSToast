//
//  ToastContainer.swift
//  
//
//  Created by JSilver on 2023/04/13.
//

import SwiftUI

public struct ToastContainer<Content: View>: UIViewRepresentable {
    public class Coordinator {
        private let controller: UIHostingController<AnyView>
        var view: UIView { controller.view }
        
        init() {
            let viewController = UIHostingController<AnyView>(rootView: AnyView(EmptyView()))
            viewController.view.backgroundColor = .clear
            
            self.controller = viewController
        }
        
        func update(_ content: Content) {
            controller.rootView = AnyView(content)
        }
    }
    // MARK: - Property
    /// This property is not used. The state of the closure does not affect the view rendering hash,
    /// so an arbitrary result value is generated to distinguish the views.
    private let _dummyContent: Content
    private let content: (UIView) -> Content
    
    // MARK: - Initializer
    public init(@ViewBuilder content: @escaping (UIView) -> Content) {
        self._dummyContent = content(UIView())
        self.content = content
    }
    
    // MARK: - Lifecycle
    public func makeUIView(context: Context) -> UIView {
        IntrinsicContentView(context.coordinator.view)
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.update(content(uiView))
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
