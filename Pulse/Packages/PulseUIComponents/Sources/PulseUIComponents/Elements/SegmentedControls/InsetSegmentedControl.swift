//
//  InsetSegmentedControl.swift
//
//
//  Created by Bahdan Piatrouski on 18.11.23.
//

import UIKit

public protocol InsetSegmentedControlDelegate: AnyObject {
    func segmentedControlValueChanged(value: Int)
}

fileprivate extension InsetSegmentedControlDelegate {
    func segmentedControlValueChanged(value: Int) {}
}

open class InsetSegmentedControl: UIView {
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.isHidden = self.isHidden
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    public let insets: UIEdgeInsets
    public var height: CGFloat {
        return 32 + insets.top + insets.bottom
    }
    
    public weak var delegate: InsetSegmentedControlDelegate?
    
    public override var isHidden: Bool {
        didSet {
            self.segmentedControl.isHidden = isHidden
        }
    }
    
    public var selectedSegmentIndex: Int {
        get {
            return self.segmentedControl.selectedSegmentIndex
        }
        set {
            self.segmentedControl.selectedSegmentIndex = newValue
        }
    }
    
    public init(insets: UIEdgeInsets = UIEdgeInsets(all: 0), frame: CGRect = .zero) {
        self.insets = insets
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setupInterface()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface
fileprivate extension InsetSegmentedControl {
    func setupInterface() {
        self.setupLayout()
        self.setupConstraints()
    }
    
    func setupLayout() {
        self.addSubview(segmentedControl)
    }
    
    func setupConstraints() {
        segmentedControl.snp.makeConstraints({ $0.edges.equalToSuperview().inset(insets) })
    }
}

// MARK: -
// MARK: Actions to delegate methods
fileprivate extension InsetSegmentedControl {
    @objc func valueChanged(_ sender: UISegmentedControl) {
        self.delegate?.segmentedControlValueChanged(value: sender.selectedSegmentIndex)
    }
}

// MARK: -
// MARK: Public funcs
public extension InsetSegmentedControl {
    func removeAllSegments() {
        self.segmentedControl.removeAllSegments()
    }
    
    func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) {
        self.segmentedControl.insertSegment(withTitle: title, at: segment, animated: animated)
    }
}
