//
//  RealmManager.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation
import RealmSwift

public final class RealmManager<T: Object> {
    public typealias RealmUpdateClosure = ((Realm) -> ())
    
    private lazy var realm: Realm = {
        return try! Realm(configuration: SettingsManager.shared.realmConfiguration)
    }()
    
    public func write(object: T) {
        try? realm.write { [weak self] in
            self?.realm.add(object)
        }
    }
    
    public func read() -> [T] {
        return Array(realm.objects(T.self))
    }
    
    public func update(realmBlock: @escaping RealmUpdateClosure) {
        realmBlock(self.realm)
    }
    
    public func delete(object: T) {
        try? realm.write { [weak self] in
            self?.realm.delete(object)
        }
    }
    
    public func deleteAll() {
        self.read().forEach({ self.delete(object: $0) })
    }
}
