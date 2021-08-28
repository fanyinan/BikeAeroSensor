//
//  AbstractPoppingView.swift
//  VideoDemo
//
//  Created by 范祎楠 on 16/6/25.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class PoppingAbstractView: ContainerView {
    
    private(set) var popViewHelper: PopViewHelper!
    
    init(size: CGSize? = nil, viewPopDirection: ViewPopDirection, maskStatus: MaskStatus) {
        super.init(frame: CGRect.zero)
        initPopViewHelper(with: size, withViewPopDirection: viewPopDirection, maskStatus: maskStatus)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initPopViewHelper(with size: CGSize? = nil, withViewPopDirection viewPopDirection: ViewPopDirection, maskStatus: MaskStatus) {
        
        frame = CGRect(origin: CGPoint.zero, size: size ?? UIScreen.main.bounds.size)
        
        popViewHelper = PopViewHelper(superView: nil, targetView: self, viewPopDirection: viewPopDirection, maskStatus: maskStatus)
        
    }
    
    @discardableResult
    func show() -> Self {
        popViewHelper.showPoppingView()
        return self
    }
    
    @objc func hide() {
        popViewHelper.hidePoppingView()
    }
    
    func autoHidePopView(after delayTime: TimeInterval) {
        popViewHelper.hidePoppingView(after: delayTime)
    }
    
    func toggle() {
        
        if popViewHelper.isShow {
            popViewHelper.hidePoppingView()
        } else {
            popViewHelper.showPoppingView()
        }
    }
}
