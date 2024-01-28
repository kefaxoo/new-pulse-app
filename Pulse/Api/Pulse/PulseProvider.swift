//
//  PulseProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation
import FriendlyURLSession

final class PulseProvider: BaseRestApiProvider {
    static let shared = PulseProvider()
    
    override init(shouldPrintLog: Bool = false, shouldCancelTask: Bool = false) {
        super.init(shouldPrintLog: Constants.isDebug, shouldCancelTask: shouldCancelTask)
    }
    
    func createUser(credentials: Credentials, success: @escaping((PulseCreateUser) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.createUser(credentials: credentials),
                decodeToHttp: true, 
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let createUser = response.data?.map(to: PulseCreateUser.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(createUser)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func loginUser(
        credentials: Credentials,
        success: @escaping((PulseLoginUser) -> ()),
        failure: @escaping PulseDefaultErrorClosure,
        verifyClosure: @escaping((PulseLoginWithCode) -> ())
    ) {
        self.urlSession.dataTask(with: URLRequest(
            type: PulseApi.loginUser(credentials: credentials),
            decodeToHttp: true,
            shouldPrintLog: self.shouldPrintLog
        )) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let loginUser = response.data?.map(to: PulseLoginUser.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(loginUser)
                case .failure(let response):
                    guard response.statusCode == 425,
                          let verifyError = response.data?.map(to: PulseLoginWithCode.self)
                    else {
                        self?.parseError(response: response, closure: failure)
                        return
                    }
                    
                    verifyClosure(verifyError)
            }
        }
    }
    
    func resetPassword(credentials: Credentials, success: @escaping((PulseVerificationCode) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.resetPassword(credentials: credentials),
                decodeToHttp: true,
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let verificationCode = response.data?.map(to: PulseVerificationCode.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(verificationCode)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func accessToken(success: @escaping((PulseLoginUser) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.accessToken,
                decodeToHttp: true,
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let loginUser = response.data?.map(to: PulseLoginUser.self) else {
                        failure(nil)
                        return
                    }
                    
                    success(loginUser)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func getTopCovers(success: @escaping(([PulseCover]) -> ()), failure: EmptyClosure? = nil) {
        self.urlSession.dataTask(
            with: URLRequest(type: PulseApi.topCovers(country: NetworkManager.shared.countryCode), shouldPrintLog: self.shouldPrintLog)
        ) { response in
            switch response {
                case .success(let response):
                    guard let covers = response.data?.map(to: [PulseCoverInfo].self) else {
                        failure?()
                        return
                    }
                    
                    success(covers.map({ $0.cover }))
                case .failure(let response):
                    response.sendLog()
                    failure?()
                    return
            }
        }
    }
    
    func sendLog(_ model: LogModel, success: ((PulseSuccess) -> ())? = nil, failure: PulseDefaultErrorClosure? = nil) {
        urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.log(
                    log: model.getFullLog
                ),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let model = response.data?.map(to: PulseSuccess.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success?(model)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func syncTrack(
        _ track: TrackModel,
        success: ((PulseSuccess) -> ())? = nil,
        failure: PulseDefaultErrorClosure? = nil,
        trackInLibraryClosure: (() -> ())? = nil
    ) {
        urlSession.dataTask(with: URLRequest(type: PulseApi.syncTrack(track), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let successModel = response.data?.map(to: PulseSuccess.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success?(successModel)
                case .failure(let response):
                    if response.statusCode == 409 {
                        trackInLibraryClosure?()
                        return
                    }
                    
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func fetchTracks(success: @escaping(([PulseTrack]) -> ()), failure: PulseDefaultErrorClosure? = nil) {
        urlSession.dataTask(with: URLRequest(type: PulseApi.fetchTracks, shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let results = response.data?.map(to: PulseResults<PulseTrack>.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success(results.results)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func removeTrack(_ track: TrackModel, success: ((PulseSuccess) -> ())? = nil, failure: PulseDefaultErrorClosure? = nil) {
        urlSession.dataTask(with: URLRequest(type: PulseApi.removeTrack(track), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let result = response.data?.map(to: PulseSuccess.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success?(result)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func soundcloudArtwork(exampleLink link: String, success: @escaping((PulseCover) -> ()), failure: PulseDefaultErrorClosure? = nil) {
        urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.soundcloudArtwork(link: link),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let cover = response.data?.map(to: PulseCover.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success(cover)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func soundcloudPlaylistArtwork(for playlist: PlaylistModel, success: @escaping((PulseCover) -> ()), failure: PulseDefaultErrorClosure? = nil) {
        urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.soundcloudPlaylistArtwork(id: playlist.id),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let cover = response.data?.map(to: PulseCover.self) else {
                        failure?(nil)
                        return
                    }
                    
                    success(cover)
                case .failure(let response):
                    if response.statusCode == 401 {
                        SoundcloudProvider.shared.refreshToken { tokens in
                            SettingsManager.shared.soundcloud.updateTokens(tokens)
                            self?.soundcloudPlaylistArtwork(for: playlist, success: success, failure: failure)
                        } failure: { _ in
                            self?.parseError(response: response, closure: failure)
                        }
                        
                        return
                    }
                    
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func features(completion: @escaping((PulseFeatures?) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.features, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    completion(response.data?.map(to: PulseFeatures.self))
                case .failure:
                    completion(nil)
            }
        }
    }
    
    func mainScreen(success: @escaping((PulseWidgets) -> ()), failure: @escaping PulseDefaultErrorV3Closure) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.mainScreen, shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let widgets = response.data?.map(to: PulseWidgetsRoot.self) else {
                        failure(nil, nil)
                        return
                    }
                    
                    success(widgets.widgets)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func exclusiveTracks(
        offset: Int = 0,
        success: @escaping((PulseWidget<PulseExclusiveTrack>) -> ()),
        failure: @escaping PulseDefaultErrorV3Closure
    ) {
        self.urlSession.dataTask(
            with: URLRequest(type: PulseApi.exclusiveTracks(offset: offset), shouldPrintLog: self.shouldPrintLog)
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let widget = response.data?.map(to: PulseWidgetRoot<PulseExclusiveTrack>.self) else {
                        failure(nil, nil)
                        return
                    }
                    
                    success(widget.widget)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func spotifyCanvas(track: TrackModel, success: @escaping((PulseSpotifyCanvas) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.spotifyCanvas(track: track), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let response = response.data?.map(to: PulseSpotifyCanvas.self) else { return }
                    
                    success(response)
                case .failure:
                    break
            }
        }
    }
    
    func pulseCanvas(track: TrackModel, success: @escaping((PulseCanvas) -> ()), failure: @escaping(() -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.pulseCanvas(track: track), shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let response = response.data?.map(to: PulseCanvas.self) else {
                        failure()
                        return
                    }
                    
                    success(response)
                case .failure:
                    failure()
            }
        }
    }
    
    func exclusiveTrackInfo(_ track: TrackModel, success: @escaping((PulseExclusiveTrack) -> ()), failure: PulseDefaultErrorV3Closure? = nil) {
        self.exclusiveTrackInfo(byId: track.id, success: success, failure: failure)
    }
    
    func exclusiveTrackInfo(byId id: String, success: @escaping((PulseExclusiveTrack) -> ()), failure: PulseDefaultErrorV3Closure? = nil) {
        self.urlSession.dataTask(
            with: URLRequest(type: PulseApi.exclusiveTrack(trackId: id), shouldPrintLog: self.shouldPrintLog)
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let response = response.data?.map(to: PulseExclusiveTrackInfo.self) else {
                        failure?(nil, nil)
                        return
                    }
                    
                    success(response.exclusiveTrack)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func markStoryAsWatched(storyId: Int) {
        self.urlSession.dataTask(
            with: URLRequest(type: PulseApi.markStoryAsWatched(storyId: storyId), shouldPrintLog: self.shouldPrintLog),
            response: { _ in }
        )
    }
    
    func fetchSettings() {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.fetchSettings, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let response = response.data?.map(to: PulseSettingsRoot.self) else { return }
                    
                    let settings = response.settings
                    SettingsManager.shared.autoDownload = settings.autoDownload
                    SettingsManager.shared.isCanvasesEnabled = settings.isCanvasEnabled
                    SettingsManager.shared.color = settings.color
                    SettingsManager.shared.soundcloudLike = settings.soundcloud.like
                    SettingsManager.shared.soundcloud.currentSource = settings.soundcloud.source.soundcloudService
                    SettingsManager.shared.yandexMusicLike = settings.yandexMusic.like
                    SettingsManager.shared.yandexMusic.currentSource = settings.yandexMusic.source.yandexMusicService
                    if let quality = settings.yandexMusic.quality,
                       let streaming = YandexMusicModel.Quality(rawValue: quality.streaming),
                       let download = YandexMusicModel.Quality(rawValue: quality.download) {
                        SettingsManager.shared.yandexMusic.streamingQuality = streaming
                        SettingsManager.shared.yandexMusic.downloadQuality = download
                    }
                    
                    NotificationCenter.default.post(name: .reloadSettings, object: nil)
                case .failure:
                    break
            }
        }
    }
    
    func updateSettings() {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.updateSettings, shouldPrintLog: self.shouldPrintLog), response: { _ in })
    }
    
    func isUserBlocked(completion: @escaping((_ isUserBlocked: Bool) -> ())) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.isUserBlocked, shouldPrintLog: self.shouldPrintLog)) { response in
            switch response {
                case .success(let response):
                    guard let isBlocked = response.data?.map(to: PulseIsBlocked.self) else {
                        completion(false)
                        return
                    }
                    
                    completion(isBlocked.isBlocked)
                case .failure:
                    completion(false)
            }
        }
    }
    
    func exclusivePlaylist(id: Int, offset: Int = 0, success: @escaping((PulsePlaylist) -> ()), failure: @escaping PulseDefaultErrorV3Closure) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.exclusivePlaylist(playlistId: id, offset: offset),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let playlist = response.data?.map(to: PulsePlaylistRoot.self) else {
                        failure(nil, nil)
                        return
                    }
                    
                    success(playlist.playlist)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func cancelTask() {
        task?.cancel()
    }
}

fileprivate extension PulseProvider {
    func parseError(response: Failure, closure: PulseDefaultErrorClosure?) {
        response.sendLog()
        if let error = response.error {
            closure?(PulseError(errorDescription: error.localizedDescription))
        } else if let error = response.data?.map(to: PulseError.self) {
            closure?(error)
        } else {
            closure?(nil)
        }
    }
}

// MARK: -
// MARK: Library V2, Soundcloud V2, Sign V3
extension PulseProvider {
    func createUserV3(
        credentials: Credentials,
        signMethod: SignMethodType,
        success: @escaping((_ createUser: PulseCreateUserV3) -> ()),
        failure: @escaping PulseDefaultErrorV3Closure
    ) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.createUserV3(credentials: credentials, signMethod: signMethod),
                decodeToHttp: true,
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let createUser = response.data?.map(to: PulseCreateUserV3.self) else {
                        failure(nil, nil)
                        return
                    }
                    
                    success(createUser)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func externalSign(
        email: String, 
        signMethod: SignMethodType, 
        signInClosure: @escaping((PulseLoginUserV3) -> ()),
        signUpClosure: @escaping((PulseCreateUserV3) -> ()),
        verifyClosure: @escaping((PulseVerifyUserV3) -> ()),
        failure: @escaping PulseDefaultErrorV3Closure
    ) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.externalSign(email: email, signMethod: signMethod), 
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    if response.statusCode == 200 {
                        guard let loginUser = response.data?.map(to: PulseLoginUserV3.self) else {
                            failure(nil, nil)
                            return
                        }
                        
                        signInClosure(loginUser)
                    } else {
                        guard let createUser = response.data?.map(to: PulseCreateUserV3.self) else {
                            failure(nil, nil)
                            return
                        }
                        
                        signUpClosure(createUser)
                    }
                case .failure(let response):
                    guard response.statusCode == 425,
                          let verifyUser = response.data?.map(to: PulseVerifyUserV3.self)
                    else {
                        self?.parseError(response: response, closure: failure)
                        return
                    }
                    
                    verifyClosure(verifyUser)
            }
        }
    }
    
    func loginUserV3(
        credentials: Credentials,
        signMethod: SignMethodType,
        success: @escaping((PulseLoginUserV3) -> ()),
        failure: @escaping PulseDefaultErrorV3Closure,
        verifyClosure: @escaping((PulseVerifyUserV3) -> ())
    ) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.loginUserV3(credentials: credentials, signMethod: signMethod),
                decodeToHttp: true,
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let loginUser = response.data?.map(to: PulseLoginUserV3.self) else {
                        failure(nil, nil)
                        return
                    }
                    
                    success(loginUser)
                case .failure(let response):
                    guard response.statusCode == 425,
                          let verifyUser = response.data?.map(to: PulseVerifyUserV3.self)
                    else {
                        self?.parseError(response: response, closure: failure)
                        return
                    }
                    
                    verifyClosure(verifyUser)
            }
        }
    }
    
    func resetPasswordV3(credentials: Credentials, success: @escaping((PulseResetPasswordV3) -> ()), failure: @escaping PulseDefaultErrorV3Closure) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.resetPasswordV3(credentials: credentials),
                decodeToHttp: true,
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let resetPassword = response.data?.map(to: PulseResetPasswordV3.self) else {
                        failure(nil, nil)
                        return
                    }
                    
                    success(resetPassword)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func accessTokenV3(success: @escaping((PulseLoginUserV3) -> ()), failure: PulseDefaultErrorV3Closure? = nil) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.accessTokenV3, shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let accessToken = response.data?.map(to: PulseLoginUserV3.self) else {
                        failure?(nil, nil)
                        return
                    }
                    
                    success(accessToken)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure)
            }
        }
    }
    
    func syncTracks() {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.syncTracks, shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let tracks = response.data?.map(to: PulseAddTracksModels.self) else { return }
                    
                    tracks.toAdd.forEach { track in
                        switch track.source {
                            case .muffon:
                                MuffonProvider.shared.trackInfo(id: track.id, service: track.service, shouldCancelTask: false) { muffonTrack in
                                    let appTrackObj = TrackModel(muffonTrack)
                                    appTrackObj.dateAdded = track.dateAdded
                                    DispatchQueue.main.async {
                                        guard !LibraryManager.shared.isTrackInLibrary(appTrackObj) else { return }
                                        
                                        RealmManager<LibraryTrackModel>().write(object: LibraryTrackModel(appTrackObj))
                                    }
                                }
                            case .soundcloud:
                                guard SettingsManager.shared.soundcloud.isSigned else { return }
                                
                                SoundcloudProvider.shared.trackInfo(id: track.id) { soundcloudTrack in
                                    let appTrackObj = TrackModel(soundcloudTrack)
                                    appTrackObj.dateAdded = track.dateAdded
                                    DispatchQueue.main.async {
                                        guard !LibraryManager.shared.isTrackInLibrary(appTrackObj) else { return }
                                        
                                        RealmManager<LibraryTrackModel>().write(object: LibraryTrackModel(appTrackObj))
                                    }
                                }
                            default:
                                break
                        }
                    }
                case .failure(let response):
                    guard response.statusCode == 401 else { return }
                    
                    self?.refreshTokens {
                        self?.syncTracks()
                    }
            }
        }
    }
    
    func likeTrack(_ track: TrackModel) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.likeTrack(track), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success:
                    break
                case .failure(let response):
                    guard response.statusCode == 401 else { return }
                    
                    self?.refreshTokens {
                        self?.likeTrack(track)
                    }
            }
        }
    }
    
    func dislikeTrack(_ track: TrackModel) {
        self.urlSession.dataTask(with: URLRequest(type: PulseApi.dislikeTrack(track), shouldPrintLog: self.shouldPrintLog)) { [weak self] response in
            switch response {
                case .success:
                    break
                case .failure(let response):
                    guard response.statusCode == 401 else { return }
                    
                    self?.refreshTokens {
                        self?.dislikeTrack(track)
                    }
            }
        }
    }
    
    func incrementCountListen(for track: TrackModel) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.incrementListenCount(track),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success:
                    break
                case .failure(let response):
                    guard response.statusCode == 401 else { return }
                    
                    self?.refreshTokens {
                        self?.incrementCountListen(for: track)
                    }
            }
        }
    }
    
    func fetchDislikedTracks(
        offset: Int = 0,
        success: @escaping(([PulseServerTrack], _ canLoadMore: Bool) -> ()),
        failure: @escaping PulseDefaultErrorV3Closure
    ) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.fetchDislikedTracks(offset: offset),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let content = response.data?.map(to: PulsebaseContentModel<PulseServerTrack>.self) else {
                        failure(nil, nil)
                        return
                    }
                    
                    success(content.content, content.nextPage != nil)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, retryClosure: {
                        self?.fetchDislikedTracks(offset: offset, success: success, failure: failure)
                    })
            }
        }
    }
    
    func soundcloudPlaylistArtworkV2(
        for playlist: PlaylistModel,
        success: @escaping((PulseCover) -> Void),
        failure: PulseDefaultErrorV3Closure? = nil
    ) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.soundcloudPlaylistArtworkV2(id: playlist.id),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let images = response.data?.map(to: PulseImagesModel.self) else {
                        failure?(nil, nil)
                        return
                    }
                    
                    success(images.images)
                case .failure(let response):
                    if response.statusCode == 401 {
                        guard let error = response.data?.map(to: PulseBaseErrorModel.self) else {
                            self?.parseError(response: response, closure: failure)
                            return
                        }
                        
                        if error.localizationKey.contains("soundcloud") {
                            SoundcloudProvider.shared.refreshToken { tokens in
                                SettingsManager.shared.soundcloud.updateTokens(tokens)
                                self?.soundcloudPlaylistArtworkV2(for: playlist, success: success, failure: failure)
                            }
                        } else {
                            self?.accessTokenV3(success: { loginUser in
                                SettingsManager.shared.pulse.updateTokens(loginUser.tokens)
                                self?.soundcloudPlaylistArtworkV2(for: playlist, success: success, failure: failure)
                            }, failure: { _, _ in })
                        }
                    } else {
                        self?.parseError(response: response, closure: failure)
                    }
            }
        }
    }
    
    func soundcloudArtworkV2(link: String, success: @escaping((PulseCover) -> Void), failure: PulseDefaultErrorV3Closure? = nil) {
        self.urlSession.dataTask(
            with: URLRequest(
                type: PulseApi.soundcloudArtworkV2(link: link),
                shouldPrintLog: self.shouldPrintLog
            )
        ) { [weak self] response in
            switch response {
                case .success(let response):
                    guard let images = response.data?.map(to: PulseImagesModel.self) else {
                        failure?(nil, nil)
                        return
                    }
                    
                    success(images.images)
                case .failure(let response):
                    self?.parseError(response: response, closure: failure, retryClosure: {
                        self?.soundcloudArtworkV2(link: link, success: success, failure: failure)
                    })
            }
        }
    }
}

fileprivate extension PulseProvider {
    func parseError(response: Failure, closure: PulseDefaultErrorV3Closure?, retryClosure: (() -> ())? = nil) {
        response.sendLog()
        if response.statusCode == 401 {
            self.accessTokenV3 { loginUser in
                SettingsManager.shared.pulse.updateTokens(loginUser.tokens)
                retryClosure?()
            }
        } else if let error = response.data?.map(to: PulseBaseErrorModel.self) {
            closure?(error, nil)
        } else if let error = response.error {
            closure?(nil, error)
        } else {
            closure?(nil, nil)
        }
    }
    
    func refreshTokens(completion: @escaping(() -> ())) {
        self.accessTokenV3 { loginUser in
            SettingsManager.shared.pulse.updateTokens(loginUser.tokens)
            completion()
        }
    }
}
