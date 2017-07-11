//
//  AdvertManager.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 10/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseAnalytics

public final class AdvertManager {
	
	/// The singleton
	public static let shared = AdvertManager()
	
	/// Manages remote config handling
	private let remoteConfig:RemoteConfig
	
	public var adsEnabled:Bool {
		return remoteConfig.configValue(forKey: "enable_ads").boolValue
	}
	
	public var placementID:String {
		return remoteConfig.configValue(forKey: "ad_placement_id").stringValue ?? ""
	}
	
	private init() {
		remoteConfig = RemoteConfig.remoteConfig()
		//remoteConfig.configSettings = FIRRemoteConfigSettings(developerModeEnabled: true)!
		remoteConfig.setDefaults(["enable_ads":false as NSObject])
		remoteConfig.setDefaults(["ad_placement_id":"" as NSObject])
		updateAdInformation()
	}
	
	private func updateAdInformation() {
		remoteConfig.fetch(withExpirationDuration: 43200) { (status, error) in
			if let err = error {
				print("error getting remote config values: \(err.localizedDescription)")
			}
			switch status {
			case .success:
				Analytics.logEvent("remote_fetch_success", parameters: nil)
				self.remoteConfig.activateFetched()
			case .failure:
				Analytics.logEvent("remote_fetch_fail", parameters: nil)
			case .throttled:
				Analytics.logEvent("remote_fetch_throttled", parameters: nil)
			case .noFetchYet:
				Analytics.logEvent("remote_nofetchyet", parameters: nil)
			}
		}
	}
	
}
