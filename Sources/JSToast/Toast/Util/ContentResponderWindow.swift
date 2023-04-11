//
//  ContentResponderWindow.swift
//  
//
//  Created by JSilver on 2023/02/11.
//

import UIKit

class ContentResponderWindow: UIWindow {
    class RootViewController: UIViewController {
        // MARK: - Property
        
        // MARK: - Initializer
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }
        
        // MARK: - Public
        
        // MARK: - Private
    }
    
    // MARK: - Property
    
    // MARK: - Initializer
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        
        rootViewController = RootViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != rootViewController?.view else { return nil }
        return view
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
