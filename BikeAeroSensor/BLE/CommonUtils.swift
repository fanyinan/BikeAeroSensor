//
//  BLEUtils.swift
//  bletool
//
//  Created by shenyutao on 2022/6/17.
//

import Foundation
#if DEBUG
import os.log
#endif

func debugLog<T>(_ message: T, filePath: String = #file, line: Int = #line, methodName: String = #function) {
    if #available(iOS 12.0, *) {
#if DEBUG
        let fileName = (filePath as NSString).lastPathComponent
        let printMsg = "[\(fileName)] [Line\(line)] [\(methodName)]: \(message)"
        os_log(.debug, "BLE:%{public}s.", printMsg)
#endif
    }
}
