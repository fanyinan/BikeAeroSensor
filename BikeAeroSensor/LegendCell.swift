//
//  LegendCell.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/24.
//

import UIKit
import SnapKit

class LegendCell: GridCell {
    
    private let colorView = ShadowCornerButton()
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(colorView)
        colorView.setRadius(1, lineWidth: 2, lineColor: .white)
        colorView.setShadow(color: #colorLiteral(red: 0.3529411765, green: 0.3529411765, blue: 0.3529411765, alpha: 1), offset: CGSize(width: 1, height: 2), radius: 2, opacity: 0.2)
        
        colorView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(colorView.snp.height)
            make.top.left.equalToSuperview()
        }
        
        addSubview(label)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(colorView.snp.right).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        colorView.frame = CGRect(x: 0, y: 0, width: height, height: height)
//        label.frame = CGRect(x: colorView.maxX + 5, y: 0, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
    }
    
    func setData(_ data: VisualInfo?) {
        
        guard let data = data else {
            colorView.isHidden = true
            label.isHidden = true
            return
        }
        colorView.isHidden = false
        label.isHidden = false
        colorView.backgroundColor = data.color
        label.text = data.label
    }
}
