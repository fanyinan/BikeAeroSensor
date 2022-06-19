//
//  BLECommonParams.swift
//  bletool
//
//  Created by shenyutao on 2022/6/17.
//

import CoreBluetooth

extension DataName {
    private static let batteryCharacteristicUUIDString = "2A19"

    private static let currentDataIndexCharacteristicUUIDString = "5A01"
    private static let currentDataFrequencyCharacteristicUUIDString = "5A02"
    private static let differentPressure0CharacteristicUUIDString = "5A04"
    private static let differentPressure1CharacteristicUUIDString = "5A05"
    private static let differentPressure2CharacteristicUUIDString = "5A06"
    private static let differentPressure3CharacteristicUUIDString = "5A07"
    private static let differentPressure4CharacteristicUUIDString = "5A08"
    private static let averageDPTemptureCharacteristicUUIDString = "5A09"
    private static let bmpTemperatureCharacteristicUUIDString = "5A0A"
    private static let bmpPressureCharacteristicUUIDString = "5A0B"
    private static let pitchAngleCharacteristicUUIDString = "5A0C"
    private static let rollAngleCharacteristicUUIDString = "5A0D"
    private static let yawAngleCharacteristicUUIDString = "5A0E"
    private static let icmAccXCharacteristicUUIDString = "5A0F"
    private static let icmAccYCharacteristicUUIDString = "5A10"
    private static let icmAccZCharacteristicUUIDString = "5A11"
    private static let icmGyrXCharacteristicUUIDString = "5A12"
    private static let icmGyrYCharacteristicUUIDString = "5A13"
    private static let icmGyrZCharacteristicUUIDString = "5A14"
 
    var characteristicUUIDString: String? {
        switch self {
        case .currentDataIndex:
            return Self.currentDataIndexCharacteristicUUIDString
        case .currentDataFrequency:
            return Self.currentDataFrequencyCharacteristicUUIDString
        case .batteryVoltage:
            return Self.batteryCharacteristicUUIDString
        case .differentialPressure0:
            return Self.differentPressure0CharacteristicUUIDString
        case .differentialPressure1:
            return Self.differentPressure1CharacteristicUUIDString
        case .differentialPressure2:
            return Self.differentPressure2CharacteristicUUIDString
        case .differentialPressure3:
            return Self.differentPressure3CharacteristicUUIDString
        case .differentialPressure4:
            return Self.differentPressure4CharacteristicUUIDString
        case .averageDPTemperature:
            return Self.averageDPTemptureCharacteristicUUIDString
        case .bmpTemperature:
            return Self.bmpTemperatureCharacteristicUUIDString
        case .bmpPressure:
            return Self.bmpPressureCharacteristicUUIDString
        case .pitchAngle:
            return Self.pitchAngleCharacteristicUUIDString
        case .rollAngle:
            return Self.rollAngleCharacteristicUUIDString
        case .yawAngle:
            return Self.yawAngleCharacteristicUUIDString
        case .icmAccX:
            return Self.icmAccXCharacteristicUUIDString
        case .icmAccY:
            return Self.icmAccYCharacteristicUUIDString
        case .icmAccZ:
            return Self.icmAccZCharacteristicUUIDString
        case .icmGyrX:
            return Self.icmGyrXCharacteristicUUIDString
        case .icmGyrY:
            return Self.icmGyrYCharacteristicUUIDString
        case .icmGyrZ:
            return Self.icmGyrZCharacteristicUUIDString
        default:
            return nil
        }
    }
    
    
    static func convert(_ uuidString: String) -> DataName? {
        switch uuidString {
        case Self.batteryCharacteristicUUIDString:
            return .batteryVoltage
        case Self.currentDataIndexCharacteristicUUIDString:
            return .currentDataIndex
        case Self.currentDataFrequencyCharacteristicUUIDString:
            return .currentDataFrequency
        case Self.differentPressure0CharacteristicUUIDString:
            return .differentialPressure0
        case Self.differentPressure1CharacteristicUUIDString:
            return .differentialPressure1
        case Self.differentPressure2CharacteristicUUIDString:
            return .differentialPressure2
        case Self.differentPressure3CharacteristicUUIDString:
            return .differentialPressure3
        case Self.differentPressure4CharacteristicUUIDString:
            return .differentialPressure4
        case Self.averageDPTemptureCharacteristicUUIDString:
            return .averageDPTemperature
        case Self.bmpTemperatureCharacteristicUUIDString:
            return .bmpTemperature
        case Self.bmpPressureCharacteristicUUIDString:
            return .bmpPressure
        case Self.pitchAngleCharacteristicUUIDString:
            return .pitchAngle
        case Self.rollAngleCharacteristicUUIDString:
            return .rollAngle
        case Self.yawAngleCharacteristicUUIDString:
            return .yawAngle
        case Self.icmAccXCharacteristicUUIDString:
            return .icmAccX
        case Self.icmAccYCharacteristicUUIDString:
            return .icmAccY
        case Self.icmAccZCharacteristicUUIDString:
            return .icmAccZ
        case Self.icmGyrXCharacteristicUUIDString:
            return .icmGyrX
        case Self.icmGyrYCharacteristicUUIDString:
            return .icmGyrY
        case Self.icmGyrYCharacteristicUUIDString:
            return .icmGyrZ
        default:
            return nil
        }
    }
}

struct BLECommonParams {
    /// 电池uuid
    private static let batteryServiceUUIDString = "180F"
    
    /// 自定义传感器数据uuid
    private static let commonServiceUUIDString = "1A01"

    /// 蓝牙设备service uuid 和 characteristic uuid 字典
    static let ServiceCharacteristicUUIDs = [
        batteryServiceUUIDString: Set<String>([
            DataName.batteryVoltage.characteristicUUIDString!
        ]),
        commonServiceUUIDString: Set<String>([
            DataName.currentDataIndex.characteristicUUIDString!,
            DataName.currentDataFrequency.characteristicUUIDString!,
            DataName.differentialPressure0.characteristicUUIDString!,
            DataName.differentialPressure1.characteristicUUIDString!,
            DataName.differentialPressure2.characteristicUUIDString!,
            DataName.differentialPressure3.characteristicUUIDString!,
            DataName.differentialPressure4.characteristicUUIDString!,
            DataName.averageDPTemperature.characteristicUUIDString!,
            DataName.bmpTemperature.characteristicUUIDString!,
            DataName.bmpPressure.characteristicUUIDString!,
            DataName.pitchAngle.characteristicUUIDString!,
            DataName.rollAngle.characteristicUUIDString!,
            DataName.yawAngle.characteristicUUIDString!,
            DataName.icmAccX.characteristicUUIDString!,
            DataName.icmAccY.characteristicUUIDString!,
            DataName.icmAccZ.characteristicUUIDString!,
            DataName.icmGyrX.characteristicUUIDString!,
            DataName.icmGyrY.characteristicUUIDString!,
            DataName.icmGyrZ.characteristicUUIDString!,
        ])
    ]
    
    static var ServicesUUIDs: [CBUUID] {
        ServiceCharacteristicUUIDs.keys.compactMap { CBUUID(string: $0) }
    }
}
