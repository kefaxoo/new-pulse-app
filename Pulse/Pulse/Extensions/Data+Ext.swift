//
//  Data+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation

extension Data {
    func map<T: Decodable>(to type: T.Type) -> T? {
        let object: T
        do {
            object = try JSONDecoder().decode(type, from: self)
            return object
        } catch let DecodingError.dataCorrupted(context) {
            debugPring(context)
        } catch let DecodingError.keyNotFound(key, context) {
            debugPring("Key", key, "not found:", context.debugDescription, "\ncodingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            debugPring("Value", value, "not found:", context.debugDescription, "\ncodingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            debugPring("Type", type, "mismatch:", context.debugDescription, "\ncodingPath", context.codingPath)
        } catch {
            debugPring("error:", error)
        }
        
        return nil
    }
}