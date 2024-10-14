//
//  ContentResponderWindow.swift
//
//
//  Created by jsilver on 2023/02/11.
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
        if #available(iOS 18, *) {
            let view = super.hitTest(point, with: event)
            guard let view, _hitTest(point, from: view) != rootViewController?.view else { return nil }
            return view
        } else {
            let view = super.hitTest(point, with: event)
            guard view != rootViewController?.view else { return nil }
            return view
        }
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func _hitTest(_ point: CGPoint, from view: UIView) -> UIView? {
        let converted = convert(point, to: view)
        
        guard view.bounds.contains(converted)
            && view.isUserInteractionEnabled
            && !view.isHidden
            && view.alpha > 0
        else { return nil }
        
        return view.subviews.reversed()
            .reduce(Optional<UIView>.none) { result, view in
                result ?? _hitTest(point, from: view)
            } ?? view
    }
}
