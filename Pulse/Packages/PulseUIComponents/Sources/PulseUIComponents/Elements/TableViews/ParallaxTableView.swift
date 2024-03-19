//
//  ParallaxTableView.swift
//
//
//  Created by Bahdan Piatrouski on 27.12.23.
//

import UIKit
import SnapKit

open class ParallaxTableView: BaseUIView {
    private lazy var tableView: BaseUITableView = {
        let tableView = BaseUITableView()
        tableView.delegate = self
        tableView.dataSource = self.dataSource
        return tableView
    }()
    
    public var tableHeaderView: UIView? {
        didSet {
            self.setupInterface()
        }
    }
    
    public var tableFooterHeight: CGFloat {
        get {
            return self.tableView.footerHeight
        }
        set {
            self.tableView.footerHeight = newValue
        }
    }
    
    public var sectionHeaderHeight: CGFloat {
        get {
            return self.tableView.sectionHeaderHeight
        }
        set {
            self.tableView.sectionHeaderHeight = newValue
        }
    }
    
    public var estimatedSectionHeaderHeight: CGFloat {
        get {
            return self.tableView.estimatedSectionHeaderHeight
        }
        set {
            self.tableView.estimatedSectionHeaderHeight = newValue
        }
    }
    
    let topOffset: CGFloat = UIScreen.main.bounds.width + (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
    
    public weak var delegate: UITableViewDelegate?
    public weak var dataSource: UITableViewDataSource? {
        didSet {
            self.tableView.dataSource = dataSource
        }
    }
    
    private func animateHeaderIfNeeded() {
        guard self.tableHeaderView?.frame.height ?? 0 > self.topOffset else { return }
        
        self.tableHeaderView?.snp.updateConstraints({ $0.height.equalTo(topOffset) })
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    public func reloadData() {
        self.tableView.reloadData()
    }
    
    public func register(cells: AnyClass...) {
        cells.forEach({ tableView.register($0) })
    }
    
    public func register(headerFooterViews: AnyClass...) {
        headerFooterViews.forEach({ tableView.register(headerFooterViews: $0) })
    }
}

// MARK: -
// MARK: Setup interface methods
extension ParallaxTableView {
    open override func setupInterface() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        super.setupInterface()
    }
    
    open override func setupLayout() {
        if let tableHeaderView {
            self.addSubview(tableHeaderView)
        }
        
        self.addSubview(tableView)
    }
    
    open override func setupConstraints() {
        if let tableHeaderView {
            tableHeaderView.snp.makeConstraints { make in
                make.height.equalTo(self.topOffset)
                make.top.leading.trailing.equalToSuperview()
                    .inset(UIEdgeInsets(top: -(UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)))
            }
            
            tableView.snp.makeConstraints { make in
                make.top.equalTo(tableHeaderView.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            self.tableView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        }
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension ParallaxTableView: UITableViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            self.tableHeaderView?.snp.updateConstraints({
                $0.height.equalTo((self.tableHeaderView?.frame.height ?? 0) + abs(scrollView.contentOffset.y))
            })
        }
        
        self.delegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.animateHeaderIfNeeded()
        
        self.delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.animateHeaderIfNeeded()
        
        self.delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
}
