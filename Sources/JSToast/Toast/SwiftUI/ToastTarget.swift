//
//  ToastTarget.swift
//
//
//  Created by JSilver on 2023/03/18.
//

import SwiftUI

struct ToastTarget<ID: Hashable>: UIViewRepresentable {
    // MARK: - Property
    private let id: ID
    
    // MARK: - Initializer
    public init(id: ID) { 
        self.id = id
    }
    
    // MARK: - Lifecycle
    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: some UIView, context: Context) {
        context.environment.toastContainer?
            .registerTarget(uiView, id: id)
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

public extension View {
    func toastTarget<ID: Hashable>(_ id: ID) -> some View {
        overlay(ToastTarget(id: id).allowsHitTesting(false))
    }
}
