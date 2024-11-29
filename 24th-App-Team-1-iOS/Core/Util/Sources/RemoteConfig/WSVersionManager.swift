//
//  WSVersionManager.swift
//  Util
//
//  Created by 김도현 on 11/29/24.
//

import Foundation

import FirebaseCore
import FirebaseRemoteConfig


//MARK: WSVersionManager
public final class WSVersionManager {
    
    public static let shared = WSVersionManager()
    
    private init() { }
    
    public func versionCheck(completionHandler: @escaping (_ isForceUpdate: Bool) async -> Void) async throws {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        let remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings()
        remoteConfigSettings.minimumFetchInterval = 3600
        remoteConfig.configSettings = remoteConfigSettings

        do {
            let fetchStatus = try await remoteConfig.fetch(withExpirationDuration: 0)
            if fetchStatus == .success {
                try await remoteConfig.activate()
                let appVersion = Bundle.main.appVersion
                let minVersion = remoteConfig.configValue(forKey: WSRemoteConfigKey.minversion.rawValue).stringValue
                guard let minVersion = minVersion else {
                    throw WSRemoteConfigError.notFoundVersion
                }

                let needForceUpdate = compareVersion(versionA: appVersion, versionB: minVersion) == .orderedAscending
                await completionHandler(needForceUpdate)
                
            } else {
                throw WSRemoteConfigError.invalidFirebaseConfigure
            }
        } catch {
            await completionHandler(false)
        }
    }

    
    private func compareVersion(versionA: String, versionB: String) -> ComparisonResult {
        let majorA = Int(Array(versionA.split(separator: "."))[1])!
        let majorB = Int(Array(versionB.split(separator: "."))[1])!
        
        if majorA < majorB {
            return .orderedAscending
        }
        
        return .orderedSame
    }
}


