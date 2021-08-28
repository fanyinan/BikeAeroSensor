//
//  String+Extension.swift
//  Vae
//
//  Created by 范祎楠 on 2019/5/18.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

extension String {
    
    func calculateHeight(withWidth width: CGFloat, fontSize: CGFloat) -> CGFloat {
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil)
        
        return rect.size.height
    }
}
