//
//  BaseUITableView.swift
//
//
//  Created by Bahdan Piatrouski on 27.12.23.
//

import UIKit

open class BaseUITableView: UITableView {
    private lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 0)))
        view.backgroundColor = .clear
        return view
    }()
    
    public var footerHeight: CGFloat = 0 {
        didSet {
            self.footerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: footerHeight)
        }
    }
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.setupFooter()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupFooter()
    }
    
    private func setupFooter() {
        self.tableFooterView = footerView
    }
}
