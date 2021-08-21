//
//  Toast.swift
//  Vae
//
//  Created by fyn on 2019/7/17.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import Foundation

extension Toast {
    
    static func showRightNow(_ text: String) {
        ToastCenter.default.cancelAll()
        let toast = Toast(text: text)
        toast.view.setShadow(color: .black, offset: .zero, radius: 4, opacity: 0.2)
        toast.show()
    }
}
