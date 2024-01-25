//
//  ResponsePulseWidgetModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.01.24.
//

import Foundation

final class ResponsePulseWidgetModel<T>: Decodable where T: Decodable {
    let id: String
    let title: String
    let localizationKey: String
    var content = [T]()
    let buttonText: String
    let buttonLocalizationKey: String
    let localizableTitle: String?
    let localizableButtonText: String?
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case localizationKey
        case content
        case buttonText
        case buttonLocalizationKey
        case localizableTitle
        case localizableButtonText
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.localizationKey = try container.decode(String.self, forKey: .localizationKey)
        self.content = try container.decode([T].self, forKey: .content)
        self.buttonText = try container.decode(String.self, forKey: .buttonText)
        self.buttonLocalizationKey = try container.decode(String.self, forKey: .buttonLocalizationKey)
        self.localizableTitle = try container.decodeIfPresent(String.self, forKey: .localizableTitle)
        self.localizableButtonText = try container.decodeIfPresent(String.self, forKey: .localizableButtonText)
    }
}
