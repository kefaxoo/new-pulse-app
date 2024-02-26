//
//  ConstraintMakerEditable+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.02.24.
//

import UIKit
import PulseUIComponents
import SnapKit

extension ConstraintMakerEditable {
    @discardableResult func inset(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> ConstraintMakerEditable {
        return self.inset(UIEdgeInsets(horizontal: horizontal, vertical: vertical))
    }
}
