//
//  String+Util.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation

extension String {
    
    /// Returns a unique version of the current name string by adding an incrementing
    /// number at end of the string until the string is unique inreguard to provided names array
    func getUniqueNumberedName(in names: [String]) -> Self {
        let baseName = self
        var curName = baseName
      
        while names.contains(curName) {
            let comps = curName.split(separator: " ")
            
            guard comps.count >= 0, let prevNum = Int(comps.last!) else {
                curName = "\(baseName) 1"
                continue
            }
            
            curName = "\(baseName) \(prevNum + 1)"
        }
        
        return curName
    }
}
