//
//  FirstLaunchChecker.swift
//  daummap
//
//  Created by Lyla on 2023/09/12.
//

import Foundation

struct FirstLaunchChecker {
    static func isFirstLaunched() -> Bool {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "isFirstLaunched") == nil {
            return true
        } else {
            return false
        }
    }
}
