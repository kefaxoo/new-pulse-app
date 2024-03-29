//
//  String+Ext.swift
//  Pulse
//
//  Created by ios on 31.08.23.
//

import UIKit

fileprivate let normalLine = "!\"#$%&'()*+,-./0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
fileprivate let cryptedLine = "mdl|cajoz~{wpyrusvktqhei`bnxf}gUHF[WPMR^GCAITY\\_]OEXSBJNKQ@VDLZ.\"*<-50&$;/:%'#2,7(>!8)14=3+69"

extension String {
    func at(_ index: Int) -> Character {
        let index = self.index(self.startIndex, offsetBy: index)
        return self[index]
    }
}

extension String {
    var encode: String {
        var result = ""
        for i in 0..<self.count {
            guard let index = normalLine.firstIndex(of: self.at(i)) else { continue }
            
            result.append(cryptedLine[index])
        }
        
        return result
    }
    
    var decode: String {
        var result = ""
        for i in 0..<self.count {
            guard let index = cryptedLine.firstIndex(of: self.at(i)) else { continue }
            
            result.append(normalLine[index])
        }
        
        return result
    }
}

extension String {
    init(length: Int, symbols: String) {
        self = String((0..<length).map({ _ in symbols.randomElement()! }))
    }
}

extension String {
    var toUnixFilename: String {
        let removeChars: Set<Character> = ["/", ">", "<", "|", ":", "&"]
        var newSelf = self
        newSelf.removeAll(where: { removeChars.contains($0) })
        return newSelf
    }
}

extension String {
    var emojiFlag: String {
        let base: UInt32 = 127397
        var line = ""
        self.unicodeScalars.forEach({ line.unicodeScalars.append(UnicodeScalar(base + $0.value)!) })
        return String(line)
    }
}

extension String {
    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: Bundle.localizedBundle,
            value: self,
            comment: self
        )
    }
    
    func localized(parameters: [String]) -> String {
        if parameters.count == 1 {
            return String(format: self.localized, parameters[0])
        } else {
            return String(format: self.localized, arguments: parameters)
        }
    }
}

extension String {
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
            
        return ceil(boundingBox.height)
    }
}
