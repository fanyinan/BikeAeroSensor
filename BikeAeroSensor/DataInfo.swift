//
//  DataInfo.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/28.
//

import UIKit

struct ProbeData {
//    let currentDataIndex: Int
//    let wiFiSignalStrength: Int
//    let currentDataFrequency: Int
//    let batteryVoltage: Double
//    let windSpeed: Double
//    let windPitching: Double
//    let windYaw: Double
//    let sensorPitch: Double
//    let sensorRoll: Double
//    let sensoryaw: Double
//    let bmpTemperature: Double
//    let bmpPressure: Double
    let visualData: [DataName: Double]
    let displayData: [DynamicData]
}

class DataInfo {
    let label: DataName
    let color: UIColor
    var unit: String
    var values: [Double] = []
    var needShow: Bool
    var isVisual: Bool
    var isDisplay: Bool
    
    init(label: DataName, color: UIColor, unit: String, isVisual: Bool, isDisplay: Bool, needShow: Bool = false) {
        self.label = label
        self.color = color
        self.unit = unit
        self.needShow = needShow
        self.isVisual = isVisual
        self.isDisplay = isDisplay
    }
}

enum DataName: String {
    case currentDataIndex
    case wiFiSignalStrength
    case currentDataFrequency
    case batteryVoltage
    case differentialPressure0
    case differentialPressure1
    case differentialPressure2
    case differentialPressure3
    case differentialPressure4
    case averageDPTemperature
    case bmpTemperature = "dpTemp"
    case bmpPressure = "ATM"
    case pitchAngle
    case rollAngle
    case yawAngle
    case icmAccX
    case icmAccY
    case icmAccZ
    case icmGyrX
    case icmGyrY
    case icmGyrZ
    case windSpeed
    case windPitch
    case windYaw
}
