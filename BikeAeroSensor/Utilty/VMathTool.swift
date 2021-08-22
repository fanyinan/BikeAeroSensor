//
//  VMathTool.swift
//  Vae
//
//  Created by fanyinan on 2018/10/19.
//  Copyright © 2018 fanyinan. All rights reserved.
//

import UIKit
import CoreMedia

class VMathTool {
    
    static func mix(v1: CGFloat, v2: CGFloat, t: CGFloat) -> CGFloat {
        return (v2 - v1) * t + v1
    }
    
    static func mix(v1: Double, v2: Double, t: Double) -> Double {
        return (v2 - v1) * t + v1
    }
    
    static func mix(rect1: CGRect, rect2: CGRect, t: CGFloat) -> CGRect {
        
        let x = mix(v1: rect1.minX, v2: rect2.minX, t: t)
        let y = mix(v1: rect1.minY, v2: rect2.minY, t: t)
        let width = mix(v1: rect1.width, v2: rect2.width, t: t)
        let height = mix(v1: rect1.height, v2: rect2.height, t: t)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    static func mix(point1: CGPoint, point2: CGPoint, t: CGFloat) -> CGPoint {
        
        let x = mix(v1: point1.x, v2: point2.x, t: t)
        let y = mix(v1: point1.y, v2: point2.y, t: t)
        
        return CGPoint(x: x, y: y)
    }
    
    static func mix(v1: CMTime, v2: CMTime, t: CGFloat) -> CMTime {
        guard t != 0 else { return v1 }
        let diff = v2 - v1
        return CMTime(value: diff.value, timescale: CMTimeScale(CGFloat(diff.timescale) / t)) + v1
    }
    
    static func mix(insets1: UIEdgeInsets, insets2: UIEdgeInsets, t: CGFloat) -> UIEdgeInsets {
        
        let left = mix(v1: insets1.left, v2: insets2.left, t: t)
        let right = mix(v1: insets1.right, v2: insets2.right, t: t)
        let top = mix(v1: insets1.top, v2: insets2.top, t: t)
        let bottom = mix(v1: insets1.bottom, v2: insets2.bottom, t: t)
        
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    static func clamp<T: Comparable>(value: T, minValue: T, maxValue: T) -> T {
        return max(min(value, maxValue), minValue)
    }
    
    static func percent(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        guard min != max else { return 1 }
        return (value - min) / (max - min)
    }
    
    static func percent(min: Double, max: Double, value: Double) -> Double {
        guard min != max else { return 1 }
        return (value - min) / (max - min)
    }
    
    static func percent(min: Float, max: Float, value: Float) -> Float {
        guard min != max else { return 1 }
        return (value - min) / (max - min)
    }
    
    static func percent(min: Int, max: Int, value: Int) -> Double {
        guard min != max else { return 1 }
        return Double(value - min) / Double(max - min)
    }
}
