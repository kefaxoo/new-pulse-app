//
//  URL+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 9.09.23.
//

import Foundation

extension URL {
    init?(filename: String, path: FileManager.SearchPathDirectory) {
        let url = FileManager.default.urls(for: path, in: .userDomainMask).first
        guard let url else { return nil }
        
        if #available(iOS 16.0, *) {
            self = url.appending(path: filename)
        } else {
            self = url.appendingPathComponent(filename)
        }
    }
    
    var isDirectory: Bool {
        return (try? self.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
