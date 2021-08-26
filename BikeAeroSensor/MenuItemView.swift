//
//  MenuItemView.swift
//  Vae
//
//  Created by fanyinan on 2019/2/27.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

enum MenuItemStatus {
    case normal
    case extend
    case hidden
}

class MenuItemView: UIView {

    private var extendRectInScreen: CGRect!
    private var shadowView = UIView()
    private var dragMarkView = UIView()
    private var beginY: CGFloat = 0
    private var pan: UIPanGestureRecognizer!
    
    private(set) var normalRect: CGRect!
    private(set) var bottomUnavailableHeight: CGFloat = 0
    private(set) var contentView = UIView()
    private(set) var isExtending = false
    private(set) var extendPercent: CGFloat = 0
    private(set) var status: MenuItemStatus = .hidden
    private(set) var isDragging = false
    
    private var extendRect: CGRect { return menuView.convert(extendRectInScreen, from: nil) }

    private var contentViewTopMargin: CGFloat = 26
    private lazy var extendModeTopMargin: CGFloat = kFitHei(20)
    private let velocityThreshold: CGFloat = 50
    
    weak var menuView: UIView!
    
    var menuListOpaque = true
    var extendable = false
    
    var isUserInteractionEnabledForMenuList: Bool = true
//    {
//        didSet { menuView.isUserInteractionEnabledForMenuList = isUserInteractionEnabledForMenuList }
//    }
    
    var onHide: ((CGFloat) -> Void)?
    var dragable: Bool = true { didSet { pan.isEnabled = dragable }}
    let itemBackgroundColor = UIColor.menuBackground
    
    init() {
        super.init(frame: .zero)
        
        addSubview(shadowView)
        shadowView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        shadowView.setCornerRadius(14)
        shadowView.backgroundColor = itemBackgroundColor
 
        setShadow(color: .black, offset: CGSize(width: 0, height: -6), radius: 18, opacity: 0.12)
        
        dragMarkView.isUserInteractionEnabled = false
        addSubview(dragMarkView)
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        addGestureRecognizer(pan)
        
        contentView.clipsToBounds = true
        shadowView.addSubview(contentView)
    }
    
    func initSize(_ size: CGSize, bottomUnavailableHeight: CGFloat) {
        normalRect = CGRect(origin: .zero, size: size)
        self.bottomUnavailableHeight = bottomUnavailableHeight
        frame = normalRect
        let minYInExtend = SizeFitManager.shared.safeTopMargin + extendModeTopMargin
        extendRectInScreen = CGRect (x: 0, y: minYInExtend, width: size.width, height: SizeFitManager.shared.screenHeight - minYInExtend)
    }

    func willPresent() { }
    func willExtend() { }
    func willShrink() { }
    func didExtend() { }
    func didShrink() { }
    func willDismiss() { }
    func didDismiss() { }
    
    func present() {
        status = .normal
        normalRect.origin.y = minY
    }

    func extending(percent: CGFloat) {
        extendPercent = percent
//        menuView.layoutWhenExtending(percent: percent)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dragMarkView.backgroundColor = extendable ? .norm : #colorLiteral(red: 0.1335631907, green: 0.1327765882, blue: 0.1341726184, alpha: 1)
        shadowView.frame = bounds
        dragMarkView.frame.size = CGSize(width: 40, height: 4)
        dragMarkView.centerX = midX
        dragMarkView.centerY = contentViewTopMargin / 2
        dragMarkView.setCornerRadius()
        
        let baseHeight = extendable ? height : normalRect.height
        if menuListOpaque {
            contentView.frame.size = CGSize(width: frame.width, height: baseHeight - bottomUnavailableHeight - contentViewTopMargin)
        } else {
            contentView.frame.size = CGSize(width: frame.width, height: baseHeight - contentViewTopMargin)
        }
        
        switch status {
        case .hidden, .normal:
//            contentView.minY = contentViewTopMargin + (frame.height - normalRect.height) / 2
            contentView.minY = contentViewTopMargin
        case .extend:
            contentView.minY = contentViewTopMargin
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onPan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            isDragging = true
            beginY = minY
            menuView.addSubview(self)
            if status == .normal {
                willExtend()
            } else if status == .extend {
                willShrink()
            }
            
        case .changed:
            
            let moveY = gesture.translation(in: self).y
            var menuItemFrame = CGRect(x: 0, y: 0, width: width, height: 0)
            menuItemFrame.origin.y = beginY + moveY

            if extendable {
                
                if menuItemFrame.minY < extendRect.minY {
                    let dampMoveY = 20 * CGFloat(sin(Double((extendRect.minY - menuItemFrame.minY) / extendRectInScreen.minY) * Double.pi / 2))
                    menuItemFrame.origin.y = extendRect.minY - dampMoveY
                    
                }
                
                status = menuItemFrame.minY < normalRect.minY ? .extend : .normal
                
            } else {
                
                if menuItemFrame.minY < normalRect.minY {
                    let distanceToTopOfScreen = menuView.convert(CGPoint.zero, to: nil).y
                    let dampMoveY = 50 * CGFloat(sin(Double((normalRect.minY - menuItemFrame.minY) / distanceToTopOfScreen) * Double.pi / 2))
                    menuItemFrame.origin.y = normalRect.minY - dampMoveY
                }
            }
            
            if menuItemFrame.minY >= normalRect.minY {
                isExtending = false
                menuItemFrame.size.height = normalRect.height
            } else {
                menuItemFrame.size.height = menuView.height - menuItemFrame.minY + SizeFitManager.shared.safeBottomMargin
                if status == .extend {
                    let percent = (height - normalRect.height) / (extendRect.height - normalRect.height)
                    isExtending = true
                    extending(percent: percent)
                }
            }
            
            frame = menuItemFrame
            
        default:
            if status == .normal {
                let v = gesture.velocity(in: self).y
                let isHide = (v > velocityThreshold && height <= normalRect.height) || minY > height / 4
                if isHide {
                    extending(percent: 0)
                    onHide?(v)
                    status = .hidden
                } else {
                    restoreToNormal()
                }
            } else {
                let locationY = gesture.location(in: nil).y
                let v = gesture.velocity(in: self).y
                let normalYInScreen = superview!.convert(.zero, to: nil).y
                
                let isExtend: Bool
                
                if v < -velocityThreshold {
                    isExtend = true
                } else if v > velocityThreshold {
                    isExtend = false
                } else {
                   isExtend = locationY < (extendRectInScreen.minY + (normalYInScreen - extendRectInScreen.minY) / 2)
                }
                
                if isExtend {
                    restoreToExtend()
                    didExtend()
                } else {
                    restoreToNormal()
                    status = .normal
                    didShrink()
                }
            }
            isDragging = false
        }
    }
    
    private func restoreToExtend() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.extending(percent: 1)
            self.frame = self.extendRect
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }, completion: { _ in
//            self.menuView.addMenuItemToScreenView(self)
            self.isExtending = false
        })
    }
    
    private func restoreToNormal() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.extending(percent: 0)
            self.frame = self.normalRect
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }, completion: { _ in
            self.isExtending = false
        })
    }
}
