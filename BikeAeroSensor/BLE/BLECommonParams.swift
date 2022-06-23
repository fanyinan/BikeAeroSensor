//
//  BLECommonParams.swift
//  bletool
//
//  Created by shenyutao on 2022/6/17.
//

import CoreBluetooth

struct BLECommonParams {
    /// 默认蓝牙设备信息
    private static let BLEDefaultDeviceUUIDKey = "BLEDeviceUUIDKey"
    static var defaultDeviceUUID: String = UserDefaults.standard.string(forKey: Self.BLEDefaultDeviceUUIDKey) ?? ""  { // 内存中缓存一份默认蓝牙设备的uuidStr
        didSet {
            guard oldValue != defaultDeviceUUID else { return }
            UserDefaults.standard.setValue(defaultDeviceUUID, forKey: Self.BLEDefaultDeviceUUIDKey)
        }
    }
    
    /// 电池uuid
    static let batteryServiceUUIDString = "180F"
    static let BatteryCharacteristicUUIDString = "2A19"
    
    /// 自定义传感器数据uuid
    static let commonServiceUUIDString = "1A01"
    static let DeviceDataCharacteristicUUIDString = "5A01"

    /// 蓝牙设备service uuid 和 characteristic uuid 字典
    static let ServiceCharacteristicUUIDs = [
        batteryServiceUUIDString: Set<String>([
            BatteryCharacteristicUUIDString
        ]),
        commonServiceUUIDString: Set<String>([
            DeviceDataCharacteristicUUIDString
        ])
    ]
    
    static var ServicesUUIDs: [CBUUID] {
        ServiceCharacteristicUUIDs.keys.compactMap { CBUUID(string: $0) }
    }
}
