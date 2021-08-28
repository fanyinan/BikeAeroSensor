//
//  ChartDataItemCell.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/26.
//

import UIKit

class ChartDataItemCell: UICollectionViewCell, Reusable {
    
    private let containerView = ShadowCornerButton()
    private let titleLabel = UILabel()
    private let colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        containerView.isUserInteractionEnabled = false
        containerView.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        addSubview(containerView)
        containerView.setRadius(6)
        containerView.setShadow(color: #colorLiteral(red: 0.3843137255, green: 0.3843137255, blue: 0.3843137255, alpha: 0.5), offsetX: 2, offsetY: 2, radius: 2, opacity: 0.42)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(12)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 11)
        titleLabel.textAlignment = .center
        titleLabel.textColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        titleLabel.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
            make.left.equalTo(colorView.snp.right).offset(5)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(_ data: DataInfo) {
        titleLabel.text = data.label.rawValue
        colorView.backgroundColor = data.color
        if data.needShow {
            containerView.contentView.setBorder(color: data.color, width: 2)
        } else {
            containerView.contentView.setBorder(color: .clear, width: 0)
        }
    }
}
