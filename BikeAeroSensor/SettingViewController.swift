//
//  SettingViewController.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var myIPLabel: UILabel!
    @IBOutlet weak var portTextField: UITextField!
    
    @IBOutlet weak var sendPortTextField: UITextField!
    @IBOutlet weak var sendHostTextField: UITextField!

    @IBOutlet weak var sendTextField: UITextField!
//    @IBOutlet weak var receiveTextView: UITextView!
    @IBOutlet weak var candidateColorView: UIView!
    @IBOutlet weak var colorField: UITextField!

    private var isSimulateOpen = false
    private var currentDataIndex = 0
    
    private let sendView = GridView(cellType: SendCell.self)
    private let sendInfos: [(String, String)] = [("重启", "R"), ("加速器校准", "A"), ("磁力计校准", "M"),]
    private let candidateColors: [UInt] = [0x018BD5, 0xCE0755, 0x77C344, 0xF8AF17, 0xECFF00, 0x1EFF00, 0x00FFC3, 0x7F00FF, 0xFF00F5]
    private var colorButtons: [UIButton] = []
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: RunLoop.main, forMode: .default)
        displayLink.isPaused = true
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 30
        } else {
            // Fallback on earlier versions
        }
        return displayLink
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let port = UDPManager.default.port
        portTextField.text = port.flatMap({ "\($0)" }) ?? ""
        
        let sendHost = UDPManager.default.sendHost
        sendHostTextField.text = sendHost ?? ""
        
        let sendPort = UDPManager.default.sendPort
        sendPortTextField.text = sendPort.flatMap({ "\($0)" }) ?? ""
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickEmpty(_:)))
        view.addGestureRecognizer(tap)
        let ips = getWiFiAddress() ?? "unknow"
        myIPLabel.text = ips
        UDPManager.default.addListener(self)
        
        
        sendView.row = 1
        sendView.col = 3
        sendView.edgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sendView.collectionView.clipsToBounds = false
        sendView.hSpace = 20
        view.addSubview(sendView)
        sendView.updateCell = { [unowned self] cell, index in
            cell.setData(title: self.sendInfos[index].0, sendContent: self.sendInfos[index].1)
        }
        
        for (i, color) in candidateColors.enumerated() {
            let colorView = UIButton()
            colorView.addTarget(self, action: #selector(onSelectColor(_:)), for: .touchUpInside)
            colorView.tag = i
            colorView.backgroundColor = UIColor(hex: color)
            candidateColorView.addSubview(colorView)
            colorButtons.append(colorView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendView.size = CGSize(width: view.width, height: 40)
        sendView.bottomMargin = view.safeAreaInsets.bottom + 50
        for (i, button) in colorButtons.enumerated() {
            button.frame = CGRect(x: (candidateColorView.height + 6) * CGFloat(i), y: 0, width: candidateColorView.height, height: candidateColorView.height)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendView.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink.invalidate()
    }

    @IBAction func onBind(_ sender: Any) {
        
        guard let port = UInt16(portTextField.text!) else {
            Toast.showRightNow("创建socket失败：我的端口号错误")
            return
        }
        
        UDPManager.default.bind(port)
    }
    
    @IBAction func sendData(_ sender: Any) {
        print(#function)
        guard let text = sendTextField.text, !text.isEmpty, let data = text.data(using: .utf8) else {
            appendText("发送数据失败：内容不得未空")
            return
        }
        
        guard let host = sendHostTextField.text, !host.isEmpty else {
            appendText("发送数据失败：host不得为空")
            return
        }
        
        guard let portStr = sendPortTextField.text, !portStr.isEmpty else {
            appendText("发送数据失败：port不得为空")
            return
        }
        
        guard let port = UInt16(portStr) else {
            appendText("发送数据失败：port必须时数字")
            return
        }
        
        UDPManager.default.send(data, toHost: host, port: port, tag: 0)
    }
    
    @IBAction func onSimulate(_ sender: UIButton) {
        isSimulateOpen = !isSimulateOpen
        displayLink.isPaused = !isSimulateOpen
        appendText(isSimulateOpen ? "开启数据模拟" : "关闭数据模拟")
        sender.setTitle(!isSimulateOpen ? "开启数据模拟" : "关闭数据模拟", for: .normal)
    }
    
    @objc private func onClickEmpty(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func onSelectColor(_ button: UIButton) {
        let color = candidateColors[button.tag]
        let str = String(format: "%06x", color)
        colorField.text = str.uppercased()
    }
    
    @IBAction func onColorApply(_ button: UIButton) {
        let colorStr = colorField.text ?? ""
        let isColor = isColorStrAvaliable(colorStr)
        guard isColor else {
            Toast.showRightNow("不是合法的颜色")
            return
        }
        UserDefaults.standard.setValue(colorStr, forKey: "theme_color")
        AlertView(title: "注意", message: "颜色设置成功，重启后生效", markButtonTitle: "确定", otherButtonTitles: nil).show()
    }
    
    private func appendText(_ str: String) {
        
        DispatchQueue.main.async {
//            let newStr = self.receiveTextView.text! + str + "\n"
//            self.receiveTextView.text = newStr
//            self.receiveTextView.setContentOffset(CGPoint(x: 0, y: max(0, self.receiveTextView.contentSize.height - self.receiveTextView.frame.height)), animated: true)
        }
    }
   
    private func isColorStrAvaliable(_ str: String) -> Bool {
        guard str.count == 6 else { return false }
        for char in str {
            if !["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"].contains(char) {
                return false
            }
        }
        return true
    }
    
    @objc func update() {
        
        guard let host = sendHostTextField.text, !host.isEmpty else {
            appendText("发送数据失败：host不得为空")
            return
        }
        
        guard let portStr = sendPortTextField.text, !portStr.isEmpty else {
            appendText("发送数据失败：port不得为空")
            return
        }
        
        guard let port = UInt16(portStr) else {
            appendText("发送数据失败：port必须时数字")
            return
        }
        
//        let exampleValues: [Double] = [90]
        let exampleValues: [Double] = [80,45,4.11,128.58,128.58,128.58,128.58,128.58,33.06,35.12,99.21138,-9.8,16.2,174.2,9.81,9.81,9.81,12.6,12.6,300]
        
        var simulateDatas = exampleValues.map({ Double.random(in: ($0 - Double.random(in: 0..<5))..<($0 + Double.random(in: 0..<5))) })
        simulateDatas.insert(Double(currentDataIndex), at: 0)
        currentDataIndex += 1
        let valueStr = simulateDatas.map({ "\($0)" }).joined(separator: ",")
        let data = valueStr.data(using: .utf8)!
        UDPManager.default.send(data, toHost: host, port: port, tag: 0)
    }
    
    private func getWiFiAddress() -> String? {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
}

extension SettingViewController: UDPListener {

    func didReceive(_ data: Data, fromHost host: String, port: UInt16) {
//        let str = String(data: data, encoding: .utf8)!
//        print(#function, str, host, port)
//        appendText("接收数据：" + str)
    }
    
    func didSend(_ tag: Int) {
        if displayLink.isPaused {
            appendText("发送数据成功")
        }
    }
    
    func didNotSend(_ tag: Int, dueToError error: Error?) {
        appendText("数据发送失败：\(error?.localizedDescription ?? "未知错误")")
    }
}
