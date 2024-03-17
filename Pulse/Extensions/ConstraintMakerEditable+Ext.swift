//
//  ConstraintMakerEditable+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.03.24.
//

import UIKit
import SnapKit

extension ConstraintMakerEditable {
    @discardableResult func inset(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> ConstraintMakerEditable {
        return self.inset(UIEdgeInsets(horizontal: horizontal, vertical: vertical))
    }
}
