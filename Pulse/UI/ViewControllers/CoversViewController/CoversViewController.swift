//
//  CoversViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit
import PulseUIComponents

class CoversViewController: BaseUIViewController {
    lazy var firstCoversLine = CoversScrollingView()
    lazy var secondCoversLine = CoversScrollingView()
    lazy var thirdCoversLine = CoversScrollingView()
    lazy var coversLines: [CoversScrollingView] = {
        return [firstCoversLine, secondCoversLine, thirdCoversLine]
    }()
    
    private lazy var presenter: CoversPresenter = {
        let presenter = CoversPresenter()
        presenter.delegate = self
        return presenter
    }()
}

// MARK: -
// MARK: Life cycle
extension CoversViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
}

// MARK: -
// MARK: Setup interface methods
extension CoversViewController {
    override func setupLayout() {
        self.view.addSubview(firstCoversLine)
        self.view.addSubview(secondCoversLine)
        self.view.addSubview(thirdCoversLine)
    }
    
    override func setupConstraints() {
        firstCoversLine.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        secondCoversLine.snp.makeConstraints { make in
            make.top.equalTo(firstCoversLine.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        thirdCoversLine.snp.makeConstraints { make in
            make.top.equalTo(secondCoversLine.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
    }
}

// MARK: -
// MARK: Presenter methods
extension CoversViewController: CoversPresenterDelegate {
    func setupCovers(covers: [PulseCover]) {
        let coversCount = covers.count / 3
        
        self.firstCoversLine.setupCovers(covers: Array(covers[0..<coversCount]))
        self.secondCoversLine.setupCovers(covers: Array(covers[(coversCount + 1)..<(coversCount * 2)]), start: 1)
        self.thirdCoversLine.setupCovers(covers: Array(covers[(coversCount * 2) + 1..<(coversCount * 3)]), start: 2)
    }
}
