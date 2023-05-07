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

public struct ToastContainer<Content: View>: UIViewControllerRepresentable {
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
    public func makeUIViewController(context: Context) -> UIHostingController<AnyView> {
        UIHostingController(rootView: AnyView(EmptyView()))
    }
    
    public func updateUIViewController(_ uiViewController: UIHostingController<AnyView>, context: Context) {
        uiViewController.rootView = AnyView(content(ToastLayer(uiViewController.view)))
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
