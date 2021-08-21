//
//  ProbeFileManager.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import Foundation
import PathKit

class ProbeDataFile {
    
    private let fileHandle: FileHandle
    let path: Path
    var didWrite = false
    
    init(path: Path) {
        self.path = path
        path.createFileIfNeeded(data: nil)
        fileHandle = FileHandle(forWritingAtPath: path.string)!
    }
    
    func write(_ data: Data) {
        if !didWrite {
            didWrite = true
        }
        
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
    }
    
    func finish() {
        try! fileHandle.close()
    }
}

class ProbeFileInfo: Codable {
    var fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
}

class ProbeFileManager {
    
    static let shared = ProbeFileManager()
    
    private let dateFormatter = DateFormatter()
    private var currentFile: ProbeDataFile!
    
    private(set) var fileInfos: [ProbeFileInfo] = []
    
    private lazy var configFilePath: Path = {
        return Path.document + Path("config.json")
    }()
    
    private let fileQueue = DispatchQueue(label: "com.file")
    
    private init() {
        dateFormatter.dateFormat = "YYYY-MM-dd_HH:mm:ss"
        let emptyDraftInfo: [ProbeFileInfo] = []
        let data = try! JSONEncoder().encode(emptyDraftInfo)
        configFilePath.createFileIfNeeded(data: data)
    }
    
    func load() {
        let data = try! configFilePath.read()
        fileInfos = try! JSONDecoder().decode([ProbeFileInfo].self, from: data)
    }
    
    func begin()  {
        fileQueue.async {
            let fileName = self.dateFormatter.string(from: Date())
            let filePath = Path.document + Path(fileName)
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
            self.fileInfos.append(ProbeFileInfo(fileURL: self.currentFile.path.url))
            let jsonData = try! JSONEncoder().encode(self.fileInfos)
            try! self.configFilePath.write(jsonData)
            self.currentFile = nil
            completion(true)
        }
    }
}
