//
//  CopyFormat.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation

struct CopyFormat: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    let format: String
    
    static func == (lhs: CopyFormat, rhs: CopyFormat) -> Bool {
        return lhs.id == rhs.id
    }
    
    func value(color: OPColor, groupName: String) -> String {
        let nscolor = color.saveableColor
        let rgb = (red: Int(nscolor.red * 255), green: Int(nscolor.green * 255), blue: Int(nscolor.blue * 255))
        let rgbf = (red: nscolor.red, green: nscolor.green, blue: nscolor.blue)
        var hex = color.hexValue
        
        while hex.first == "#" {
            hex.removeFirst()
        }
        
        var output = format
        
        
        output = output.replacingOccurrences(of: "@r-float", with: "\(rgbf.red)")
        output = output.replacingOccurrences(of: "@g-float", with: "\(rgbf.green)")
        output = output.replacingOccurrences(of: "@b-float", with: "\(rgbf.blue)")
        
        output = output.replacingOccurrences(of: "@hex", with: "\(hex)")
        output = output.replacingOccurrences(of: "@group", with: "\(groupName)")
        
        output = output.replacingOccurrences(of: "@r", with: "\(rgb.red)")
        output = output.replacingOccurrences(of: "@g", with: "\(rgb.green)")
        output = output.replacingOccurrences(of: "@b", with: "\(rgb.blue)")

        return output
    }
}

extension CopyFormat {
    static func `default`() -> CopyFormat {
        return CopyFormat(name: "Hex", format: "#@hex")
    }
    
    static func nameUnique() -> CopyFormat {
        let name = "New Format".getUniqueNumberedName(in: CopyFormatService.shared.formats.map { $0.name })
        return CopyFormat(name: name, format: "")
    }
}
