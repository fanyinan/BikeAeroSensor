//
//  UIColor.swift
//  Vae
//
//  Created by fanyinan on 2018/9/11.
//  Copyright © 2018 fanyinan. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var theme = #colorLiteral(red: 0.003921568627, green: 0.5450980392, blue: 0.8352941176, alpha: 1)
    static let subTheme = #colorLiteral(red: 0.6, green: 0.5254901961, blue: 0.7215686275, alpha: 1)
    static let norm = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
    static let separator = #colorLiteral(red: 0.7744626999, green: 0.7745938301, blue: 0.7744454145, alpha: 1)
    static let text = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    static let subtext = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
    static let button = #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
    static let mainBackground = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let editBackground = #colorLiteral(red: 0.1294117647, green: 0.1333333333, blue: 0.1411764706, alpha: 1)
    static let alertBackground = #colorLiteral(red: 0.8665809631, green: 0.8667267561, blue: 0.8665617108, alpha: 1)
    static let deselect = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    static let menuBackground = #colorLiteral(red: 0.9646111131, green: 0.964772284, blue: 0.9645897746, alpha: 1)

    convenience init(hex: UInt, alpha: CGFloat = 1) {
        
        let (red, green, blue) = UIColor.convertHexToRGB(hex: hex, hasAlpha: false)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(hexStr: String) {
        
        let rgbString = hexStr.hasPrefix("#") ? String(hexStr[hexStr.index(hexStr.startIndex, offsetBy: 1)..<hexStr.endIndex]) : hexStr
        let scaner = Scanner(string: rgbString)
        var rgb: UInt32 = 0
        scaner.scanHexInt32(&rgb)
        
        self.init(hex: UInt(rgb), alpha: 1)
    }
    
    class func convertHexToRGB(hex: UInt, hasAlpha: Bool) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        
        if hasAlpha {
            
            let red = CGFloat((hex & 0xFF000000) >> 24) / 255.0
            let green = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            let blue = CGFloat((hex & 0xFF00) >> 8) / 255.0
            let alpha = CGFloat((hex & 0xFF)) / 255.0
            
            return (red * alpha, green * alpha, blue * alpha)
            
        } else {
            let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat((hex & 0x0000FF)) / 255.0
            
            return (red, green, blue)
        }
    }
    
    class var random: UIColor {
        let hue = CGFloat(arc4random() % 256) / 256.0
        let saturation = CGFloat(arc4random() % 128) / 256.0 + 0.5
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256.0 + 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    static func ==(lhs: UIColor, rhs: UIColor) -> Bool {
        let lhsComponents = lhs.cgColor.components
        let rhsComponents = rhs.cgColor.components

        switch (lhsComponents, rhsComponents) {
        case (.some(_), .none) :
            return false
        case (.none, .some(_)):
            return false
        case (.none, .none):
            return true
        case (.some(let lvalue), .some(let rvalue)):
            var lvalue = lvalue
            var rvalue = rvalue
            if lvalue.count == 2 {
                lvalue = [lvalue[0], lvalue[0], lvalue[0], lvalue[1]]
            }
            if rvalue.count == 2 {
                rvalue = [rvalue[0], rvalue[0], rvalue[0], rvalue[1]]
            }
            return lvalue == rvalue
        }
    }
}


struct Color: Codable {

    var uiColor: UIColor
    
    enum CodingKeys: CodingKey {
        case red, blue, green, alpha
    }
    
    init(_ uiColor: UIColor) {
        self.uiColor = uiColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(CGFloat.self, forKey: .red)
        let green = try container.decode(CGFloat.self, forKey: .green)
        let blue = try container.decode(CGFloat.self, forKey: .blue)
        let alpha = try container.decode(CGFloat.self, forKey: .alpha)
        uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }
}

