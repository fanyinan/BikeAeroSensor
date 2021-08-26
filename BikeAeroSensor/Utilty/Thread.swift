//
//  Thread.swift
//  Vae
//
//  Created by fanyinan on 2019/5/17.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import Foundation

func delayTask(_ time: TimeInterval, delayBlock: @escaping () -> Void) {
    
    let delay = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delay) {
        delayBlock()
    }
}

func exchangeMainThread(_ block: @escaping () -> Void) {
    guard !Thread.isMainThread else {
        block()
        return
    }
    
    DispatchQueue.main.async {
        block()
    }
}
