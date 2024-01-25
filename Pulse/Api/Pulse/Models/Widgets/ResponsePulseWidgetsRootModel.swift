//
//  ResponsePulseWidgetsRootModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 3.01.24.
//

import Foundation

final class ResponsePulseWidgetsRootModel: PulseBaseSuccessModel {
    let widgets: PulseWidgets
    
    enum CodingKeys: CodingKey {
        case widgets
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.widgets = try container.decode(PulseWidgets.self, forKey: .widgets)
        
        try super.init(from: decoder)
    }
}
