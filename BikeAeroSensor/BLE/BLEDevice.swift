//
//  BLEDevice.swift
//  bletool
//
//  Created by shenyutao on 2022/6/17.
//

import Foundation
import CoreBluetooth

@objc protocol BLEDeviceDelegte {
    
    /// 蓝牙设备characteristic uuid 对应的value值回调
    /// - Parameters:
    ///   - characteristicUUIDString: characteristic uuid
    ///   - value: characteristic value
    @objc optional func deviceValueDidChanged(characteristicUUIDString: String, value: Data?)
}

class BLEDevice: NSObject {
    static let UnknownDeviceName = "unknown"
    
    private let peripheral: CBPeripheral
    private let centeralManager: CBCentralManager
    private var delegateSet = NSHashTable<AnyObject>(options: .weakMemory)
    
    /// 设备名
    var name: String {
        peripheral.name ?? Self.UnknownDeviceName
    }
    
    /// 蓝牙设备连接状态
    var state: CBPeripheralState {
        peripheral.state
    }
    
    init(peripheral: CBPeripheral, centeralManager: CBCentralManager) {
        self.peripheral = peripheral
        self.centeralManager = centeralManager
        super.init()
        self.peripheral.delegate = self
    }
    
    /// 连接蓝牙设备
    func connect() {
        centeralManager.connect(peripheral)
    }
    
    /// 获取设备services
    func discoverServices() {
        peripheral.discoverServices(BLECommonParams.ServicesUUIDs)
    }
    
    /// 断开设备蓝牙链接
    func disconnect() {
        centeralManager.cancelPeripheralConnection(peripheral)
    }
}

extension BLEDevice: CBPeripheralDelegate {
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        debugLog("Device: discovered services")
        peripheral.services?.forEach { service in
            debugLog("----\(service)")
            var discoverCharacteristicsUUIDs: [CBUUID]? = nil
            if BLECommonParams.ServiceCharacteristicUUIDs.keys.contains(service.uuid.uuidString),
               let characteristics = BLECommonParams.ServiceCharacteristicUUIDs[service.uuid.uuidString] {
                discoverCharacteristicsUUIDs = service.characteristics?.compactMap { $0.uuid }.filter { characteristics.contains($0.uuidString) }
            }
            peripheral.discoverCharacteristics(discoverCharacteristicsUUIDs, for: service)
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let matchedCharacteristics = BLECommonParams.ServiceCharacteristicUUIDs[service.uuid.uuidString] else {
            return
        }
        debugLog("Device: discovered characteristics")
        service.characteristics?.forEach { characteristic in
            debugLog("----\(characteristic)")
            if matchedCharacteristics.contains(characteristic.uuid.uuidString) {
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            } else {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        debugLog("Device: updated value for \(characteristic)")
        if let data = characteristic.value {
            DispatchQueue.global().async {
                self.trigger { $0.deviceValueDidChanged?(characteristicUUIDString: characteristic.uuid.uuidString, value: data) }
            }
        }
    }
}

extension BLEDevice {
    func register(delegate: BLEDeviceDelegte) {
        if delegateSet.member(delegate) == nil {
            delegateSet.add(delegate)
        }
    }
    
    func unRegister(delegate: BLEDeviceDelegte) {
        if delegateSet.member(delegate) == nil {
            delegateSet.remove(delegate)
        }
    }
    
    private func trigger(_ action: (BLEDeviceDelegte) -> Void) {
        delegateSet.allObjects.forEach { delegate in
            if let delegate = delegate as? BLEDeviceDelegte {
                action(delegate)
            }
        }
    }
}
