//
//  UDPTestViewController.swift
//  BikeAeroSensor
//
//  Created by yinan17 on 2021/8/18.
//

import UIKit
import CocoaAsyncSocket

class UDPTestViewController: UIViewController {

    @IBOutlet weak var myIPLabel: UILabel!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var sendPortTextField: UITextField!
    @IBOutlet weak var sendHostTextField: UITextField!

    @IBOutlet weak var sendTextField: UITextField!
    @IBOutlet weak var receiveTextView: UITextView!
    
    private var receiveSocket: GCDAsyncUdpSocket!
    private var sendSocket: GCDAsyncUdpSocket!

    deinit {
        receiveSocket.close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        receiveSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue(label: "reveive_queue"), socketQueue: nil)
        sendSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue(label: "send_queue"), socketQueue: nil)
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
            
            try receiveSocket.bind(toPort: port)
            try receiveSocket.beginReceiving()
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
        
        sendSocket.send(data, toHost: host, port: port, withTimeout: 60, tag: 200)
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
   
    func getWiFiAddress() -> String? {
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

extension UDPTestViewController: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        let host = GCDAsyncUdpSocket.host(fromAddress: address) ?? "error host"
        let port = GCDAsyncUdpSocket.port(fromAddress: address)
        print(#function, host, port)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print(#function)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let host = GCDAsyncUdpSocket.host(fromAddress: address) ?? "error host"
        let port = GCDAsyncUdpSocket.port(fromAddress: address)

        let str = String(data: data, encoding: .utf8)!
        print(#function, str, host, port)
        
        appendText("接收数据：" + str)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        appendText("发送数据成功")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        appendText("数据发送失败：\(error?.localizedDescription ?? "位置错误")")
    }

}
