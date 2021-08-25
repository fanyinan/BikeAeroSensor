//
//  MenuView.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/24.
//

import UIKit

enum MenuActionType {
    case setting, file, function, tareOn, tareOff, startRecord, endRecord
}

enum RecordStatus {
    case end, prepare, recording
}

class MenuView: UIView, NibLoadable {

    @IBOutlet weak var batteryPercentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var batteryPercentLabel: UILabel!
    @IBOutlet weak var tareImageView: UIImageView!
    @IBOutlet var wiFiSignalStrengthView: [UIView]!
    @IBOutlet weak var recordIconView: UIView!
    @IBOutlet weak var recLabel: UILabel!
    @IBOutlet weak var recordStatusView: UIView!
    @IBOutlet weak var recTimeLabel: UILabel!

    private var batteryPercent: Double = 0
    private var wifi = 0
    private var recordStatus: RecordStatus = .end
    private var timer: Timer?
    private var currentTime = 0
    private var tareTintImage: UIImage?
    private var tareOriginImage: UIImage?

    private let batteryMin = 3.6
    private let batteryMax = 4.2
    
    
    var onClickBlock: ((MenuActionType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wiFiSignalStrengthView.forEach({ $0.backgroundColor = .theme })
        tareTintImage = tareImageView.image?.tintColor(.theme)
        tareOriginImage = tareImageView.image
        recTimeLabel.textColor = .theme
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
    
    @IBAction func onTare(_ button: UIControl) {
        button.isSelected = !button.isSelected
        tareImageView.image = button.isSelected ? tareTintImage : tareOriginImage
        onClickBlock?(button.isSelected ? .tareOn : .tareOff)
    }
    
    @IBAction func onRecord(_ sender: Any) {
        switch recordStatus {
        case .end:
            beginCountDown()
        case .prepare:
            break
        case .recording:
            recordStatusView.alpha = 1
            recTimeLabel.alpha = 0
            recordStatusView.backgroundColor = .red
            recordStatusView.layer.removeAllAnimations()
            recordIconView.setBorder(color: .black, width: 2)
            recLabel.textColor = .black
            recordStatus = .end
            onClickBlock?(.endRecord)
        }
    }
    
    private func beginCountDown() {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.recordStatusView.alpha = 0
        })
        
        recTimeLabel.alpha = 0
        currentTime = 3
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onCountDown), userInfo: nil, repeats: true)
        timer?.fire()
        recordStatus = .prepare
        recordIconView.setBorder(color: .theme, width: 2)
        recLabel.textColor = .theme
    }
    
    @objc private func onCountDown() {
        if currentTime < 0 {
            timer?.invalidate()
            recordStatus = .recording
            recordStatusView.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 0.3719732761, alpha: 1)
            beginBlink()
            onClickBlock?(.startRecord)
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.recTimeLabel.alpha = 0
        } completion: { _ in
            self.recTimeLabel.text = "\(self.currentTime)"
            self.currentTime -= 1
            UIView.animate(withDuration: 0.3, animations: {
                self.recTimeLabel.alpha = 1
            })
        }
    }
    
    private func beginBlink() {
        UIView.animate(withDuration: 0.2, animations: {
            self.recTimeLabel.alpha = 0
        })
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0
        animation.toValue = 1
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.duration = 0.5
        animation.autoreverses = true
        recordStatusView.layer.add(animation, forKey: nil)
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onBlink), userInfo: nil, repeats: true)
    }
    
//    @objc private func onBlink() {
//
//    }
}
