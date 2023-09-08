//
//  SearchPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit

protocol SearchPresenterDelegate: AnyObject {
    func setupServiceSegmentedControl(items: [String])
    func setupTypeSegmentedControl(items: [String])
    func reloadData()
}

final class SearchPresenter: BasePresenter {
    private let services = ServiceType.searchController
    private var query = ""
    private var timer: Timer?
    
    private var currentService: ServiceType = .none {
        didSet {
            self.currentSource = currentService.source
        }
    }
    
    private var currentType: SearchType = .none
    private var searchResponse: SearchResponse?
    private var currentSource: SourceType = .none
    
    weak var delegate: SearchPresenterDelegate?
    
    var resultsCount: Int {
        return searchResponse?.results.count ?? 0
    }
    
    func viewDidLoad() {
        self.delegate?.setupServiceSegmentedControl(items: services.map({ $0.title }))
        guard !services.isEmpty else { return }
        
        self.currentService = services[0]
        let searchTypes = SearchType.types(for: services[0])
        self.delegate?.setupTypeSegmentedControl(items: searchTypes.map({ $0.title }))
        
        guard !searchTypes.isEmpty else { return }
        
        self.currentType = searchTypes[0]
    }
    
    func textDidChange(_ text: String) {
        timer?.invalidate()
        
        self.query = text
        timer = Timer(timeInterval: 1, target: self, selector: #selector(search), userInfo: nil, repeats: false)
        timer?.fire()
    }
    
    func serviceDidChange(index: Int) {
        self.currentService = services[index]
        self.textDidChange(self.query)
    }
    
    func typeDidChange(index: Int) {
        self.currentType = SearchType.types(for: self.currentService)[index]
        self.textDidChange(self.query)
    }
    
    @objc private func search() {
        timer?.invalidate()
        
        guard !self.query.isEmpty else {
            MuffonProvider.shared.cancelTask()
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            return
        }
        
        if let isSpinnerPresented = MainCoordinator.shared.currentViewController?.isSpinnerPresented,
           !isSpinnerPresented {
            MainCoordinator.shared.currentViewController?.presentSpinner()
        }
        
        MuffonProvider.shared.search(query: query, in: self.currentService, type: self.currentType) { [weak self] response in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            self?.searchResponse = response
            self?.delegate?.reloadData()
        } failure: {
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            AlertView.shared.present(title: "Error", message: "Unknown Muffon Error", alertType: .error, system: .iOS16AppleMusic)
        }
    }
    
    func setupCell(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: self.currentType.id, for: indexPath), for: indexPath)
    }
    
    private func setupCell(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        guard self.currentType != .none else { return UITableViewCell() }
        
        switch self.currentType {
            case .tracks:
                let track: TrackModel
                switch self.currentSource {
                    case .muffon:
                        guard let muffonTrack = self.searchResponse?.results[indexPath.item] as? MuffonTrack else { return UITableViewCell() }
                        
                        track = TrackModel(muffonTrack)
                    case .none:
                        return UITableViewCell()
                }
                
                (cell as? TrackTableViewCell)?.setupCell(track, isSearchController: true)
                return cell
            default:
                return UITableViewCell()
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        switch self.currentType {
            case .tracks:
                guard let playlist = AudioManager.shared.convertPlaylist(self.searchResponse?.results ?? [], source: self.currentSource),
                      playlist.count == (self.searchResponse?.results.count ?? 0)
                else { return }
                
                let track = playlist[indexPath.item]
                if track.playableLinks.streamingLinkNeedsToRefresh {
                    AudioManager.shared.updatePlayableLink(for: track) { [weak self] updatedTrack in
                        self?.searchResponse?.results[indexPath.item] = updatedTrack.response
                        AudioPlayer.shared.play(from: updatedTrack.track, playlist: playlist, position: indexPath.item)
                    }
                } else {
                    AudioPlayer.shared.play(from: track, playlist: playlist, position: indexPath.item)
                }
            default:
                return
        }
    }
}