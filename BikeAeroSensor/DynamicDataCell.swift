//
//  DynamicDataCell.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/24.
//

import UIKit
import SnapKit

struct DynamicData {
    var name: String
    var value: Double
    var unit: String
}

class DynamicDataCell: GridCell {
    
    private let containerView = ShadowCornerButton()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let unitLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        addSubview(containerView)
        containerView.setRadius(6)
        containerView.setShadow(color: .black, offsetX: 0, offsetY: 2, radius: 2, opacity: 0.08)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.backgroundColor = .white
        containerView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 11)
        titleLabel.textAlignment = .center
        titleLabel.textColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-9)
            make.width.equalToSuperview()
            make.height.equalTo(16)
            make.centerX.equalToSuperview()
        }
        
        containerView.addSubview(valueLabel)
        valueLabel.font = UIFont.systemFont(ofSize: 20)
        valueLabel.textAlignment = .right
        valueLabel.textColor = .theme
//        valueLabel.backgroundColor = .red
        valueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.right.equalTo(containerView.snp.centerX).offset(10)
        }
        
        containerView.addSubview(unitLabel)
        unitLabel.font = UIFont.systemFont(ofSize: 10)
        unitLabel.textAlignment = .left
        unitLabel.textColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
//        unitLabel.backgroundColor = .blue
        unitLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(valueLabel.snp.bottom).offset(-3)
            make.left.equalTo(valueLabel.snp.right).offset(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setData(_ data: DynamicData?) {
        
        guard let data = data else {
            titleLabel.isHidden = true
            valueLabel.isHidden = true
            unitLabel.isHidden = true
            return
        }
        titleLabel.isHidden = false
        valueLabel.isHidden = false
        unitLabel.isHidden = false
        titleLabel.text = data.name
        valueLabel.text = String(format: "%.1f", data.value)
        unitLabel.text = data.unit
    }
}
