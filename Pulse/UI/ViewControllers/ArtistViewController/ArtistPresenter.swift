//
//  ArtistPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 27.12.23.
//

import UIKit

protocol ArtistPresenterProtocol: BasePresenter, BaseTableViewPresenter, AnyObject {
    var countOfSections: Int { get }
    var artistName: String { get }
    
    func setView(_ view: ArtistView?)
    func countOfRowsInSection(_ section: Int) -> Int
    func scheme(inSection section: Int) -> ArtistViewScheme
    func getArtist() -> ArtistModel
    func didSelectRow(at indexPath: IndexPath)
    func indexPath(for track: TrackModel) -> IndexPath?
    func setupHeaderView(for section: Int) -> UIView?
}

final class ArtistPresenter {
    private let artist: ArtistModel
    private weak var view: ArtistView?
    
    private var scheme = [ArtistViewScheme]()
    
    private var popularTracks  = [TrackModel]()
    private var similarArtists = [ArtistModel]()
    
    private var currentSectionPlaying = -1
    
    var popularTracksCount: Int {
        return self.popularTracks.count > 6 ? 5 : self.popularTracks.count
    }
    
    var artistName: String {
        return self.artist.name
    }
    
    init(artist: ArtistModel) {
        self.artist = artist
    }
    
    func setView(_ view: ArtistView?) {
        self.view = view
    }
    
    func getArtist() -> ArtistModel {
        return self.artist
    }
    
    private func play(from track: TrackModel, in playlist: [TrackModel], atIndexPath indexPath: IndexPath, isNewPlaylist: Bool) {
        self.currentSectionPlaying = indexPath.section
        AudioPlayer.shared.play(
            from: track,
            playlist: playlist,
            position: indexPath.row,
            isNewPlaylist: isNewPlaylist
        )
    }
    
    func indexPath(for track: TrackModel) -> IndexPath? {
        guard self.currentSectionPlaying > -1 else { return nil }
        
        let scheme = self.scheme[self.currentSectionPlaying]
        switch scheme {
            case .popularTracks:
                guard let index = self.popularTracks.firstIndex(where: { $0.id == track.id }) else { return nil }
                
                return IndexPath(row: index, section: self.currentSectionPlaying)
            default:
                return nil
        }
    }
    
    private func headerDidTap(scheme: ArtistViewScheme) {
        
    }
}

extension ArtistPresenter: ArtistPresenterProtocol {
    var countOfSections: Int {
        return self.scheme.count
    }
    
    func countOfRowsInSection(_ section: Int) -> Int {
        switch self.scheme[section] {
            case .popularTracks:
                return self.popularTracksCount
            default:
                return 0
        }
    }
    
    func scheme(inSection section: Int) -> ArtistViewScheme {
        return self.scheme[section]
    }
    
    func viewDidLoad() {
        switch artist.service {
            case .yandexMusic:
                MainCoordinator.shared.currentViewController?.presentSpinner()
                YandexMusicProvider.shared.fetchArtist(self.artist) { [weak self] ymArtist in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    if let popularTracks = ymArtist.popularTracks {
                        self?.scheme.append(.popularTracks)
                        self?.popularTracks = popularTracks.map({ TrackModel($0) })
                    }
                    
//                    if let similarArtists = ymArtist.similarArtists {
//                        self?.scheme.append(.similarArtists)
//                        self?.similarArtists = similarArtists.map({ ArtistModel($0) })
//                    }
                    
                    self?.scheme.sort(by: { lhs, rhs in
                        return lhs.rawValue > rhs.rawValue
                    })
                    
                    self?.view?.reloadData()
                } failure: {
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    MainCoordinator.shared.popViewController()
                }
            default:
                MainCoordinator.shared.popViewController()
        }
    }
    
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: self.scheme[indexPath.section].cellId), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        switch self.scheme[indexPath.section] {
            case .popularTracks:
                if let cell = cell as? TrackTableViewCell {
                    let track = self.popularTracks[indexPath.row]
                    cell.setupCell(track, state: AudioPlayer.shared.state(for: track))
                }
            default:
                return cell
        }
        
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let scheme = self.scheme[indexPath.section]
        switch scheme {
            case .popularTracks:
                self.play(
                    from: self.popularTracks[indexPath.row],
                    in: self.popularTracks,
                    atIndexPath: indexPath,
                    isNewPlaylist: self.currentSectionPlaying != indexPath.section
                )
            default:
                break
        }
    }
    
    func setupHeaderView(for section: Int) -> UIView? {
        let scheme = self.scheme[section]
        
        switch scheme {
            case .popularTracks:
                return ButtonTableHeaderView().configure(withTitle: "Popular Tracks", buttonText: "More") { [scheme, weak self] in
                    self?.headerDidTap(scheme: scheme)
                }
            default:
                return nil
        }
    }
}
