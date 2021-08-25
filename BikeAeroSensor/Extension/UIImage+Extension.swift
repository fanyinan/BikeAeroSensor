//
//  UIImage+Extension.swift
//  Vae
//
//  Created by fyn on 2019/7/31.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

extension UIImage {
    
    func tintColor(_ color: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        color.setFill()
        let bounds = CGRect(origin: .zero, size: size)
        ctx.fill(bounds)
        draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    func scale(boxSize: CGSize, isFill: Bool) -> UIImage? {
        let targetSize = isFill ? size.fill(boxSize: boxSize) : size.fit(boxSize: boxSize)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        draw(in: CGRect(origin: .zero, size: targetSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
