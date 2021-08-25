//
//  MenuView.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/24.
//

import UIKit

enum MenuActionType {
    case setting, file, function, tareOn, tareOff
}

class MenuView: UIView, NibLoadable {

    @IBOutlet weak var batteryPercentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var batteryPercentLabel: UILabel!
    @IBOutlet var wiFiSignalStrengthView: [UIView]!
    
    private var batteryPercent: Double = 0
    private var wifi = 0
    private var isTare = false
    
    private let batteryMin = 3.6
    private let batteryMax = 4.2
    private var timer: Timer?
    
    var onClickBlock: ((MenuActionType) -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        wiFiSignalStrengthView.forEach({ $0.backgroundColor = .theme })
    }
    
    func update(battery: Double, wifi: Int) {
        batteryPercent = VMathTool.percent(min: batteryMin, max: batteryMax, value: battery)
        batteryPercent = VMathTool.clamp(value: batteryPercent, minValue: 0, maxValue: 1)
        self.wifi = wifi
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(refreshUI), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func end() {
        timer?.invalidate()
    }
    
    @objc private func refreshUI() {
        print("batteryPercent", batteryPercent)
        batteryPercentViewWidthConstraint?.constant = CGFloat(batteryPercent * 22)
        batteryPercentLabel?.text = "\(Int((batteryPercent * 100).rounded()))%"
        
        let curWifiCount = wifi / 20
        for (i, view) in wiFiSignalStrengthView.enumerated() {
            if i <= curWifiCount {
                view.alpha = 1
            } else {
                view.alpha = 0.2
            }
        }
        
    }
    
    @IBAction func onSetting(_ sender: Any) {
        onClickBlock?(.setting)
    }
    
    @IBAction func onFile(_ sender: Any) {
        onClickBlock?(.file)
    }
    
    @IBAction func onFunction(_ sender: Any) {
        onClickBlock?(.function)
    }
    
    @IBAction func onTare(_ sender: UIButton) {
        isTare = !isTare
        if isTare {
            sender.tintColor = .theme
            onClickBlock?(.tareOn)
        } else {
            sender.tintColor = .black
            onClickBlock?(.tareOff)
        }
    }
}
