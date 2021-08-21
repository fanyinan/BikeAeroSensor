//
//  ProbeFileCell.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import UIKit

class ProbeFileCell: UITableViewCell, Reusable {

    private let fileNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(fileNameLabel)
        fileNameLabel.font = UIFont.systemFont(ofSize: 14)
        fileNameLabel.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fileNameLabel.frame = CGRect(x: 30, y: 0, width: width - 30, height: height)
    }
    
    func setData(_ fileInfo: ProbeFileInfo) {
        fileNameLabel.text = fileInfo.fileURL.lastPathComponent
    }
}
