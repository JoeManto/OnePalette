//
//  PaletteImporter.swift
//  OnePalette
//
//  Created by Joe Manto on 4/25/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

class PaletteImporter {
    
    let onCancel: () -> Void
    
    private let manager: FileManager
    
    private let entity: NSEntityDescription
    private let context: NSManagedObjectContext
    
    init(onCancel: @escaping (() -> Void), entity: NSEntityDescription, insertInto context: NSManagedObjectContext) {
        self.onCancel = onCancel
        manager = .default
        self.entity = entity
        self.context = context
    }
    
    @Published var importedPalette: Palette?
    
    func `import`() {
        DispatchQueue.main.async {
            guard let data = self.selectFile() else {
                return
            }
            
            guard let palette = self.parsePaletteData(data: data) else {
                return
            }

            self.importedPalette = palette
        }
    }
    
    private func selectFile() -> Data? {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a palette (.pal)"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if let path = result?.path {
                return manager.contents(atPath: path)
            }
            else {
                OPUtil.showErrorAlert(title: "Palette Not Found", msg: "No file path")
            }
            
        } else {
            self.onCancel()
        }
        
        return nil
    }
    
    func parsePaletteData(data: Data) -> Palette? {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
            showParsingErrorAlert()
            return nil
        }
        
        let palette = Palette(entity: entity, insertInto: context)
        
        guard let names = json["names"] as? [String] else {
            showParsingErrorAlert()
            return nil
        }
  
        guard let keys = json["keys"] as? [String] else {
            showParsingErrorAlert()
            return nil
        }
     
        guard let weights = json["weights"] as? [Int] else {
            showParsingErrorAlert()
            return nil
        }
        
        let groupOrder = json["groupsOrder"] as? [String]
        
        var palData = [String: OPColorGroup]()
        
        for (i, key) in keys.enumerated() {
            guard let hexColors = json[key] as? [String] else {
                continue
            }
            
            var colors = [OPColor]()
            var headerColorIndex: Int?
            
            for (x, hex) in hexColors.enumerated() {
                var hexStr = hex
                let weight = weights.count > 0 ? weights[min(x, weights.count - 1)] : 0
                
                if hex.first == "*" {
                    hexStr.removeFirst()
                    headerColorIndex = x
                }
                colors.append(OPColor(hexString: hexStr, weight: weight))
            }
            
            let group = OPColorGroup(id: key)
            group.headerColorIndex = headerColorIndex ?? (colors.count - 1) / 2
            group.name = names[i]
            group.colorsArray = colors
            
            palData[key] = group
        }
        
        var paletteName = json["paletteName"] as? String ?? "New Palette"
        paletteName = paletteName.getUniqueNumberedName(in: PaletteService.shared.palettes.map { $0.paletteName })
        
        palette.paletteWeights = weights
        palette.paletteData = palData
        palette.paletteName = paletteName
        palette.paletteKey = keys
        palette.saveColorData()
        palette.groupsOrder = groupOrder ?? keys
        palette.dateCreated = Date()
        
        return palette
    }
    
    private func showParsingErrorAlert() {
        OPUtil.showErrorAlert(
            title: "Failed To Parse Palette",
            msg: "File was in an unexpected format"
        )
    }
}
