//
//  UIEdgeInsets+EdgeInsets.swift
//  
//
//  Created by JSilver on 2023/03/18.
//

import UIKit
import SwiftUI

extension UIEdgeInsets {
    init(_ edgeInsets: EdgeInsets) {
        self.init(
            top: edgeInsets.top,
            left: edgeInsets.leading,
            bottom: edgeInsets.trailing,
            right: edgeInsets.bottom
        )
    }
}
