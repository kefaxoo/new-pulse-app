//
//  UIView+MarqueeViewCopyable.swift
//
//
//  Created by Bahdan Piatrouski on 1.01.24.
//

import UIKit

extension UIView: MarqueeViewCopyable {
    @objc func copyMarqueeView() -> UIView? {
        guard let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: archivedData)
    }
}
