//
//  Slider.swift
//  Vae
//
//  Created by fanyinan on 2019/5/10.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import UIKit

@objc protocol SliderDelegate: NSObjectProtocol {
    
    func valueChanged(_ slider: Slider, value: Int)
    @objc optional func touchDown(_ slider: Slider)
    @objc optional func touchUp(_ slider: Slider)
    @objc optional func displayText(value: Int) -> String
}

class Slider: UIView {
    
    private var progressView = UIView()
    private var indicatorMarkView = UIView()
    private var progressIndicatorView = UIView()
    private var tagLabel = UILabel()
    private var panBeginX: CGFloat = 0
    private var valueLabel = UILabel()
    private var initValue = 0
    
    private(set) var minValue = 0
    private(set) var maxValue = 1
    private(set) var isDragging = false
    private(set) var progress: Double = 0
    private(set) var value = 0
    private(set) var touchDownValue = 0
    
    weak var delegate: SliderDelegate?
    
    var label: String? {
        didSet {
            tagLabel.text = label
            tagLabel.isHidden = label == nil
        }
    }
    
    var labelWidth: CGFloat?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(minValue: Int, maxValue: Int, initValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        value = initValue
        let text = delegate?.displayText?(value: initValue) ?? "\(initValue)"
        valueLabel.text = text
        progress = VMathTool.percent(min: minValue, max: maxValue, value: initValue)
        setNeedsLayout()
    }
    
    func setValue(_ value: Int) {
        config(minValue: minValue, maxValue: maxValue, initValue: value)
    }
    
    func setProgress(_ progress: Double) {
        guard !isDragging else { return }
        let progress = VMathTool.clamp(value: progress, minValue: 0, maxValue: 1)
        indicatorMarkView.centerX = progressView.frame.width * CGFloat(progress)
        setNeedsLayout()
        updateValue(newProgress: progress)
        delegate?.touchUp?(self)
    }
    
    @objc private func onPan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            isDragging = true
            panBeginX = indicatorMarkView.centerX
            touchDownValue = value
            UIView.animate(withDuration: 0.1) {
                self.valueLabel.alpha = 1
            }
            delegate?.touchDown?(self)
        case .changed:
            let transition = gesture.translation(in: self)
            var panX = panBeginX + transition.x
            panX = min(max(progressView.minX, panX), progressView.maxX)
            indicatorMarkView.centerX = panX
            progressIndicatorView.width = indicatorMarkView.centerX - progressIndicatorView.minX
            valueLabel.centerX = indicatorMarkView.centerX
            let newProgress = VMathTool.percent(min: progressView.minX, max: progressView.maxX, value: panX)
            updateValue(newProgress: Double(newProgress))
        default:
            isDragging = false
            UIView.animate(withDuration: 0.1) {
                self.valueLabel.alpha = 0
            }
            delegate?.touchUp?(self)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isUserInteractionEnabled else { return false }
        
        let touchFrame = bounds.zoom(by: CGSize(width: 80, height: 20))
        if touchFrame.contains(point) {
            return true
        }
        
        return super.point(inside: point, with: event)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        guard isUserInteractionEnabled && alpha > 0 && !isHidden else { return nil }

        let touchFrame = bounds.zoom(by: CGSize(width: 80, height: 20))
        if touchFrame.contains(point) {
            return self
        }

        return super.hitTest(point, with: event)
    }
    
    private func updateValue(newProgress: Double) {
        
        let value = Int(round(VMathTool.mix(v1: Double(minValue), v2: Double(maxValue), t: newProgress)))
        self.value = value
        let text = delegate?.displayText?(value: value) ?? "\(value)"
        valueLabel.text = text
        if newProgress != progress {
            progress = newProgress
            delegate?.valueChanged(self, value: value)
        }
    }
    
    private func setupUI() {
        
        addSubview(tagLabel)
        tagLabel.font = UIFont.systemFont(ofSize: 12)
        tagLabel.textColor = #colorLiteral(red: 0.1999762356, green: 0.200016588, blue: 0.1999709308, alpha: 1)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)
        
        progressView.backgroundColor = #colorLiteral(red: 0, green: 0.5019607843, blue: 0.768627451, alpha: 1)
        addSubview(progressView)
        
        addSubview(progressIndicatorView)
        progressIndicatorView.backgroundColor = .theme
        progressIndicatorView.isUserInteractionEnabled = false

        addSubview(indicatorMarkView)
        indicatorMarkView.backgroundColor = .theme
        indicatorMarkView.isUserInteractionEnabled = false
        indicatorMarkView.setBorder(color: .white, width: 3)

        valueLabel.font = UIFont.boldSystemFont(ofSize: 12)
        valueLabel.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        valueLabel.textAlignment = .center
        valueLabel.alpha = 0
        addSubview(valueLabel)
        
    }
    
    private func layout() {
        
        if label == nil {
            tagLabel.frame = .zero
        } else {
            tagLabel.frame = CGRect(x: 0, y: 0, width: labelWidth ?? (tagLabel.sizeThatFits(size).width + 30), height: height)
        }
        
        progressView.minX = tagLabel.width == 0 ? 0 : tagLabel.maxX
        progressView.size = CGSize(width: frame.width - progressView.minX, height: 2)
        centerSubviewsVertical()
        
        indicatorMarkView.frame.size = CGSize(width: 10, height: 20)
        indicatorMarkView.center = CGPoint(x: CGFloat(progress) * progressView.width + progressView.minX, y: progressView.frame.midY)
        
        progressIndicatorView.frame = progressView.frame
        progressIndicatorView.width = indicatorMarkView.center.x - progressIndicatorView.minX
        
        valueLabel.frame.size = CGSize(width: 100, height: 20)
        valueLabel.maxY = indicatorMarkView.minY - 5
        valueLabel.centerX = indicatorMarkView.centerX
    }
}

extension Slider: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard label != nil else { return true }
        let location = touch.location(in: self)
        if location.x > tagLabel.maxX {
            return true
        }
        
        return false
    }
}
