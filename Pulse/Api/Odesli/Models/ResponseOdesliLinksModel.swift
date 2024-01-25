//
//  ResponseOdesliLinksModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import Foundation

struct OdesliLink {
    let service: OdesliService
    let type   : ServiceType
    
    var id: String {
        return self.service.entitiyUniqueId.replacingOccurrences(of: self.type.odesliReplacePart, with: "")
    }
}

final class ResponseOdesliLinksModel: Decodable {
    let appleMusic  : OdesliService?
    let soundcloud  : OdesliService?
    let spotify     : OdesliService?
    let youtube     : OdesliService?
    let youtubeMusic: OdesliService?
    let yandexMusic : OdesliService?
    let deezer      : OdesliService?
    
    var links: [OdesliLink] {
        var links = [OdesliLink]()
        if let appleMusic {
            links.append(OdesliLink(service: appleMusic, type: .appleMusic))
        }
        
        if let deezer {
            links.append(OdesliLink(service: deezer, type: .deezer))
        }
        
        if let soundcloud {
            links.append(OdesliLink(service: soundcloud, type: .soundcloud))
        }
        
        if let spotify {
            links.append(OdesliLink(service: spotify, type: .spotify))
        }
        
        if let youtube {
            links.append(OdesliLink(service: youtube, type: .youtube))
        }
        
        if let youtubeMusic {
            links.append(OdesliLink(service: youtubeMusic, type: .youtubeMusic))
        }
        
        if let yandexMusic {
            links.append(OdesliLink(service: yandexMusic, type: .yandexMusic))
        }
        
        return links
    }
    
    enum CodingKeys: String, CodingKey {
        case appleMusic
        case deezer
        case soundcloud
        case spotify
        case youtube
        case youtubeMusic
        case yandexMusic = "yandex"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.appleMusic = try container.decodeIfPresent(OdesliService.self, forKey: .appleMusic)
        self.deezer = try container.decodeIfPresent(OdesliService.self, forKey: .deezer)
        self.soundcloud = try container.decodeIfPresent(OdesliService.self, forKey: .soundcloud)
        self.spotify = try container.decodeIfPresent(OdesliService.self, forKey: .spotify)
        self.youtube = try container.decodeIfPresent(OdesliService.self, forKey: .youtube)
        self.youtubeMusic = try container.decodeIfPresent(OdesliService.self, forKey: .youtubeMusic)
        self.yandexMusic = try container.decodeIfPresent(OdesliService.self, forKey: .yandexMusic)
    }
}
