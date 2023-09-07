//
//  String+Ext.swift
//  Pulse
//
//  Created by ios on 31.08.23.
//

import Foundation

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
