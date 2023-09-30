//
//  PaddingLabel.swift
//
//
//  Created by Bahdan Piatrouski on 24.09.23.
//

import UIKit

public class PaddingLabel: UILabel {
    public var insets: UIEdgeInsets = .zero
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.insets))
    }
    
    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + self.insets.left + self.insets.right, height: size.height + self.insets.top + self.insets.bottom)
    }
    
    public override var bounds: CGRect {
        didSet {
            self.preferredMaxLayoutWidth = self.bounds.width - (self.insets.left + self.insets.right)
        }
    }
}
 
