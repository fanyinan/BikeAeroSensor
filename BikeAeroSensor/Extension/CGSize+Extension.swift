//
//  CGSize+Extension.swift
//  Vae
//
//  Created by fanyinan on 2019/3/26.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

extension CGSize {
    
    init(length: CGFloat) {
        self.init(width: length, height: length)
    }
    
    static func *(size: CGSize, multiplicand: CGFloat) -> CGSize {
        return CGSize(width: size.width * multiplicand, height: size.height * multiplicand)
    }
    
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    func fit(boxSize: CGSize) -> CGSize {
        
        let widthScale = boxSize.width / width
        let heightScale = boxSize.height / height
        let scale = min(widthScale, heightScale)
        return self * scale
    }
    
    func fill(boxSize: CGSize) -> CGSize {
        
        let widthScale = boxSize.width / width
        let heightScale = boxSize.height / height
        let scale = max(widthScale, heightScale)
        return self * scale
    }
}
