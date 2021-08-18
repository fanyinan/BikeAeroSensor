//
//  UIView+Common.swift
//  Vae
//
//  Created by fanyinan on 2018/9/11.
//  Copyright © 2018 fanyinan. All rights reserved.
//

import UIKit

extension UIView {
    
    @discardableResult
    func addTapGestureRecognizer(target: Any?, action: Selector?) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tap)
        return tap
    }
    
    @discardableResult
    func addPanGestureRecognizer(target: Any?, action: Selector?) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer(target: target, action: action)
        addGestureRecognizer(pan)
        return pan
    }
    
    func setCornerRadius(_ radius: CGFloat? = nil) {
        
        if let radius = radius {
            if radius == 0 {
                layer.masksToBounds = false
                layer.cornerRadius = 0
            } else {
                layer.masksToBounds = true
                layer.cornerRadius = radius
            }
            
        } else {
            layer.masksToBounds = true
            layer.cornerRadius = min(width, height) / 2
        }
        
    }
    
    func setShadow(color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
    
    func setShadow(color: UIColor, offsetX: CGFloat, offsetY: CGFloat, radius: CGFloat, opacity: Float) {
        setShadow(color: color, offset: CGSize(width: offsetX, height: offsetY), radius: radius, opacity: opacity)
    }
    
    func setBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func clearBorder() {
        layer.borderColor = nil
        layer.borderWidth = 0
    }
    
    func removeAllSubviews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func removeShadow() {
        
        layer.shadowColor = nil
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0
    }
    
    func frame(in view: UIView) -> CGRect {
        return convert(bounds, to: view)
    }
    
    var viewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let _parentResponder = parentResponder {
            parentResponder = _parentResponder.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func findView<T: UIView>(viewType: T.Type) -> [T] {
        
        var results: [UIView] = []
        traverseSubviews(view: self, results: &results, condition: { $0.classForCoder == viewType })
        return results.compactMap({ $0 as? T })
    }
    
    func setStyle(isEnable: Bool) {
        alpha = isEnable ? 1 : 0.3
    }
    
    private func traverseSubviews(view: UIView, results: inout [UIView], condition: (UIView) -> Bool) {
        
        if condition(view) {
            results.append(view)
        }
        
        for subview in view.subviews {
             traverseSubviews(view: subview, results: &results, condition: condition)
        }
    }
}
