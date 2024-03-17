//
//  Dynamic.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.03.24.
//

import Foundation

class Dynamic<T> {
    typealias Listener = ((T) -> ())
    
    private var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
}
