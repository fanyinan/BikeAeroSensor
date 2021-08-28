//
//  SendCell.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/28.
//

import UIKit

class SendCell: GridCell {
    
    private let containerView = ShadowCornerButton()
    private let titleLabel = UILabel()
    
    private var sendContent: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        addSubview(containerView)
        containerView.addTarget(self, action: #selector(onSend), for: .touchUpInside)
        containerView.setRadius(6)
        containerView.setShadow(color: .black, offsetX: 0, offsetY: 2, radius: 4, opacity: 0.1)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.backgroundColor = .white
        containerView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .text
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(title: String, sendContent: String) {
        titleLabel.text = title
        self.sendContent = sendContent
    }
    
    @objc private func onSend() {
        guard let data = sendContent?.data(using: .utf8) else { return }
        let success = UDPManager.default.send(data)
        if !success {
            Toast.showRightNow("发送失败，ip或端口号为空")
        }
    }
}
