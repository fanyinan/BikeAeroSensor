//
//  BLEManager.swift
//  bletool
//
//  Created by shenyutao on 2022/6/17.
//

import Foundation
import CoreBluetooth

@objc protocol BLEManagerProtocol {
    
    /// 扫描开关改变回调
    /// - Parameter on: 开关状态
    @objc optional func didScan(on: Bool)
    
    /// 发现蓝牙设备回调
    /// - Parameter device: 蓝牙设备
    @objc optional func didDiscover(device: BLEDevice)
    
    /// 系统蓝牙状态变更回调
    /// - Parameter state: 蓝牙状态
    @objc optional func didChangedState(state: CBManagerState)
    
    /// 连接到蓝牙设备回调
    /// - Parameter device: 蓝牙设备
    @objc optional func didConnected(_ device: BLEDevice)
    
    /// 断开蓝牙设备回调
    /// - Parameter device: 蓝牙设备
    @objc optional func didDisconnected(_ device: BLEDevice)
}

class BLEManager: NSObject {
    
    /// 单例
    public static let sharedInstanced = BLEManager()
    
    private let manager: CBCentralManager
    private var scanedDevice: [UUID: BLEDevice] = [:]
    private var delegateSet = NSHashTable<AnyObject>(options: .weakMemory)
    
    /// 扫描开关
    var scanning: Bool = false {
        willSet {
            guard scanning != newValue else { return }
            if scanning && manager.state != .poweredOn {
                return
            }
        }
        didSet {
            debugLog("Manager: scan state set to \(scanning)")
            if scanning {
                manager.scanForPeripherals(withServices: nil)
                // TODO: 指定service uuid后模拟测试时扫描不出任何设备，后续探究
                // manager.scanForPeripherals(withServices: BLECommonParams.ServicesUUIDs)
            } else {
                manager.stopScan()
            }
            trigger { $0.didScan?(on: scanning) }
        }
    }
    
    /// 发现的蓝牙设备
    var deveices: [BLEDevice] {
        Array(scanedDevice.values).sorted { $0.name == BLEDevice.UnknownDeviceName ? false : $0.name < $1.name }
    }
    
    /// 本机蓝牙状态
    var state: CBManagerState {
        manager.state
    }
    
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    private override init() {
        manager = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        super.init()
        manager.delegate = self
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        debugLog("Manager: state \(manager.state)")
        if manager.state != .poweredOn {
            scanning = false
            scanedDevice = [:]
        }
        trigger { $0.didChangedState?(state: manager.state) }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugLog("Manager: connected \(peripheral)")
        if let device = scanedDevice[peripheral.identifier] {
            scanedDevice.values.forEach { // 断开其他蓝牙设备，仅支持连接一个设备
                guard $0 != device, $0.state == .connected || $0.state == .connecting else { return }
                $0.disconnect()
            }
            device.discoverServices()
            trigger { $0.didConnected?(device) }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugLog("Manager: failed connect \(peripheral), error \(error.debugDescription)")
        if let device = scanedDevice[peripheral.identifier] {
            trigger { $0.didDisconnected?(device) }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugLog("Manager: disconnected \(peripheral), error \(error.debugDescription)")
        if let device = scanedDevice[peripheral.identifier] {
            trigger { $0.didDisconnected?(device) }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !scanedDevice.keys.contains(peripheral.identifier) else {
            return
        }
        debugLog("Manager: discovered \(peripheral), rssi: \(RSSI)")
        let device = BLEDevice(peripheral: peripheral, centeralManager: manager)
        scanedDevice[peripheral.identifier] = device
        trigger { $0.didDiscover?(device: device) }
    }
}

extension BLEManager {
    func register(delegate: BLEManagerProtocol) {
        if delegateSet.member(delegate) == nil {
            delegateSet.add(delegate)
        }
    }
    
    func unRegister(delegate: BLEManagerProtocol) {
        if delegateSet.member(delegate) == nil {
            delegateSet.remove(delegate)
        }
    }
    
    private func trigger(_ action: (BLEManagerProtocol) -> Void) {
        delegateSet.allObjects.forEach { delegate in
            if let delegate = delegate as? BLEManagerProtocol {
                action(delegate)
            }
        }
    }
}
