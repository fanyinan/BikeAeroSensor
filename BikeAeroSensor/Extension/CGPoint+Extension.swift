//
//  CGPoint+Extension.swift
//  Vae
//
//  Created by fanyinan on 2019/3/27.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

extension CGPoint {
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
    static func +=(lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs + rhs
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt((self.x - point.x) * (self.x - point.x) + (self.y - point.y) * (self.y - point.y))
    }
    
    func offset(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}
