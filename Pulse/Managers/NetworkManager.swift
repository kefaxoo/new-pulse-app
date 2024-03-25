//
//  NetworkManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation
import Network
import SystemConfiguration.CaptiveNetwork

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
    private(set) var country : String?
    
    private lazy var monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    private(set) var isReachableOnCellurar = false
    
    var isPong = true {
        didSet {
            self.setupPingPongTimer()
        }
    }
    
    private var pingPongTimer: Timer?
    
    var isReachable: Bool {
        return self.status == .satisfied
    }
    
    var isHomeWifi: Bool {
        var ssid: String?
        guard let interfaces: NSArray = CNCopySupportedInterfaces() else { return false }
        
        for interface in interfaces {
            // swiftlint:disable force_cast
            let cfInterface = interface as! CFString
            // swiftlint:enable force_cast
            guard let interfaceInfo: NSDictionary = CNCopyCurrentNetworkInfo(cfInterface) else { continue }
            
            ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
            break
        }
        
        return ["TP-Link_5D85_5G", "TP-Link_5D85"].contains(ssid)
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
    
    func checkNetwork() {}
    
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
    
    var countryCode: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.country.rawValue) as? String ?? "US"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.country.rawValue)
        }
    }
    
    func getCountryCode() {
        IpApiProvider.shared.getInfo { [weak self] model in
            self?.countryCode = model.countryCode ?? ""
            self?.city = model.city
            self?.provider = model.provider
            self?.country = model.country
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
                  self.isReachable != (path.status == .satisfied || path.isExpensive)
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

// MARK: -
// MARK: Ping-Pong Pulse Api
extension NetworkManager {
    func setupPingPongTimer() {
        self.pingPongTimer?.invalidate()
        
        self.pingPongTimer = Timer.scheduledTimer(withTimeInterval: 10 * 60, repeats: true, block: { _ in
            PulseProvider.shared.ping()
        })
    }
}
