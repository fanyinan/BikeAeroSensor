//
//  AlertView.swift
//  Vae
//
//  Created by 范祎楠 on 2017/3/2.
//  Copyright © 2017年 Juxin. All rights reserved.
//

import UIKit

enum AlertViewType {
    
    case normal
    case input //显示一个输入框
    
}

class AlertView: PoppingAbstractView {
    
    private var title: String?
    private var message: String?
    private var markButtonTitle: String?
    private var normalButtonTitles: [String]
    private var currentFrame: CGRect!
    private var titleLabel: UILabel!
    private var buttonContainerView: UIView!
    private var buttonTitles: [String] = []
    private var markButtonIndex: Int?
    private var buttonWidth: CGFloat!
    
    private(set) var customView: UIView!
    private(set) var textField: UITextField?

    private let titleTopMargin: CGFloat = 17
    private let titleBottomMargin: CGFloat = 17
    private let textLabelHMargin: CGFloat = 17
    
    private let contentTopMargin: CGFloat = 17
    private let contentBottomMargin: CGFloat = 17
    
    private var titleHeight: CGFloat = 20
    private let buttonHeight: CGFloat = 50
    private let vSpace: CGFloat = 1
    private let buttonSpace: CGFloat = 1
    private let textFieldHeight: CGFloat = 35
    private let margin: CGFloat = 50
    
    private var succeedHandle: (() -> Void)?
    private var resultHandle: ((Int) -> Void)?
    
    var alertViewType: AlertViewType = .normal {
        didSet {
            customView = nil
            setupUI()
        }
    }
    
    var autoClose: Bool = true
    
    init(title: String?, message: String, markButtonTitle: String?, otherButtonTitles: String?) {
        
        self.title = title
        self.message = message
        self.markButtonTitle = markButtonTitle
        self.normalButtonTitles = [otherButtonTitles].compactMap({ $0 })
        
        super.init(size: CGSize.zero, viewPopDirection: .fade, maskStatus: .clickDisable)
        
        frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.size.width - margin * 2, height: 0))
        self.customView = createCustomView()
        
        popViewHelper.adjustWithKeyboard = true
        
        setupUI()
        
    }
    
    init(title: String?, customView: UIView, markButtonTitle: String?, otherButtonTitles: String?) {
        
        self.title = title
        self.customView = customView
        self.markButtonTitle = markButtonTitle
        self.normalButtonTitles = [otherButtonTitles].compactMap({ $0 })
        
        super.init(size: CGSize.zero, viewPopDirection: .fade, maskStatus: .clickDisable)
        
        frame.size.width = customView.frame.width
        
        popViewHelper.adjustWithKeyboard = true
        
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    override func show() -> Self {
        super.show()
        textField?.becomeFirstResponder()
        return self
    }
    
    override func hide() {
        succeedHandle = nil
        resultHandle = nil
        super.hide()
    }
    
    func onSucceed(_ succeedHandle: @escaping () -> Void) {
        self.succeedHandle = succeedHandle
    }
    
    func onResult(_ resultHandle: @escaping (Int) -> Void) {
        self.resultHandle = resultHandle
    }
    
    private func setupUI() {
        
        subviews.forEach({$0.removeFromSuperview()})
        
        setCornerRadius(8)
        backgroundColor = .alertBackground
        
        initTitle()
        
        initContentView()
        
        initButtons()
        
        frame.size.height = buttonContainerView.frame.maxY
        
    }
    
    private func initTitle() {
        
        let isHaveTitle = title != nil && !title!.isEmpty
        
        let tileLabelY = isHaveTitle ? titleTopMargin : 0
        let tileLabelHeight = isHaveTitle ? titleHeight : 0
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: tileLabelY, width: frame.width, height: tileLabelHeight))
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        addSubview(titleLabel)
        titleLabel.isHidden = !isHaveTitle
        
        guard isHaveTitle else {
            titleHeight = 0
            return
        }
        
        titleHeight += titleTopMargin
        
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .text
        titleLabel.textAlignment = .center
        titleLabel.text = title
    }
    
    private func initContentView() {
        
        if customView == nil {
            customView = createCustomView()
        }
        
        customView.frame.origin = CGPoint(x: 0, y: titleHeight)
        addSubview(customView)
        
    }
    
    //当是message是，自己造一个customview
    private func createCustomView() -> UIView {
        
        let customView = UIView()
        customView.frame.size.width = frame.width
        
        let labelWidth = frame.width - textLabelHMargin * 2
        let labelHeight = message!.calculateHeight(withWidth: labelWidth, fontSize: 15)
        let label = UILabel(frame: CGRect(x: textLabelHMargin, y: contentTopMargin, width: labelWidth, height: labelHeight))
        customView.addSubview(label)
        
        label.text = message
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .subtext
        label.textAlignment = .center
        label.numberOfLines = 0
        
        customView.frame.size.height = labelHeight + contentTopMargin + contentBottomMargin
        
        if alertViewType == .input {
            
            textField = UITextField(frame: CGRect(x: textLabelHMargin, y: label.frame.maxY + contentTopMargin, width: frame.width - textLabelHMargin * 2, height: textFieldHeight))
            
            textField!.setBorder(color: .norm, width: 1)
            textField!.setCornerRadius(2)
            textField!.font = UIFont.systemFont(ofSize: 16)
            textField!.leftViewMode = .always
            textField!.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            textField!.textColor = .text
            customView.addSubview(textField!)
            
            customView.frame.size.height = customView.frame.height + textFieldHeight + contentTopMargin
            
        }
        
        return customView
    }
    
    private func initButtons() {
        
        buttonContainerView = UIView(frame: CGRect(x: 0, y: customView.frame.maxY, width: frame.width, height: buttonHeight + vSpace))
        addSubview(buttonContainerView)
        
        buttonContainerView.backgroundColor = .separator
        
        configButtonTitles()
        
        for (index, title) in buttonTitles.enumerated() {
            
            let button = UIButton(frame: CGRect(x: CGFloat(index) * (buttonWidth + buttonSpace), y: vSpace, width: buttonWidth, height: buttonContainerView.frame.height))
            buttonContainerView.addSubview(button)
            button.setTitle(title, for: .normal)
            button.setTitleColor(index == markButtonIndex ? .theme : #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), for: .normal)
            button.setTitleColor(.orange, for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.backgroundColor = .alertBackground
            button.tag = index
            button.addTarget(self, action: #selector(AlertView.onClickButton(_:)), for: .touchUpInside)
        }
    }
    
    private func configButtonTitles() {
        
        buttonTitles.removeAll()
        
        for title in normalButtonTitles {
            
            buttonTitles.append(title)
        }
        
        if let markButtonTitle = markButtonTitle {
            
            buttonTitles.append(markButtonTitle)
            markButtonIndex = buttonTitles.count - 1
        }
        
        buttonWidth = (frame.width - ((CGFloat(buttonTitles.count)) - 1) * buttonSpace) / CGFloat(buttonTitles.count)
        
    }
    
    @objc private func onClickButton(_ sender: UIButton) {
        
        if sender.tag == markButtonIndex {
            if alertViewType == .input && (textField!.text == nil || textField!.text!.isEmpty ){
                Toast.showRightNow("内容不得为空")
                return
            } else {
                succeedHandle?()
            }
        }
        
        resultHandle?(sender.tag)
        
        if autoClose {
            
            hide()
            
        }
        
        if alertViewType == .input {
            
            textField?.resignFirstResponder()
        }
    }
}
