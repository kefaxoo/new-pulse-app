//
//  MainFeedPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 3.01.24.
//

import UIKit

protocol MainFeedProtocol: BasePresenter, BaseTableViewPresenter, AnyObject {
    var countOfSections: Int { get }
    
    func countOfRows(in section: Int) -> Int
    func setView(_ view: MainFeedView?)
    func indexPath(for track: TrackModel) -> IndexPath?
    func fetchData()
    func scheme(for section: Int) -> PulseWidgetsScheme?
    func widget(for scheme: PulseWidgetsScheme) -> Any?
}

final class MainFeedPresenter {
    private var widgets: PulseWidgets?
    private var currentSectionPlaying = -1
    
    weak var view: MainFeedView?
    
    private func play(from track: TrackModel, in playlist: [TrackModel], atIndexPath indexPath: IndexPath, isNewPlaylist: Bool) {
        currentSectionPlaying = indexPath.section
        AudioPlayer.shared.play(from: track, playlist: playlist, position: indexPath.row, isNewPlaylist: isNewPlaylist)
    }
}

// MARK: -
// MARK: MainFeedProtocol
extension MainFeedPresenter: MainFeedProtocol {
    var countOfSections: Int {
        return self.widgets?.scheme.count ?? 0
    }
    
    func countOfRows(in section: Int) -> Int {
        switch self.widgets?.scheme[section] {
            case .exclusiveSongs:
                return self.widgets?.exclusiveTracks?.content.count ?? 0
            case .stories:
                return self.widgets?.scheme != nil ? 1 : 0
            case .categories:
                return self.widgets?.categories != nil ? 1 : 0
            default:
                return 0
        }
    }
    
    func setView(_ view: MainFeedView?) {
        self.view = view
    }
    
    func indexPath(for track: TrackModel) -> IndexPath? {
        guard self.currentSectionPlaying > -1,
              let scheme = self.widgets?.scheme[self.currentSectionPlaying]
        else { return nil }
        
        switch scheme {
            case .exclusiveSongs:
                guard let index = self.widgets?.exclusiveTracks?.content.firstIndex(where: { $0.id == Int(track.id) }) else { return nil }
                
                return IndexPath(row: index, section: self.currentSectionPlaying)
            default:
                return nil
        }
    }
    
    func fetchData() {
        PulseProvider.shared.mainScreen { [weak self] widgets in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            self?.widgets = widgets
            self?.view?.reloadData()
        } failure: { serverError, internalError in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            AlertView.shared.presentError(
                error: LocalizationManager.shared.localizeError(
                    server: serverError,
                    internal: internalError,
                    default: Localization.Lines.unknownError.localization(
                        with: "Pulse"
                    )
                ),
                system: .iOS16AppleMusic
            )
        }
    }
    
    func scheme(for section: Int) -> PulseWidgetsScheme? {
        guard section < self.widgets?.scheme.count ?? -1 else { return nil }
        
        return self.widgets?.scheme[section]
    }
    
    func widget(for scheme: PulseWidgetsScheme) -> Any? {
        switch scheme {
            case .exclusiveSongs:
                return self.widgets?.exclusiveTracks
            case .categories:
                return self.widgets?.categories
            default:
                return nil
        }
    }
}

// MARK: -
// MARK: BasePresenter
extension MainFeedPresenter {
    func viewDidLoad() {
        MainCoordinator.shared.currentViewController?.presentSpinner()
        self.fetchData()
    }
}

// MARK: -
// MARK: BaseTableViewPresenter
extension MainFeedPresenter {
    func setupCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let scheme = self.widgets?.scheme[indexPath.section] else { return UITableViewCell() }
        
        return self.setupCell(tableView.dequeueReusableCell(withIdentifier: scheme.cellId, for: indexPath), at: indexPath)
    }
    
    func setupCell(_ cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
        guard let scheme = self.widgets?.scheme[indexPath.section] else { return cell }
        
        switch scheme {
            case .exclusiveSongs:
                guard let pulseTrack = self.widgets?.exclusiveTracks?.content[indexPath.row] else { return cell }
                
                let track = TrackModel(pulseTrack)
                (cell as? TrackTableViewCell)?.setupCell(track, state: AudioPlayer.shared.state(for: track))
            case .stories:
                guard let stories = self.widgets?.stories else { return cell }
                
                (cell as? StoriesTableViewCell)?.configure(withStories: stories.content, completion: { [weak self] indexPath in
                    self?.widgets?.stories?.content[indexPath.item].didUserWatch = true
                    self?.widgets?.stories?.content = self?.widgets?.stories?.content.sorted(by: { lhs, rhs in
                        return lhs.id < rhs.id
                    }) ?? []
                    
                    self?.widgets?.stories?.content = self?.widgets?.stories?.content.sorted(by: { lhs, rhs in
                        guard lhs.didUserWatch != rhs.didUserWatch else { return false }
                        
                        return !lhs.didUserWatch && rhs.didUserWatch
                    }) ?? []
                    
                    guard let section = self?.widgets?.scheme.firstIndex(of: .stories) else { return }
                    
                    self?.view?.reloadSection(section)
                })
            case .categories:
                guard let playlists = self.widgets?.categories else { return cell }
                
                (cell as? PlaylistsCollectionTableViewCell)?.configure(withPlaylists: playlists.content)
            default:
                break
        }
        
        return cell
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard let scheme = self.widgets?.scheme[indexPath.section] else { return }
        
        switch scheme {
            case .exclusiveSongs:
                guard let playlist = AudioManager.shared.convertPlaylist(self.widgets?.exclusiveTracks?.content ?? [], source: .pulse) else { return }
                
                let track = playlist[indexPath.row]
                self.play(from: track, in: playlist, atIndexPath: indexPath, isNewPlaylist: self.currentSectionPlaying != indexPath.section)
            default:
                break
        }
    }
}
