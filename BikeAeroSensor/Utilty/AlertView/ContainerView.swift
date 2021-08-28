//
//  ContainerView.swift
//  Vae
//
//  Created by fanyinan on 2017/7/6.
//  Copyright © 2017年 Juxin. All rights reserved.
//

import UIKit

class ContainerView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let result = super.hitTest(point, with: event)
        
        if let targetView = result, targetView == self {
            return nil
        }
        
        return result
    }
    
}
