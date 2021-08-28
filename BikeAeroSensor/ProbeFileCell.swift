//
//  ProbeFileCell.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import UIKit
import SnapKit

class ProbeFileCell: UITableViewCell, Reusable {

    private let fileNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(fileNameLabel)
        fileNameLabel.font = UIFont.systemFont(ofSize: 18)
        fileNameLabel.textColor = #colorLiteral(red: 0.2338292599, green: 0.2324454784, blue: 0.2348968685, alpha: 1)
        fileNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = #colorLiteral(red: 0.3578231931, green: 0.3557013571, blue: 0.3594576716, alpha: 1)
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(fileNameLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-30)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setData(_ fileInfo: ProbeFileInfo) {
        fileNameLabel.text = fileInfo.displayName
        descriptionLabel.text = fileInfo.desc
    }
}
