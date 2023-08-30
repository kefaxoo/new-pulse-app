//
//  CoversViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

class CoversViewController: BaseUIViewController {
    lazy var firstCoversLine = CoversScrollingView()
    lazy var secondCoversLine = CoversScrollingView()
    lazy var thirdCoversLine = CoversScrollingView()
    lazy var coversLines: [CoversScrollingView] = {
        return [firstCoversLine, secondCoversLine, thirdCoversLine]
    }()
    
    private lazy var provider: CoversProvider = {
        let provider = CoversProvider()
        provider.delegate = self
        return provider
    }()
}

// MARK: -
// MARK: Life cycle
extension CoversViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.coversLines.forEach({ $0.setupTimer() })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.coversLines.forEach({ $0.removeTimer() })
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
// MARK: Provider methods
extension CoversViewController: CoversProviderDelegate {
    func setupCovers(covers: [PulseCover]) {
        guard covers.count >= 30 else { return }
        
        self.firstCoversLine.setupCovers(covers: Array(covers[0..<10]))
        self.secondCoversLine.setupCovers(covers: Array(covers[10..<20]), start: 1)
        self.thirdCoversLine.setupCovers(covers: Array(covers[20..<30]), start: 2)
    }
}
