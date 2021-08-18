//
//  UIView+Layout.swift
//  Vae
//
//  Created by fanyinan on 2018/9/11.
//  Copyright © 2018 fanyinan. All rights reserved.
//

import UIKit

extension UIView {
    
    var centerX: CGFloat {
        
        get{
            return center.x
        }
        
        set {
            center.x = newValue
        }
    }
    
    var centerY: CGFloat {
        
        get{
            return center.y
        }
        
        set {
            center.y = newValue
        }
    }
    
    var midX: CGFloat {
        return bounds.width / 2
    }
    
    var midY: CGFloat {
        return bounds.height / 2
    }
    
    var mid: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    func centerInSuperview() {
        guard let superview = superview else { return }
        center = superview.mid
    }
    
    func centerXInSuperview(margin: CGFloat? = nil) {
        guard let superview = superview else { return }
        if let margin = margin {
            width = superview.width - margin * 2
        }
        centerX = superview.midX
    }
    
    func centerYInSuperview() {
        guard let superview = superview else { return }
        centerY = superview.midY
    }
    
    func centerSubviewsVertical() {
        
        for subview in subviews {
            subview.centerY = midY
        }
    }
    
    var rightMargin: CGFloat? {
        
        get {
            guard let superview = superview else { return nil }
            return superview.frame.width - frame.maxX
        }
        
        set {
            guard let newValue = newValue, let superview = superview else { return }
            frame.origin.x = superview.frame.width - newValue - frame.width
        }
    }
    
    var minY: CGFloat {
        
        get {
            return frame.minY
        }
        
        set {
            frame.origin.y = newValue
        }
    }
    
    var minX: CGFloat {
        
        get {
            return frame.minX
        }
        
        set {
            frame.origin.x = newValue
        }
    }
    
    var maxY: CGFloat {
        
        get {
            return frame.maxY
        }
        
        set {
            frame.origin.y = newValue - frame.height
        }
    }
    
    var maxX: CGFloat {
        
        get {
            return frame.maxX
        }
        
        set {
            frame.origin.x = newValue - frame.width
        }
    }
    
    var height: CGFloat {
        
        get {
            return frame.height
        }
        
        set {
            frame.size.height = newValue
        }
    }
    
    var width: CGFloat {
        
        get {
            return frame.width
        }
        
        set {
            frame.size.width = newValue
        }
    }
    
    var size: CGSize {
        
        get {
            return frame.size
        }
        
        set {
            frame.size = newValue
        }
    }
    
    var origin: CGPoint {
        
        get {
            return frame.origin
        }
        
        set {
            frame.origin = newValue
        }
    }
    
    var bottomMargin: CGFloat? {
        
        get {
            guard let superview = superview else { return nil }
            return superview.frame.height - frame.maxY
        }
        
        set {
            guard let newValue = newValue, let superview = superview else { return }
            frame.origin.y = superview.frame.height - newValue - frame.height
        }
    }
    
    func moveTo(_ view: UIView) {
        guard let superview = superview else { return }
        frame = superview.convert(frame, to: view)
        view.addSubview(self)
    }
    
    func moveToBottom(_ view: UIView) {
        guard let superview = superview else { return }
        frame = superview.convert(frame, to: view)
        view.insertSubview(self, at: 0)
    }
    
    func makeFrame(block: (UIView) -> Void) {
        
        let virtualView = UIView()
        var virtualSuperview: UIView?

        if let superview = superview {
            let _virtualSuperview = UIView()
            _virtualSuperview.frame = superview.bounds
            _virtualSuperview.addSubview(virtualView)
            virtualSuperview = _virtualSuperview
        }
        
        virtualView.frame = frame
        
        block(virtualView)
        
        frame = virtualView.frame
        
        virtualView.removeFromSuperview()
        virtualSuperview?.removeFromSuperview()
    }
    
    func zoom(by size: CGSize) {
        let newFrame = frame.zoom(by: size)
        frame = newFrame
    }
    
    func zoom(to size: CGSize) {
        let newFrame = frame.zoom(to: size)
        frame = newFrame
    }
    
    func top(of view: UIView, offset: CGFloat) {
        maxY = view.minY - offset
    }
    
    func bottom(of view: UIView, offset: CGFloat) {
        minY = view.maxY + offset
    }
    
    func left(of view: UIView, offset: CGFloat) {
        maxX = view.minX - offset
    }
    
    func setBottomMargin(_ margin: CGFloat, flexHeight isFlexHeight: Bool = false) {
        guard let superview = superview else { return }
        if isFlexHeight {
            height = superview.height - minY - margin
        } else {
            maxY = superview.height - margin
        }
    }
    
    func frame(in view: UIView?) -> CGRect {
        return convert(bounds, to: view)
    }
    
    convenience init(width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
}
