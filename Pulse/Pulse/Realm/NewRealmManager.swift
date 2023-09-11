//
//  NewRealmManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 12.09.23.
//

import Foundation
import RealmSwift

final class NewRealmManager {
    private let realm: Realm
    private let queue: DispatchQueue
    
    static let shared = NewRealmManager()
    
    fileprivate init() {
        if let queueLabel = Bundle.main.bundleIdentifier {
            queue = DispatchQueue(label: queueLabel + ".realm", qos: .background)
        } else {
            queue = DispatchQueue.global(qos: .background)
        }
        
        self.realm = try! Realm(configuration: SettingsManager.shared.realmConfiguration)
    }
    
    func add<T: Object>(_ object: T) {
        queue.async { [weak self] in
            try? self?.realm.write { [weak self] in
                self?.realm.add(object)
            }
        }
    }
    
    func get<T: Object>(for: T.Type, completion: @escaping(([T]?) -> ())) where T: Object {
        queue.async { [weak self] in
            guard let results = self?.realm.objects(T.self) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completion(Array(results))
            }
        }
    }
    
    func update<T: Object>(_ object: T, updateBlock: @escaping(() -> ())) {
        queue.async { [weak self] in
            try? self?.realm.write({ updateBlock() })
        }
    }
    
    func delete<T: Object>(_ object: T) {
        queue.async { [weak self] in
            self?.realm.delete(object)
        }
    }
}
