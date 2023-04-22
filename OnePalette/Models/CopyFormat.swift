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
