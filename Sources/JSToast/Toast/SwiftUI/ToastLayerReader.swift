//
//  ToastContainer.swift
//  
//
//  Created by JSilver on 2023/04/13.
//

import SwiftUI
import Combine

public class ToastLayerProxy {
    // MARK: - Property
    public private(set) var view: UIView?
    public private(set) var scene: UIWindowScene?
    
    // MARK: - Initializer
    
    // MARK: - Public
    func register(view: UIView) {
        self.view = view
        self.scene = view.window?.windowScene
    }
    
    // MARK: - Private
}

public class ToastLayerViewController: UIHostingController<AnyView> {
    // MARK: - Property
    let proxy = ToastLayerProxy()
    
    // MARK: - Lifecycle
    public override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        proxy.register(view: view)
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

public struct ToastLayerReader<Content: View>: UIViewControllerRepresentable {
    // MARK: - Property
    private let content: (ToastLayerProxy) -> Content
    
    // MARK: - Initializer
    public init(@ViewBuilder content: @escaping (ToastLayerProxy) -> Content) {
        self.content = content
    }
    
    // MARK: - Lifecycle
    public func makeUIViewController(context: Context) -> ToastLayerViewController {
        let viewController = ToastLayerViewController(rootView: AnyView(EmptyView()))
        viewController.view.backgroundColor = .clear
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ToastLayerViewController, context: Context) {
        uiViewController.rootView = AnyView(content(uiViewController.proxy))
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
