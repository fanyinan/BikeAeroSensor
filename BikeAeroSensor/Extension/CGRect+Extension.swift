//
//  CGRect+Extension.swift
//  Vae
//
//  Created by fanyinan on 2019/3/27.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

extension CGRect {
    
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
    
    var maxX: CGFloat {
        
        get {
            return origin.x + width
        }
        
        set {
            origin.x = newValue - width
        }
    }
    
    var minX: CGFloat {
        
        get {
            return origin.x
        }
        
        set {
            origin.x = newValue
        }
    }
    
    var maxY: CGFloat {
        
        get {
            return origin.y + height
        }
        
        set {
            origin.y = newValue - height
        }
    }
    
    var minY: CGFloat {
        
        get {
            return origin.y
        }
        
        set {
            origin.y = newValue
        }
    }
    
    func zoom(by size: CGSize) -> CGRect {
        var frame = self
        frame.size.width += size.width
        frame.size.height += size.height
        frame.origin.x -= size.width / 2
        frame.origin.y -= size.height / 2
        return frame
    }
    
    func zoom(to size: CGSize) -> CGRect {
        var frame = self
        frame = frame.zoom(by: CGSize(width: size.width - frame.width, height: size.height - frame.height))
        return frame
    }
    
    func zoom(by edge: UIEdgeInsets) -> CGRect {
        var frame = self
        frame.size.width += (edge.left + edge.right)
        frame.size.height += (edge.top + edge.bottom)
        frame.origin.x -= edge.left
        frame.origin.y -= edge.top
        return frame
    }
    
    func scale(_ scale: CGFloat) -> CGRect {
        
        let newWidth = width * scale
        let newHeight = self.height * scale
        
        return CGRect(x: (width - newWidth) / 2, y: (height - newHeight), width: newWidth, height: newHeight)
    }
    
    var ceilValue: CGRect {
        return CGRect(x: ceil(minX), y: ceil(minY), width: ceil(width), height: ceil(height))
    }
}
