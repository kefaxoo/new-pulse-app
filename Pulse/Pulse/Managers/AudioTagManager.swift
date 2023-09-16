//
//  AudioTagManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 16.09.23.
//

import AVFoundation
import OutcastID3

final class AudioTagManager {
    static let shared = AudioTagManager()
    
    fileprivate init() {}
    
    func saveTag(from track: TrackModel, to url: URL?, completion: @escaping(() -> ())) {
        guard let url else {
            completion()
            return
        }
        
        ImageManager.shared.image(from: track.image?.original) { image in
            var frames: [OutcastID3TagFrame] = [
                OutcastID3.Frame.StringFrame(type: .title, encoding: .utf8, str: track.title),
                OutcastID3.Frame.StringFrame(type: .leadArtist, encoding: .utf8, str: track.artistText)
            ]
            
            if let data = image?.pngData(),
               let image = OutcastID3.Frame.PictureFrame.Picture.PictureImage(data: data) {
                frames.append(
                    OutcastID3.Frame.PictureFrame(
                        encoding: .utf8,
                        mimeType: "image/png",
                        pictureType: .coverFront,
                        pictureDescription: "",
                        picture: OutcastID3.Frame.PictureFrame.Picture(image: image)
                    )
                )
            }
            
            let tag = OutcastID3.ID3Tag(version: .v2_4, frames: frames)
            let mp3File = try? OutcastID3.MP3File(localUrl: url)
            
            try? mp3File?.writeID3Tag(tag: tag, outputUrl: url)
            completion()
        }
    }
}
