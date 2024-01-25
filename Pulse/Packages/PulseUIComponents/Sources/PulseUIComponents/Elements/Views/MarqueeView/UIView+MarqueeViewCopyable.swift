//
//  UIView+MarqueeViewCopyable.swift
//
//
//  Created by Bahdan Piatrouski on 1.01.24.
//

import UIKit

extension UIView: MarqueeViewCopyable {
    @objc func copyMarqueeView() -> UIView? {
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: self)
        let copyView = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? UIView
        return copyView
    }
}
