//
//  UDP.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/18.
//

import Foundation
import CocoaAsyncSocket

@objc protocol UDPDelegate: NSObjectProtocol {
    func udp(_ udp: UDP, didReceive data: Data, fromHost host: String, port: UInt16)
    @objc optional func udp(_ udp: UDP, didSendDataWithTag tag: Int)
    @objc optional func udp(_ udp: UDP, didNotSendDataWithTag tag: Int, dueToError error: Error?)
}

class UDP: NSObject {
    
    private var receiveSocket: GCDAsyncUdpSocket!
    private var sendSocket: GCDAsyncUdpSocket!
    weak var delegate: UDPDelegate?
    
    deinit {
        receiveSocket.close()
        sendSocket.close()
    }
    
    override init() {
        super.init()
        receiveSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue(label: "reveive_queue"), socketQueue: nil)
        sendSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue(label: "send_queue"), socketQueue: nil)
    }
    
    func listen(port: UInt16) throws {
        try receiveSocket.bind(toPort: port)
        try receiveSocket.beginReceiving()
    }
    
    func send(_ data: Data, toHost host: String, port: UInt16, tag: Int) {
        sendSocket.send(data, toHost: host, port: port, withTimeout: 5, tag: tag)
    }
    
}


extension UDP: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let host = GCDAsyncUdpSocket.host(fromAddress: address) ?? "error host"
        let port = GCDAsyncUdpSocket.port(fromAddress: address)
        delegate?.udp(self, didReceive: data, fromHost: host, port: port)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        delegate?.udp?(self, didSendDataWithTag: tag)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        delegate?.udp?(self, didNotSendDataWithTag: tag, dueToError: error)
    }

}
