//
//  UDPManager.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import Foundation

@objc protocol UDPListener: NSObjectProtocol {
    func didReceive(_ data: Data, fromHost host: String, port: UInt16)
    @objc optional func didSend(_ tag: Int)
    @objc optional func didNotSend(_ tag: Int, dueToError error: Error?)
}

class UDPManager: NSObject {
    
    static let `default` = UDPManager()
    
    private let udp = UDP()
    
    private var subscribers: NSHashTable<UDPListener> = NSHashTable<UDPListener>.weakObjects()
    private(set) var port: UInt16?
    private(set) var sendHost: String?
    private(set) var sendPort: UInt16?

    override init() {
        super.init()
        udp.delegate = self
        let port = (UserDefaults.standard.value(forKey: "port") as? UInt16) ?? 1133
        bind(port)

    }
    
    func addListener(_ listener: UDPListener) {
        subscribers.add(listener)
    }

    func bind(_ port: UInt16) {
        
        do {
            try udp.bind(port: port)
            self.port = port
            Toast.showRightNow("绑定端口成功")
            UserDefaults.standard.setValue(port, forKey: "port")
        } catch let error {
            print(error)
            Toast.showRightNow("绑定端口失败：\(error.localizedDescription)")
        }
    }
    
    func send(_ data: Data, toHost host: String, port: UInt16, tag: Int) {
        udp.send(data, toHost: host, port: port, tag: tag)
    }
}


extension UDPManager: UDPDelegate {

    func udp(_ udp: UDP, didReceive data: Data, fromHost host: String, port: UInt16) {
        sendHost = host
        sendPort = port
        for subcriber in subscribers.allObjects {
            subcriber.didReceive(data, fromHost: host, port: port)
        }
    }
    
    func udp(_ udp: UDP, didSendDataWithTag tag: Int) {
        for subcriber in subscribers.allObjects {
            subcriber.didSend?(tag)
        }
    }
    
    func udp(_ udp: UDP, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        for subcriber in subscribers.allObjects {
            subcriber.didNotSend?(tag, dueToError: error)
        }
    }
}
