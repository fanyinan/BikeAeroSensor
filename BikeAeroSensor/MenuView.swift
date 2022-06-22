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
    @IBOutlet weak var batteryIconView: UIView!
    @IBOutlet weak var tareImageView: UIImageView!
    @IBOutlet var wiFiSignalStrengthView: [UIView]!
    @IBOutlet weak var recordIconView: UIView!
    @IBOutlet weak var recLabel: UILabel!
    @IBOutlet weak var recordStatusView: UIView!
    @IBOutlet weak var recTimeLabel: UILabel!

    let functionView = FunctionMenuItem()

    private var batteryPercent: Double = 0
    private var wifi = 0
    private var recordStatus: RecordStatus = .end
    private var timer: Timer?
    private var currentTime = 0
    private var tareTintImage: UIImage?
    private var tareOriginImage: UIImage?

    private let batteryMin = 3.6
    private let batteryMax = 4.2
    
    var menuItemHeight: CGFloat = 0
    
    var safeBottom: CGFloat {
        return SizeFitManager.shared.screenHeight - convert(CGPoint(x: 0, y: height), to: nil).y
    }
    
    var onClickBlock: ((MenuActionType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wiFiSignalStrengthView.forEach({ $0.backgroundColor = .theme })
        tareTintImage = tareImageView.image?.tintColor(.theme)
        tareOriginImage = tareImageView.image
        recTimeLabel.textColor = .theme
        recordStatusView.backgroundColor = .theme
        batteryIconView.backgroundColor = .theme
        
        functionView.menuView = self
        functionView.onHide = { [weak self] velocity in
            guard let self = self else { return }
            self.hideCurrentMenuItem(velocity: velocity)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if functionView.status == .normal {
            return functionView.frame.contains(point)
        }
        
        return super.point(inside: point, with: event)
    }
    
    func set(battery: Double) {
        batteryPercent = VMathTool.clamp(value: battery, minValue: 0, maxValue: 1)
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
//        onClickBlock?(.function)
        showMeneItemView(functionView, delay: 0.1, duration: 0.35)
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
            endCountDown()
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
    
    private func endCountDown() {
        recordStatusView.alpha = 1
        recTimeLabel.alpha = 0
        recordStatusView.backgroundColor = .theme
        recordStatusView.layer.removeAllAnimations()
        recordIconView.setBorder(color: .black, width: 2)
        recLabel.textColor = .black
        recordStatus = .end
        onClickBlock?(.endRecord)
        
    }
    @objc private func onCountDown() {
        if currentTime < 0 {
            timer?.invalidate()
            recordStatus = .recording
            recordStatusView.backgroundColor = .red
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
    }
    
    private func showMeneItemView(_ menuItemView: MenuItemView, delay: TimeInterval, duration: Double) {
        func pop() {
            menuItemView.willPresent()
            
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = 0
            animation.toValue = 0.12
            animation.beginTime = CACurrentMediaTime() + delay
            animation.duration = duration
            menuItemView.layer.add(animation, forKey: nil)
            
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                menuItemView.maxY = self.height + self.safeBottom
                menuItemView.alpha = 1
            }, completion: { _ in
//                self.navigationView.popByPan = false
                menuItemView.present()
            })
        }
        
        menuItemView.minY = height
        menuItemView.alpha = 0
//        let menuItemViewHeight = delegate.menuView(self, willShowMenuItemWith: label, menuItemView: menuItemView, node: node)
        let menuItemViewHeight: CGFloat = menuItemHeight
        menuItemView.initSize(CGSize(width: width, height: menuItemViewHeight), bottomUnavailableHeight: safeBottom)
        addSubview(menuItemView)
        
        //使menuItemView完全加载完再弹出，为了音频和特效菜单的轴能够设置正确的contentOffset
        delayTask(0.01) {
            pop()
        }
    }
    
    func hideCurrentMenuItem(velocity: CGFloat? = nil, isResetLabel: Bool = true, completion: (() -> Void)? = nil) {
        hideMenuItemView(functionView, velocity: velocity) {
            completion?()
        }
    }
    
    private func hideMenuItemView(_ menuItemView: MenuItemView, velocity: CGFloat? = nil, completion: (() -> Void)? = nil) {
        menuItemView.willDismiss()
        
        var duration = 0.2
        
        if let velocity = velocity {
            duration = min(duration, TimeInterval((height - menuItemView.minY) / velocity))
        }
        
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.toValue = 0
        animation.beginTime = CACurrentMediaTime()
        animation.duration = duration
        menuItemView.layer.add(animation, forKey: nil)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            menuItemView.minY = self.height
            menuItemView.alpha = 0
        }, completion: { _ in
            menuItemView.removeFromSuperview()
            menuItemView.didDismiss()
            completion?()
        })
    }
}
