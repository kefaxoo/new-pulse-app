//
//  URL+Ext.swift
//
//
//  Created by Bahdan Piatrouski on 11.03.24.
//

import Foundation

public extension URL {
    init?(filename: String, path: FileManager.SearchPathDirectory) {
        guard let url = FileManager.default.urls(for: path, in: .userDomainMask).first else { return nil }
        
        if #available(iOS 16.0, tvOS 16.0, *) {
            self = url.appending(path: filename)
        } else {
            self = url.appendingPathComponent(filename)
        }
    }
    
    var isDirectory: Bool {
        return (try? self.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
