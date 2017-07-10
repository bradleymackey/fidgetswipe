//
//  AdvertManager.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 10/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

public final class AdvertManager {
	
	public static let shared = AdvertManager()
	
	private let remoteConfig:RemoteConfig
	
	public var adsEnabled:Bool {
		return remoteConfig.configValue(forKey: "enable_ads").boolValue
	}
	
	private init() {
		remoteConfig = RemoteConfig.remoteConfig()
		//remoteConfig.configSettings = FIRRemoteConfigSettings(developerModeEnabled: true)!
		remoteConfig.setDefaults(["enable_ads":true as NSObject])
		updateAdsEnabled()
	}
	
	private func updateAdsEnabled() {
		remoteConfig.fetch(withExpirationDuration: 43200) { (status, error) in
			if let err = error {
				print("error getting remote config values: \(err.localizedDescription)")
			} else {
				print("got config values with status: \(status)")
				self.remoteConfig.activateFetched()
			}
		}
	}
	
}
