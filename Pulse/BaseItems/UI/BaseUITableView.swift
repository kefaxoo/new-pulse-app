//
//  BaseUITableView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import UIKit

final class BaseUITableView: UITableView {
    private lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: NowPlayingView.height))
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.setupFooter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupFooter()
    }
    
    private func setupFooter() {
        self.tableFooterView = footerView
    }
}
