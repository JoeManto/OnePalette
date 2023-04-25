//
//  OnePaletteSettingsProvider.swift
//  OnePalette
//
//  Created by Joe Manto on 4/23/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppSDK

/*class OnePaletteSettingsProvider: AppSettingsProvider {
    func appSettings() -> [AppSettingKey : AppSDK.AppSetting] {
        var settings = [AppSettingKey: AppSetting]()
        
        // Looping through all cases so we can utilize a switch statement exhaustiveness
        // to ensuring we provide a AppSetting for every AppSettingKey
        for key in AppSettingKey.allCases {
            switch key {
            case .app:
                settings[.app] = AppSetting(key: .app, title: "", description: "", defaultValue: false)
            }
        }

        return settings
    }
}*/
