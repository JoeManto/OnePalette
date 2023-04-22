//
//  CopyFormatService.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation

class CopyFormatService {
    
    static let shared = CopyFormatService()
    
    private(set) var formats: [CopyFormat]
    
    private(set) var currentFormat: CopyFormat
    
    private static let userDefaultsKey = "CopyFormats"
    private static let curFormatKey = "CopyFormats-Current"
    
    init() {
        self.formats = []
        self.currentFormat = CopyFormat.default()
        
        self.formats = self.getFormats()
        self.currentFormat = self.getCurrentFormat()
    }
    
    private func getFormats() -> [CopyFormat] {
        let rawFormats = UserDefaults.standard.data(forKey: Self.userDefaultsKey) ?? Data()
        guard let formats = try? JSONDecoder().decode([CopyFormat].self, from: rawFormats) else {
            print("Error decoding formats")
            return []
        }
        
        return formats
    }
    
    private func getCurrentFormat() -> CopyFormat {
        guard let curFormatId = UserDefaults.standard.string(forKey: Self.curFormatKey),
              let curFormat = self.formats.first(where: { $0.id.uuidString == curFormatId }) else {
            return .default()
        }
        
        return curFormat
    }
    
    private func saveFormats() {
        guard let data = try? JSONEncoder().encode(self.formats) else {
            print("Error encoding formats")
            return
        }
        
        UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
    }
    
    func add(format: CopyFormat) {
        self.formats.append(format)
        saveFormats()
    }
    
    func remove(format: CopyFormat) {
        self.formats.removeAll(where: { $0.id == format.id })
        
        if format == currentFormat {
            self.setCurrent(format: self.formats.first ?? .default())
        }
        
        saveFormats()
    }
    
    func update(format: CopyFormat) {
        if let idx = self.formats.firstIndex(where: { $0.id == format.id }) {
            self.formats[idx] = format
            self.saveFormats()
            
            if format == currentFormat {
                self.setCurrent(format: format)
            }
        }
    }
    
    func setCurrent(format: CopyFormat) {
        if !self.formats.contains(where: { $0.id == format.id }) {
            self.add(format: format)
        }
        
        self.currentFormat = format
        
        UserDefaults.standard.set(format.id.uuidString, forKey: Self.curFormatKey)
    }
}
