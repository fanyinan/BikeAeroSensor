//
//  ProbeFileManager.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import Foundation
import PathKit

let dateFormatter = DateFormatter()

class ProbeDataFile {
    
    private let fileHandle: FileHandle
    let fileInfo: ProbeFileInfo
    
    let path: Path
    var didWrite = false

    init(path: Path) {
        self.path = path
        path.createFileIfNeeded(data: nil)
        fileHandle = FileHandle(forWritingAtPath: path.string)!
        fileInfo = ProbeFileInfo(fileName: path.lastComponentWithoutExtension)
        writeHeader()
    }
    
    func write(_ data: Data) {
        if !didWrite {
            didWrite = true
        }
        
        _write(data)
    }
    
    func finish() {
        try! fileHandle.close()
        fileInfo.end()
    }
    
    func writeHeader() {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateStr = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "HH:mm:ss"
        let timeStr = dateFormatter.string(from: Date())
        
        let headerStr = "# THIS FILE IS FOR AEROMETER DATA RECORDING.\n" +
            "# Version: \(Version.current.string)\n" +
        "# Date: \(dateStr)\n" +
        "# Time: \(timeStr) (Hong Kong Time)\n" +
        "# Copyright (c) 2018, The Aerodynamics Acoustics & Noise control Technology Centre(AANTC), Performance Sports Engineering Research Group\n" +
        "# <aantc.ust.hk>\n" +
        "# All rights reserved.\n" +
        "***End_of_Header***\n" +
        "currentDataIndex,wiFiSignalStrength,currentDataFrequency,batteryVoltage,differentialPressure0,differentialPressure1,differentialPressure2,differentialPressure3,differentialPressure4,averageDPTemperature,bmpTemperature,bmpPressure,pitchAngle,rollAngle,yawAngle,icmAccX,icmAccY,icmAccZ,icmGyrX,icmGyrY,icmGyrZ\n"
        let headerData = headerStr.data(using: .utf8)!
        _write(headerData)
    }
    
    private func _write(_ data: Data) {
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
        fileInfo.increaseCount()
    }
}

class ProbeFileInfo: Codable {
    
    enum CodingKeys: CodingKey {
        case startTime, endTime, dataCount, fileName, name, isSent
    }
    
    var name: String?
    private(set) var startTime = Date()
    private(set) var endTime: Date!
    private(set) var dataCount = 0
    private(set) var isSent = true
    var displayName: String {
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        return name ?? dateFormatter.string(from: startTime)
    }
    
    var desc: String {
        dateFormatter.dateFormat = "HH:mm:ss"
        return "time : \(dateFormatter.string(from: startTime)) - \(dateFormatter.string(from: endTime))   count : \(dataCount)"
    }
    
    private(set) var fileName: String
    
    var filePath: Path {
        return ProbeFileManager.shared.folderPath + Path(fileName)
    }
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        dataCount = try container.decode(Int.self, forKey: .dataCount)
        fileName = try container.decode(String.self, forKey: .fileName)
        name = try container.decode(String?.self, forKey: .name)
        isSent = try container.decode(Bool.self, forKey: .isSent)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(dataCount, forKey: .dataCount)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(name, forKey: .name)
        try container.encode(isSent, forKey: .isSent)
    }
    
    func increaseCount() {
        dataCount += 1
    }
    
    func end() {
        endTime = Date()
    }
    
    func markSent() {
        isSent = true
    }
}

class ProbeFileManager {
    
    static let shared = ProbeFileManager()
    
    private var currentFile: ProbeDataFile!

    private(set) var fileInfos: [ProbeFileInfo] = []
    
    private lazy var configFilePath: Path = {
        return folderPath + Path("config.json")
    }()
    
    private(set) lazy var folderPath: Path = {
        return Path.document + Path("recoredData")
    }()
    
    private let fileQueue = DispatchQueue(label: "com.file")
    
    private init() {
        let emptyDraftInfo: [ProbeFileInfo] = []
        let data = try! JSONEncoder().encode(emptyDraftInfo)
        folderPath.createFolderIfNeeded()
        configFilePath.createFileIfNeeded(data: data)
    }
    
    func load() {
        let data = try! configFilePath.read()
        fileInfos = try! JSONDecoder().decode([ProbeFileInfo].self, from: data)
    }
    
    func begin()  {
        fileQueue.async {
            let fileName = UUID().uuidString
            let filePath = self.folderPath + Path(fileName)
            self.currentFile = ProbeDataFile(path: filePath)
        }
    }
    
    func write(_ data: Data) {
        fileQueue.async {
            var data = data
            let enterData = "\n".data(using: .utf8)!
            data.append(enterData)
            self.currentFile?.write(data)
        }
    }
    
    func finish(completion: @escaping ((Bool) -> Void)) {
        fileQueue.async {
            assert(self.currentFile != nil)
            self.currentFile.finish()
            if !self.currentFile.didWrite {
                completion(false)
                return
            }
            self.fileInfos.append(self.currentFile.fileInfo)
            let jsonData = try! JSONEncoder().encode(self.fileInfos)
            try! self.configFilePath.write(jsonData)
            self.currentFile = nil
            completion(true)
        }
    }

    func delete(_ infos: [ProbeFileInfo], completion: @escaping (() -> Void)) {
        
        fileQueue.async {
            for info in infos {            
                self.fileInfos.removeAll(where: { $0.fileName == info.fileName })
            }
            self.saveSync()
            completion()
        }
    }
    
    func save() {
        fileQueue.async {
            self.saveSync()
        }
    }
    
    private func saveSync() {
        let jsonData = try! JSONEncoder().encode(fileInfos)
        try! configFilePath.write(jsonData)
    }
}
