//
//  Version.swift
//  Vae
//
//  Created by fyn on 2019/8/13.
//  Copyright © 2019 fanyinan. All rights reserved.
//

import Foundation

struct Version: Codable, Comparable {
    
    private(set) var major: Int
    private(set) var minor: Int
    private(set) var revision: Int
    
    static var current: Version {
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let version = Version(string: versionString)!
        return version
    }
    
    var string: String {
        return "\(major).\(minor).\(revision)"
    }
    
    init?(string: String) {
        let versionComponents = string.split(separator: ".").map({ Int($0) })
        guard let major = versionComponents[0], let minor = versionComponents[1], let revision = versionComponents[2] else { return nil }
        self.major = major
        self.minor = minor
        self.revision = revision
    }
    
    init(major: Int, minor: Int, revision: Int) {
        self.major = major
        self.minor = minor
        self.revision = revision
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.revision != rhs.revision { return lhs.revision < rhs.revision }
        return false
    }
}
