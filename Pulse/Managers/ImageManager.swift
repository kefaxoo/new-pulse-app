//
//  ImageManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit
import SDWebImage

final class ImageManager {
    static let shared = ImageManager()
    
    fileprivate init() {}
    
    func image(from link: String?, imageClosure: @escaping((_ image: UIImage?, _ shouldAnimate: Bool) -> ()), errorClosure: (() -> ())? = nil) {
        guard let link else {
            errorClosure?()
            return
        }
        
        if link.contains("file://"),
           let image = self.localImage(from: URL(string: link)) {
            imageClosure(image, false)
            return
        }
        
        if let image = SDImageCache.shared.imageFromCache(forKey: link) {
            imageClosure(image, false)
            return
        }
        
        SDWebImageManager.shared.loadImage(with: URL(string: link), progress: nil) { image, _, error, cacheType, _, _ in
            guard error == nil else { return }
            
            imageClosure(image, cacheType == .none)
        }
    }
    
    private func localImage(from url: URL?) -> UIImage? {
        guard let url,
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data)
        else { return nil }
        
        return image
    }
    
    private func downloadImage(from link: String, completion: @escaping((UIImage?) -> ())) {
        DownloadManager.shared.downloadImage(from: link, completion: completion)
    }
    
    func saveCover(_ track: TrackModel, completion: @escaping((String?) -> ())) {
        let filename: String
        switch track.service {
            case .soundcloud:
                filename = "Covers/soundcloud-\(track.id).png"
            case .yandexMusic:
                filename = "Covers/yandexMusic-\(track.id).png"
            case .pulse:
                filename = "Covers/pulse-\(track.id).png"
            case .deezer:
                filename = "Covers/deezer-\(track.id).png"
            default:
                completion(nil)
                return
        }
        
        var track = track
        if track.image == nil {
            switch track.source {
                case .muffon:
                    MuffonProvider.shared.trackInfo(track) { [weak self] updatedTrack in
                        track = TrackModel(updatedTrack)
                        self?.image(from: track.image?.original) { image, _ in
                            self?.saveImage(image, filename: filename, completion: completion)
                        }
                    } failure: {
                        completion(nil)
                    }
                    
                    return
                case .soundcloud:
                    SoundcloudProvider.shared.trackInfo(id: track.id) { track in
                        if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.newSoundcloud?.prod ?? false {
                            PulseProvider.shared.soundcloudArtworkV2(link: track.coverLink ?? "") { [weak self] cover in
                                self?.image(from: cover.xl, imageClosure: { image, _ in
                                    self?.saveImage(image, filename: filename, completion: completion)
                                })
                            } failure: { _, _ in
                                completion(nil)
                            }
                        } else {
                            PulseProvider.shared.soundcloudArtwork(exampleLink: track.coverLink ?? "") { [weak self] cover in
                                self?.image(from: cover.xl, imageClosure: { image, _ in
                                    self?.saveImage(image, filename: filename, completion: completion)
                                })
                            } failure: { _ in
                                completion(nil)
                            }
                        }
                    } failure: { _ in
                        completion(nil)
                    }
                case .yandexMusic:
                    YandexMusicProvider.shared.trackInfo(id: track.id) { [weak self] track in
                        self?.image(from: track.coverLink(for: .xl)) { image, _ in
                            self?.saveImage(image, filename: filename, completion: completion)
                        } errorClosure: {
                            completion(nil)
                        }
                    }
                case .pulse:
                    PulseProvider.shared.exclusiveTrackInfo(track) { [weak self] track in
                        self?.image(from: track.album?.coverLink, imageClosure: { image, _ in
                            self?.saveImage(image, filename: filename, completion: completion)
                        }, errorClosure: {
                            completion(nil)
                        })
                    }
                default:
                    completion(nil)
                    return
            }
        }
        
        self.image(from: track.image?.original) { [weak self] image, _ in
            self?.saveImage(image, filename: filename, completion: completion)
        } errorClosure: {
            completion(nil)
        }
    }
    
    private func saveImage(_ image: UIImage?, filename: String, completion: @escaping((String?) -> ())) {
        guard let image,
              let data = image.pngData(),
              let url = URL(filename: filename, path: .documentDirectory),
              (try? data.write(to: url)) != nil
        else {
            completion(nil)
            return
        }
        
        completion(filename)
    }
}
