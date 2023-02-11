//
//  ContentResponderWindow.swift
//  
//
//  Created by JSilver on 2023/02/11.
//

import UIKit

class ContentResponderWindow: UIWindow {
    // MARK: - Property
    
    // MARK: - Initializer
    
    // MARK: - Lifecycle
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return nil }
        return view
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
