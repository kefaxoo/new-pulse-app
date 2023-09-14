//
//  NetworkManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation
import Network

enum NetworkState {
    case hasInternet
    case noInternet
}

protocol NetworkManagerDelegate: AnyObject {
    func networkStateDidChange(_ status: NetworkState)
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private(set) var city    : String?
    private(set) var provider: String?
    
    private lazy var monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    private(set) var isReachableOnCellurar = false
    private var isReachable: Bool {
        return self.status == .satisfied
    }
    
    weak var delegate: NetworkManagerDelegate?
    
    fileprivate init() {
        self.startMonitoring()
    }
    
    func updateValues() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            IpifyProvider.shared.getIp { [weak self] ip in
                self?.ip = ip
                self?.getCountryCode()
            } failure: { [weak self] in
                self?.getCountryCode()
            }
        }
    }
    
    deinit {
        self.stopMonitoring()
    }
}

// MARK: -
// MARK: Ip and country of device
extension NetworkManager {
    var ip: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.ip.rawValue) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.ip.rawValue)
        }
    }
    
    var country: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.country.rawValue) as? String ?? "US"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.country.rawValue)
        }
    }
    
    func getCountryCode() {
        IpApiProvider.shared.getInfo { [weak self] model in
            self?.country = model.countryCode ?? ""
            self?.city = model.city
            self?.provider = model.provider
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
        let version = dictionary?["CFBundleShortVersionString"] as? String ?? ""
        return "CFNetwork/\(version)"
    }
    
    private var appNameAndVersion: String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as? String ?? ""
        let name = dictionary["CFBundleName"] as? String ?? ""
        return "\(name)/\(version)"
    }
    
    var userAgent: String {
        return "\(appNameAndVersion) \(cfNetworkVersion) \(darvinVersion)"
    }
}

// MARK: -
// MARK: Monitoring
extension NetworkManager {
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self,
                  self.isReachable != (path.status == .satisfied && path.isExpensive)
            else { return }
            
            self.status = path.status
            self.isReachableOnCellurar = path.isExpensive
            self.delegate?.networkStateDidChange(self.isReachable ? .hasInternet : .noInternet)
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
}
