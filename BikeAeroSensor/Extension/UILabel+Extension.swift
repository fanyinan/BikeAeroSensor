//
//  UILabel+Extension.swift
//  Vae
//
//  Created by fanyinan on 2019/6/28.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

extension UILabel {
    
    func config(fontSize: CGFloat, textColor: UIColor, textAlignment: NSTextAlignment) {
        
        self.font = UIFont.systemFont(ofSize: fontSize)
        self.textColor = textColor
        self.textAlignment = textAlignment
    }
}
