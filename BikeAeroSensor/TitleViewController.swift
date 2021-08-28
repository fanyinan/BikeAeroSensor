//
//  TitleViewController.swift
//  Vae
//
//  Created by 范祎楠 on 2019/8/10.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {

    private let titleLabel = UILabel()
//    let blurView = BlurView(radius: 12, color: .editBackground, alpha: 0.8)
    let titleView = UIView()
    let closeButton = UIButton()

    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .editBackground
        
        view.addSubview(titleView)
        titleView.setShadow(color: .text, offset: CGSize(width: 0, height: 0.6), radius: 1, opacity: 0.05)
        titleView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            if UIScreen.main.bounds.size.height <= 667 {
                make.height.equalTo(80 + SizeFitManager.shared.safeTopMargin)
            } else {
                make.height.equalTo(100 + SizeFitManager.shared.safeTopMargin)
            }
        }
        
//        titleView.addSubview(blurView)
//        blurView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        titleLabel.config(fontSize: 30, textColor: .text, textAlignment: .left)
        titleLabel.text = "编辑"
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ make in
            make.left.equalToSuperview().offset(kFitWid(30))
            make.bottom.equalToSuperview().offset(-kFitHei(16))
        })
        
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        titleView.addSubview(closeButton)
        closeButton.snp.makeConstraints({ make in
            make.right.equalToSuperview().offset(-kFitWid(16))
            make.bottom.equalToSuperview().offset(-kFitHei(16))
            make.height.width.equalTo(kFitMid(30))
        })
    }
    
    @objc func onClose() {
        dismiss(animated: true, completion: nil)
    }
}
