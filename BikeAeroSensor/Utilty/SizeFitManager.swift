//
//  SizeFitManager.swift
//  Vae
//
//  Created by fanyinan on 2018/9/10.
//  Copyright © 2018 fanyinan. All rights reserved.
//

import UIKit

func kFitWid(_ wid: CGFloat) -> CGFloat {
    return SizeFitManager.shared.screenWidthRatio * wid
}

func kFitHei(_ hei: CGFloat) -> CGFloat {
    return SizeFitManager.shared.screenHeightRatio * hei
}

func kFitMid(_ size: CGFloat) -> CGFloat {
    return SizeFitManager.shared.screenWHMinRatio * size
}

class SizeFitManager {
    
    static let shared = SizeFitManager()
    
    private var screenRatio: CGFloat
    private(set) var screenWidthRatio: CGFloat
    private(set) var screenHeightRatio: CGFloat
    private(set) var screenWHMinRatio: CGFloat
    private(set) var screenWHMaxRatio: CGFloat
    
    private let baseSize = CGSize(width: 375, height: 667)
    
    private(set) var screenSize: CGSize
    private(set) var safeTopMargin: CGFloat = 0
    private(set) var safeBottomMargin: CGFloat = 0
    
    var screenWidth: CGFloat { return screenSize.width }
    var screenHeight: CGFloat { return screenSize.height }
    
    private init() {
        
        screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        screenRatio = min(screenWidth / screenHeight, screenHeight / screenWidth)
        
        safeTopMargin = UIApplication.shared.keyWindow!.safeAreaInsets.top
        safeBottomMargin = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        
        if screenHeight > screenWidth {
            screenWidthRatio = screenWidth / baseSize.width
            screenHeightRatio = (screenHeight - safeTopMargin - safeBottomMargin) / baseSize.height
        } else {
            screenWidthRatio = (screenHeight - safeTopMargin - safeBottomMargin) / baseSize.height
            screenHeightRatio = screenWidth / baseSize.width
        }
        
        screenWHMinRatio = min(screenWidthRatio, screenHeightRatio)
        screenWHMaxRatio = max(screenWidthRatio, screenHeightRatio)
    }
}
