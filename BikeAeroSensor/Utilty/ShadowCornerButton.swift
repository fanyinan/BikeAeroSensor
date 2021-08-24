//
//  ShadowCornerButton.swift
//  Vae
//
//  Created by 范祎楠 on 2019/5/26.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

class ShadowCornerButton: UIControl {
    
    private(set) var contentView = UIView()
    
    override var backgroundColor: UIColor? {
        set{
            contentView.backgroundColor = newValue
        }
        
        get {
            return contentView.backgroundColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        contentView.layer.masksToBounds = true
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let r = super.hitTest(point, with: event)
        return r
    }
    
    override func addSubview(_ view: UIView) {
        if view == contentView {
            super.addSubview(view)
        } else {
            contentView.addSubview(view)
        }
    }
    
    func addSublayer(_ layer: CALayer) {
        contentView.layer.addSublayer(layer)
    }
    
    func setRadius(_ radius: CGFloat? = nil) {
        
        if let radius = radius {
            if radius == 0 {
                contentView.layer.masksToBounds = false
                contentView.layer.cornerRadius = 0
            } else {
                contentView.layer.masksToBounds = true
                contentView.layer.cornerRadius = radius
            }
            
        } else {
            contentView.layer.masksToBounds = true
            contentView.layer.cornerRadius =  height / 2
        }
    }
    
    func setRadius(_ radius: CGFloat, lineWidth: CGFloat, lineColor: UIColor) {
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = lineWidth
        contentView.layer.borderColor = lineColor.cgColor
    }
}
