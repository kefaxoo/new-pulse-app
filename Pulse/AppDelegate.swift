//
//  AppDelegate.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 27.08.23.
//

import UIKit
import PulseMedia
import FirebaseCore
import FirebasePerformance

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let trace = Performance.startTrace(name: "app_launch_trace")
        if !NetworkManager.shared.isHomeWifi {
            AppEnvironment.current = AppEnvironment.environmentByScheme
        }
        
        debugLog(AppEnvironment.current)
        MainCoordinator.shared.makeLaunchScreenAsRoot()
        SettingsManager.shared.initRealmVariables()
        NetworkManager.shared.checkNetwork()
        NetworkManager.shared.updateValues()
        ServicesManager.shared.refreshTokens()
        SettingsManager.shared.yandexMusic.checkPlusSubscription()
        LibraryManager.shared.removeTemporaryCache()
        PulseProvider.shared.fetchSettings()
        SettingsManager.shared.pulse.isUserBlocked {
            SettingsManager.shared.updateFeatures {
                MainCoordinator.shared.firstLaunch {
                    LibraryManager.shared.initialSetup()
                    trace?.stop()
                }
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    // swiftlint:disable line_length
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    // swiftlint:enable line_length
    
    func applicationWillTerminate(_ application: UIApplication) {
        LibraryManager.shared.removeTemporaryCache()
    }
}
