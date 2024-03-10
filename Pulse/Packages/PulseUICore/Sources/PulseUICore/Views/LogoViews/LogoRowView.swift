//
//  LogoRowView.swift
//
//
//  Created by Bahdan Piatrouski on 8.03.24.
//

import UIKit

class LogoRowView: UIView {
    enum Row: CaseIterable {
        case first
        case second
        case third
        case fourth
        case fifth
        case sixth
        case seventh
        
        var color: UIColor? {
            return switch self {
                case .first:
                    UIColor(hex: "#FF4770")
                case .second:
                    UIColor(hex: "#FF6AAD")
                case .third:
                    UIColor(hex: "#FBD177")
                case .fourth:
                    UIColor(hex: "#FBCC68")
                case .fifth:
                    UIColor(hex: "#ACDE8E")
                case .sixth:
                    UIColor(hex: "#7FCC56")
                case .seventh:
                    UIColor(hex: "#5ABD26")
            }
        }
    }
    
    init(numberOfRow: Row) {
        super.init(frame: .zero)
        self.backgroundColor = numberOfRow.color
        self.layer.cornerRadius = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
