//
//  PopViewManager.swift
//  Vae
//
//  Created by fanyinan on 2017/6/29.
//  Copyright © 2017年 Juxin. All rights reserved.
//

import Foundation

class PopViewManager {
    
    static let shared = PopViewManager()
    
    private(set) var popViewHelperContainers: [PopViewHelperContainer] = []
    private(set) var popViewHelperQueue: [PopViewHelper] = []
    private weak var showingPoppingViewHelper: PopViewHelper?
    
    func add(popViewHelper: PopViewHelper) {
        
        clearReleased()
        
        popViewHelperContainers.append(PopViewHelperContainer(popViewHelper: popViewHelper))
    }
    
    func contains(for targetType: PoppingAbstractView.Type) -> Bool {
        clearReleased()
        
        let list = popViewHelperContainers.filter { container in
            guard let helper = container.popViewHelper else { return false }
            return type(of: helper.targetView as AnyObject) === targetType
        }
        
        return !list.isEmpty
    }
    
    func hideAll(for targetType: PoppingAbstractView.Type) {
        popViewHelperContainers.forEach { (container) in
            guard let helper = container.popViewHelper else { return }
            guard type(of: helper.targetView as AnyObject) === targetType, helper.canForceHide else { return }
            helper.hidePoppingView()
        }
        clearReleased()
    }
    
    func hideAll() {
        
        popViewHelperContainers.forEach { popViewHelperContainer in
            
            guard let popViewHelper = popViewHelperContainer.popViewHelper else { return }
            guard popViewHelper.canForceHide else { return }
            popViewHelper.hidePoppingView()
        }
        
        clearReleased()
    }
    
    func enQueue(_ popViewHelper: PopViewHelper) {
        
        if showingPoppingViewHelper == nil {
            popViewHelper.showPoppingView()
            showingPoppingViewHelper = popViewHelper
        } else {
            popViewHelper.isLockTargetView = true
        }
        
        popViewHelperQueue.append(popViewHelper)
    }
    
    func deQueue(_ popViewHelper: PopViewHelper) {
        
        if let index = popViewHelperQueue.firstIndex(where: { $0 == popViewHelper }) {
            popViewHelper.isLockTargetView = false
            popViewHelperQueue.remove(at: index)
            showingPoppingViewHelper = nil
            showInQueue()
        }
    }
    
    private func showInQueue() {
        
        showingPoppingViewHelper = popViewHelperQueue.max { (popViewHelper1, popViewHelper2) -> Bool in
            
            guard let priority1 = popViewHelper1.priority else { return false }
            guard let priority2 = popViewHelper2.priority else { return false }
            
            return priority1 < priority2
        }
        
        showingPoppingViewHelper?.showPoppingView()
        showingPoppingViewHelper?.hidePoppingViewDelayIfNeeded()
        
    }
    
    private func clearReleased() {
        
        for (index, element) in popViewHelperContainers.enumerated().reversed() where element.popViewHelper == nil {
            popViewHelperContainers.remove(at: index)
        }
    }
}

class PopViewHelperContainer {
    weak var popViewHelper: PopViewHelper?
    
    init(popViewHelper: PopViewHelper) {
        self.popViewHelper = popViewHelper
    }
}
