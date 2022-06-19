//
//  UDPManager.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import UIKit

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
        NotificationCenter.default.addObserver(self, selector: #selector(onWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func addListener(_ listener: UDPListener) {
        subscribers.add(listener)
    }
    
    func bind(_ port: UInt16, completion: ((Bool) -> Void)? = nil) {
        do {
            try udp.bind(port: port)
            self.port = port
            Toast.showRightNow("Bind the port successfully.")
            completion?(true)
            UserDefaults.standard.setValue(port, forKey: "port")
        } catch let error {
            print(error)
            Toast.showRightNow("Failed to bind the port.：\(error.localizedDescription)")
            completion?(false)
        }
    }
    
    func send(_ data: Data) -> Bool {
        guard let sendHost = sendHost, let sendPort = sendPort else { return false }
        send(data, toHost: sendHost, port: sendPort, tag: 0)
        return true
    }
    
    func send(_ data: Data, toHost host: String, port: UInt16, tag: Int) {
        udp.send(data, toHost: host, port: port, tag: tag)
    }
    
    @objc private func onWillEnterForeground() {
        guard let port = port else { return }
        bind(port)
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
