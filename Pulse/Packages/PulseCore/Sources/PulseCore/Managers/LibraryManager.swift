//
//  LibraryManager.swift
//
//
//  Created by Bahdan Piatrouski on 11.03.24.
//

import Foundation

public final class LibraryManager {
    public static let shared = LibraryManager()
    
    fileprivate init() {}
    
    public func appStarting() {
        self.removeTemporaryCache()
    }
    
    public func removeTemporaryCache() {
        guard let url = URL(filename: "", path: .cachesDirectory) else { return }
        
        let path: String
        if #available(iOS 16.0, tvOS 16.0, *) {
            path = url.path()
        } else {
            path = url.path
        }
        
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: path) else { return }
        
        items.forEach { [weak self] item in
            guard let url = URL(filename: item, path: .cachesDirectory),
                  !url.isDirectory || item.contains("SDImageCache")
            else { return }
            
            self?.removeFile(atUrl: url)
        }
    }
    
    @discardableResult public func removeFile(atUrl url: URL?) -> Bool {
        guard let url else { return false }
        
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}
