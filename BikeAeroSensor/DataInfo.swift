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
    case currentDataFrequency = "Current Data Frequency"
    case batteryVoltage
    case differentialPressure0 = "Differential Pressure 0"
    case differentialPressure1 = "Differential Pressure 1"
    case differentialPressure2 = "Differential Pressure 2"
    case differentialPressure3 = "Differential Pressure 3"
    case differentialPressure4 = "Differential Pressure 4"
    case averageDPTemperature = "average DP Temperature"
    case bmpTemperature = "dpTemp"
    case bmpPressure = "ATM"
    case pitchAngle = "Pitch Angle"
    case rollAngle = "Roll Angle"
    case yawAngle = "Yaw Angle"
    case icmAccX = "Icm Acc X"
    case icmAccY = "Icm Acc Y"
    case icmAccZ = "Icm Acc Z"
    case icmGyrX = "Icm Gyr X"
    case icmGyrY = "Icm Gyr Y"
    case icmGyrZ = "Icm Gyr Z"
    case windSpeed = "Wind Speed"
    case windPitch = "Wind Pitch"
    case windYaw = "Wind Yaw"
}
