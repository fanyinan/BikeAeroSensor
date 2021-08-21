//
//  Path+Extension.swift
//  Vae
//
//  Created by fanyinan on 2019/6/28.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import PathKit
import Foundation

extension Path {
    
    static var document: Path {
        let documentPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return Path(documentPathString)
    }

    func createFolderIfNeeded() {
        guard !self.exists else { return }
        try? self.mkpath()
    }
    
    func createFileIfNeeded(data: Data?) {
        guard !self.exists else { return }
        FileManager.default.createFile(atPath: self.url.path, contents: data)
    }
    
    var size: UInt64 {
        return try! FileManager.default.attributesOfItem(atPath: url.path)[.size] as! UInt64
    }
    
    var configFile: Path {
        return self + Path("config.json")
    }
}
