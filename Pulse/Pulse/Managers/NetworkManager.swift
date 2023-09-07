//
//  NetworkManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    fileprivate init() {}
    
    func updateValues() {
        DispatchQueue.global(qos: .background).async {
            ipifyProvider.shared.getIp { [weak self] ip in
                self?.ip = ip
                self?.getCountryCode()
            } failure: { [weak self] in
                self?.getCountryCode()
            }
        }
    }
}

// MARK: -
// MARK: Ip and country of device
extension NetworkManager {
    var ip: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.ip) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKey.ip)
        }
    }
    
    var country: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.country) as? String ?? "US"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKey.country)
        }
    }
    
    func getCountryCode() {
        ipApiProvider.shared.getCountryCode { [weak self] countryCode in
            self?.country = countryCode
        }
    }
}

// MARK: -
// MARK: User-Agent
extension NetworkManager {
    private var darvinVersion: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let darvin = String(
            bytes: Data(bytes: &systemInfo.release, count: Int(_SYS_NAMELEN)),
            encoding: .ascii
        )!.trimmingCharacters(in: .controlCharacters)
        
        return "Darvin/\(darvin)"
    }
    
    private var cfNetworkVersion: String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }
    
    private var appNameAndVersion: String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let name = dictionary["CFBundleName"] as! String
        return "\(name)/\(version)"
    }
    
    var userAgent: String {
        return "\(appNameAndVersion) \(cfNetworkVersion) \(darvinVersion)"
    }
}
