//
//  FirebaseDataProtocol.swift
//  cleancar
//
//  Created by MacBook Pro on 8/28/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import Firebase


protocol FirebaseDataProtocol {
    var id: String { get }
    static var childRefName: String { get }
    
    func toDict(withId: Bool) -> NSMutableDictionary

}


enum FirebaseRemoteConfigKeyTypes: String {
    case AddressNameLabel = "label_address_name"
    case AddressLabel = "label_address"
    case TimeRangeLabel = "label_time_range"
    case PhoneNumber = "data_administrator_phone_number"
    case AdministatorName = "label_administrator_name"
    case TimeStart = "data_start_hour"
    case TimeFinish = "data_end_hour"
    case LocationLat = "data_address_location_lat"
    case LocationLong = "data_address_location_long"
}

class FirebaseRemoteConfig {
    static let sharedInstance = FirebaseRemoteConfig()

    let remoteConfig: FIRRemoteConfig
    var expirationDuration = 3600

    private init() {
        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaultsFromPlistFileName("RemoteConfigDefaults")
        fetch()
    }

    func fetch() {
        // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
        // the server.
        if remoteConfig.configSettings.isDeveloperModeEnabled {
            expirationDuration = 0
        }

        remoteConfig.fetchWithExpirationDuration(NSTimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .Success {
                print("Config fetched! and will expire in", self.expirationDuration)
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
        }
    }
    static func value(key: FirebaseRemoteConfigKeyTypes) -> FIRRemoteConfigValue {
        return FirebaseRemoteConfig.sharedInstance.remoteConfig[key.rawValue]
    }
    
}


