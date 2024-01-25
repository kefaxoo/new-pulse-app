//
//  ResponsePulseWidgetRootModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.01.24.
//

import Foundation

final class ResponsePulseWidgetRootModel<T>: PulseBaseSuccessModel where T: Decodable {
    let widget: PulseWidget<T>
    
    enum CodingKeys: CodingKey {
        case widget
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.widget = try container.decode(PulseWidget<T>.self, forKey: .widget)
        
        try super.init(from: decoder)
    }
}
