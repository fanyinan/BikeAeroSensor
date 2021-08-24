//
//  DynamicDataCell.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/24.
//

import UIKit

class DynamicData {
    
}

class DynamicDataCell: GridCell {
    
    private let containerView = ShadowCornerButton()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        addSubview(containerView)
        containerView.setRadius(6)
        containerView.setShadow(color: .black, offsetX: 0, offsetY: 2, radius: 2, opacity: 0.08)
        
        containerView.addSubview(titleLabel)
        containerView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
        containerView.centerInSuperview()
        titleLabel.size = CGSize(width: containerView.width, height: 16)
        titleLabel.bottomMargin = 9
    }
    
    func setData(_ data: DynamicData) {
        
    }
}
