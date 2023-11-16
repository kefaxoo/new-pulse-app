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
            debugLog(context, sendLog: true)
        } catch let DecodingError.keyNotFound(key, context) {
            debugLog("Key", key, "not found:", context.debugDescription, "\ncodingPath:", context.codingPath, sendLog: true)
        } catch let DecodingError.valueNotFound(value, context) {
            debugLog("Value", value, "not found:", context.debugDescription, "\ncodingPath:", context.codingPath, sendLog: true)
        } catch let DecodingError.typeMismatch(type, context) {
            debugLog("Type", type, "mismatch:", context.debugDescription, "\ncodingPath", context.codingPath, sendLog: true)
        } catch {
            debugLog("error:", error, sendLog: true)
        }
        
        return nil
    }
    
    var toString: String? {
        return String(data: self, encoding: .utf8)
    }
}

extension Data {
    var decodeJWT: [String: Any]? {
        guard let jwt = String(data: self, encoding: .utf8) else { return nil }
        
        let segments = jwt.components(separatedBy: ".")
        var base64 = segments[1].replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        
        guard let bodyData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters),
              let json = try? JSONSerialization.jsonObject(with: bodyData),
              let payload = json as? [String: Any]
        else { return nil }
        
        return payload
    }
}
