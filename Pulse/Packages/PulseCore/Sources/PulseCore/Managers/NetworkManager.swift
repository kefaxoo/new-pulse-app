//
//  NetworkManager.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation

public final class NetworkManager {
    public static let shared = NetworkManager()
    
    public func appStarting() {
        self.updateCountry()
    }
}

// MARK: -
// MARK: User-Agent
extension NetworkManager {
    private static var darvinVersion: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let darvin = String(
            bytes: Data(bytes: &systemInfo.release, count: Int(_SYS_NAMELEN)),
            encoding: .ascii
        )!.trimmingCharacters(in: .controlCharacters)
        
        return "Darvin/\(darvin)"
    }
    
    private static var cfNetworkVersion: String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as? String ?? ""
        return "CFNetwork/\(version)"
    }
    
    private static var appNameAndVersion: String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as? String ?? ""
        let name = dictionary["CFBundleName"] as? String ?? ""
        return "\(name)/\(version)"
    }
    
    public static var userAgent: String {
        return "\(appNameAndVersion) \(cfNetworkVersion) \(darvinVersion)"
    }
}

// MARK: -
// MARK: Location
extension NetworkManager {
    public var countryCode: String {
        get {
            return UserDefaults.standard.value(forKey: .deviceCountry) as? String ?? "US"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .deviceCountry)
        }
    }
    
    func updateCountry() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            PulseDeviceProvider.shared.fetchInfo { deviceInfo in
                self?.countryCode = deviceInfo?.countryCode ?? "US"
            }
        }
    }
}
