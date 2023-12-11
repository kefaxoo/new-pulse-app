//
//  BasePresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

protocol BasePresenter {
    func loadView()
    func viewDidLoad()
    func viewWillAppear()
    func viewDidDisappear()
}

extension BasePresenter {
    func loadView() {}
    func viewDidLoad() {}
    func viewWillAppear() {}
    func viewDidDisappear() {}
}
