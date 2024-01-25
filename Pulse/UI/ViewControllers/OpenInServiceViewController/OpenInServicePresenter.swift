//
//  OpenInServicePresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import Foundation
import UIKit

protocol OpenInServiceProtocol: BasePresenter {
    var links: [OdesliLink] { get }
    
    func didSelectItem(at indexPath: IndexPath)
}

final class OpenInServicePresenter {
    private let track: TrackModel
    
    private var root: OdesliRoot?
    
    weak var view: OpenInServiceViewProtocol?
    
    init(track: TrackModel, view: OpenInServiceViewProtocol?) {
        self.track = track
        self.view = view
    }
}

extension OpenInServicePresenter: OpenInServiceProtocol {
    var links: [OdesliLink] {
        return self.root?.services.links ?? []
    }
    
    func viewDidLoad() {
        MainCoordinator.shared.currentViewController?.presentSpinner()
        OdesliProvider.shared.fetchTrackLinks(for: track) { [weak self] odesliRoot in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            self?.root = odesliRoot
            self?.view?.reloadData()
        }
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        let link = self.links[indexPath.row].service.url
        guard let url = URL(string: link),
              UIApplication.shared.canOpenURL(url)
        else { return }
        
        UIApplication.shared.open(url)
    }
}
