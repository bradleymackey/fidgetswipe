//
//  GameConstants.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseAnalytics


/// Singleton class used for the game, backed by remote config. (Use public methods to access data)
public final class GameConstants {
    
    let remoteConfig:RemoteConfig
    
    public static let shared = GameConstants()
    
    /// Keys for the contsants used by remote config
    private struct GameConstantsKeys {
        static let time_1 = "time_1"
        static let time_2 = "time_2"
        static let time_4 = "time_4"
        static let time_7 = "time_7"
        static let time_12 = "time_12"
        static let time_20 = "time_20"
        static let time_40 = "time_40"
        static let time_60 = "time_60"
    }
    
    /// Default values for all the different stages in the game
    private struct GameConstantsValues {
        static let time_1:NSNumber = 4
        static let time_2:NSNumber = 3
        static let time_4:NSNumber = 1.6
        static let time_7:NSNumber = 1
        static let time_12:NSNumber = 0.75
        static let time_20:NSNumber = 0.55
        static let time_40:NSNumber = 0.45
        static let time_60:NSNumber = 0.35
    }
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        self.remoteConfig.activateFetched() // update any fetched values we may have retrieved from last time
        let defaults:[String:NSNumber] = [GameConstantsKeys.time_1:GameConstantsValues.time_1,
                                          GameConstantsKeys.time_2:GameConstantsValues.time_2,
                                          GameConstantsKeys.time_4:GameConstantsValues.time_4,
                                          GameConstantsKeys.time_7:GameConstantsValues.time_7,
                                          GameConstantsKeys.time_12:GameConstantsValues.time_12,
                                          GameConstantsKeys.time_20:GameConstantsValues.time_20,
                                          GameConstantsKeys.time_40:GameConstantsValues.time_40,
                                          GameConstantsKeys.time_60:GameConstantsValues.time_60]
        remoteConfig.setDefaults(defaults)
        updateRemoteConfigValues() // try to get some new values
    }
    
    private func updateRemoteConfigValues() {
        remoteConfig.fetch(withExpirationDuration: 43200) { (status, error) in
            if let err = error {
                Analytics.logEvent("remote_config_err", parameters: nil)
                print("Error getting remote config values: \(err.localizedDescription)")
            } else {
                Analytics.logEvent("remote_config_succ", parameters: nil)
                print("got updated remote config values with status: \(status)")
            }
        }
    }
    
    public func getTime(forCurrentScore score: UInt) -> NSNumber {
        switch score {
        case 0..<1:
            return remoteConfig.configValue(forKey: GameConstantsKeys.time_1).numberValue ?? GameConstantsValues.time_1
        case 1..<2:
            return remoteConfig.configValue(forKey: GameConstantsKeys.time_2).numberValue ?? GameConstantsValues.time_2
        case 2..<4:
            return remoteConfig.configValue(forKey: GameConstantsKeys.time_4).numberValue ?? GameConstantsValues.time_4
        case 4..<7:
            return remoteConfig.configValue(forKey: GameConstantsKeys.time_7).numberValue ?? GameConstantsValues.time_7
        case 7..<12:
            return remoteConfig.configValue(forKey: GameConstantsKeys.time_12).numberValue ?? GameConstantsValues.time_12
        case 12..<20:
            return remoteConfig.configValue(forKey: GameConstantsKeys.time_20).numberValue ?? GameConstantsValues.time_20
        case 20..<40:
            return remoteConfig.configValue(forKey: GameConstantsKeys.time_40).numberValue ?? GameConstantsValues.time_40
        default:
            return remoteConfig.configValue(forKey: GameConstantsKeys.time_60).numberValue ?? GameConstantsValues.time_60
        }
    }
}
