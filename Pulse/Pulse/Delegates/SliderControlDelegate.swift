//
//  SliderControlDelegate.swift
//  Pulse
//
//  Created by ios on 19.09.23.
//

import UIKit
import SliderControl

protocol SliderControlDelegate: AnyObject {
    func valueStartedChange(_ value: Float)
    func valueDidChange(_ value: Float)
}

extension SliderControlDelegate {
    func valueStartedChange(_ value: Float) {}
    func valueDidChange(_ value: Float) {}
}
