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
    
    func image(from link: String?, imageClosure: @escaping((UIImage?) -> ()), errorClosure: (() -> ())? = nil) {
        guard let link else {
            errorClosure != nil ? errorClosure?() : imageClosure(UIImage(systemName: Constants.Images.System.exclamationMark))
            return
        }
        
        if let image = self.localImage(from: URL(string: link)) {
            imageClosure(image)
            return
        }
        
        if let image = SDImageCache.shared.imageFromCache(forKey: link) {
            imageClosure(image)
            return
        }
        
        SDWebImageManager.shared.loadImage(with: URL(string: link), progress: nil) { [weak self] image, _, error, _, _, _ in
            if error == nil {
                self?.downloadImage(from: link) { image in
                    guard error == nil else {
                        errorClosure != nil ? errorClosure?() : imageClosure(UIImage(systemName: Constants.Images.System.exclamationMark))
                        return
                    }
                    
                    imageClosure(image)
                }
                
                return
            }
            
            imageClosure(image)
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
            default:
                completion(nil)
                return
        }
        
        var track = track
        if track.image == nil {
            switch track.source {
                case .muffon:
                    MuffonProvider.shared.trackInfo(track) { updatedTrack in
                        track = TrackModel(updatedTrack)
                        self.image(from: track.image?.original) { [weak self] image in
                            self?.saveImage(image, filename: filename, completion: completion)
                        }
                    } failure: {
                        completion(nil)
                    }
                    
                    return
                default:
                    completion(nil)
                    return
            }
        }
        
        self.image(from: track.image?.original) { [weak self] image in
            self?.saveImage(image, filename: filename, completion: completion)
        } errorClosure: {
            completion(nil)
        }
    }
    
    private func saveImage(_ image: UIImage?, filename: String, completion: @escaping((String?) -> ())) {
        guard let image,
              let data = image.pngData(),
              let url = URL(filename: filename, path: .documentDirectory),
              let _ = try? data.write(to: url)
        else {
            completion(nil)
            return
        }
        
        completion(filename)
    }
}
