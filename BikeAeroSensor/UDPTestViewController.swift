//
//  UDPTestViewController.swift
//  BikeAeroSensor
//
//  Created by yinan17 on 2021/8/18.
//

import UIKit
//import CocoaAsyncSocket

class UDPTestViewController: UIViewController {

    @IBOutlet weak var myIPLabel: UILabel!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var sendPortTextField: UITextField!
    @IBOutlet weak var sendHostTextField: UITextField!

    @IBOutlet weak var sendTextField: UITextField!
    @IBOutlet weak var receiveTextView: UITextView!
    
    private let udp = UDP()
    private var isSimulateOpen = false
    private var currentDataIndex = 0
    
    lazy var displayLink: CADisplayLink = {
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
        udp.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickEmpty(_:)))
        view.addGestureRecognizer(tap)
        let ips = getWiFiAddress() ?? "unknow"
        myIPLabel.text = ips
    }

    @IBAction func createServer(_ sender: Any) {
        print(#function)
        
        do {
            guard let port = UInt16(portTextField.text!) else {
                appendText("创建socket失败：我的端口号错误")
                return
            }
            
            try udp.listen(port: port)
            appendText("创建socket成功!")
        } catch let error {
            print(error)
            appendText("创建socket失败：\(error.localizedDescription)")
        }
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
        
        udp.send(data, toHost: host, port: port, tag: 0)
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
    
    private func appendText(_ str: String) {
        
        DispatchQueue.main.async {
            let newStr = self.receiveTextView.text! + str + "\n"
            self.receiveTextView.text = newStr
            self.receiveTextView.setContentOffset(CGPoint(x: 0, y: max(0, self.receiveTextView.contentSize.height - self.receiveTextView.frame.height)), animated: true)
        }
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
        
        let exampleValues: [Double] = [90]
//        let exampleValues: [Double] = [90,45,4.11,128.58,128.58,128.58,128.58,128.58,33.06,35.12,99.21138,-9.8,16.2,174.2,9.81,9.81,9.81,12.6,12.6,12.6]
        
        var simulateDatas = exampleValues.map({ Double.random(in: ($0 - Double.random(in: 0..<5))..<($0 + Double.random(in: 0..<5))) })
        simulateDatas.insert(Double(currentDataIndex), at: 0)
        currentDataIndex += 1
        let valueStr = simulateDatas.map({ "\($0)" }).joined(separator: ",")
        let data = valueStr.data(using: .utf8)!
        udp.send(data, toHost: host, port: port, tag: 0)
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

extension UDPTestViewController: UDPDelegate {

    func udp(_ udp: UDP, didReceive data: Data, fromHost host: String, port: UInt16) {
        let str = String(data: data, encoding: .utf8)!
        print(#function, str, host, port)
        
        appendText("接收数据：" + str)
    }
    
    func udp(_ udp: UDP, didSendDataWithTag tag: Int) {
        if displayLink.isPaused {
            appendText("发送数据成功")
        }
    }
    
    func udp(_ udp: UDP, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        appendText("数据发送失败：\(error?.localizedDescription ?? "未知错误")")
    }
    
    
}
