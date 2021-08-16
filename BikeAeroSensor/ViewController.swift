//
//  ViewController.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/16.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController {

    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var sendPortTextField: UITextField!
    @IBOutlet weak var sendHostTextField: UITextField!

    @IBOutlet weak var sendTextField: UITextField!
    @IBOutlet weak var receiveTextView: UITextView!
    
    private var socket: GCDAsyncUdpSocket!

    deinit {
        socket.close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue(label: "server_queue"), socketQueue: nil)
    }

    @IBAction func createServer(_ sender: Any) {
        print(#function)
        
        do {
            guard let port = UInt16(portTextField.text!) else {
                appendText("创建socket失败：我的端口号错误")
                return
            }
            
            try socket.bind(toPort: port)
            try socket.beginReceiving()
        } catch let error {
            print(error)
            appendText("创建socket失败：\(error.localizedDescription)")
        }
        
        appendText("创建socket成功!")
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
        
        socket.send(data, toHost: host, port: port, withTimeout: 60, tag: 200)
    }
    
    private func appendText(_ str: String) {
        
        DispatchQueue.main.async {
            let newStr = self.receiveTextView.text! + str + "\n"
            self.receiveTextView.text = newStr
        }
    }
}

extension ViewController: GCDAsyncUdpSocketDelegate {
    
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
