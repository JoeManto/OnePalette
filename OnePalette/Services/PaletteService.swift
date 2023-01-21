//
//  PaletteService.swift
//  OnePalette
//
//  Created by Joe Manto on 12/4/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

class PaletteService {
    
    static let shared = PaletteService()
    
    private(set) var palettes = [Palette]()
    
    private var curPaletteIndex: Int
    
    /// The current palette being presented in PaletteView
    var lastUsed: Palette? {
        self.palettes[curPaletteIndex]
    }
    
    private lazy var postSetupQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.onepalette.palette-service.post-setup-queue", qos: .userInitiated)
        queue.suspend()
        return queue
    }()
    
    private lazy var operationQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.onepalette.palette-service.operation-queue", qos: .userInitiated)
        return queue
    }()
    
    private let context: NSManagedObjectContext
    private let entity: NSEntityDescription
    
    private init() {
        self.context = (NSApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
        self.entity = NSEntityDescription.entity(forEntityName: "Pal", in: context)!
        self.curPaletteIndex = 0 // TODO update search for value from userdefaults if not found default to first palette
                
        OPUtil.flushData(entity: entity, insertInto: context)
        
        onOperationQueue {
            if self.fetchAllPalettes() == 0 {
                // If the user has no saved palettes install the default palettes
                self.installMaterialDesignPalette()
                self.installAppleDesignPalette()
            }
            
            // Continue with execution after palettes have been installed
            self.postSetupQueue.resume()
        }
    }
    
    private func fetchAllPalettes() -> Int {
        let palettesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        
        do {
            let fetchedPalettes = try context.fetch(palettesFetch)
            self.palettes = (fetchedPalettes as? [Palette]) ?? []
            
            self.palettes.sort(by: { (a, b) in a.dateCreated > b.dateCreated })
            
            return self.palettes.count
        }
        catch {
            print("error fetching palettes: \(error)")
            return 0
        }
    }
    
    private func installMaterialDesignPalette() {
        let pal = Palette(name: "Material Design", localFile: "MaterialDesginColors", entity: entity, insertInto: context)
        self.palettes.append(pal)
        
        guard pal.save() else {
            print("Failed to save material design color palette")
            return
        }
    }
    
    private func installAppleDesignPalette() {
        let pal = Palette(name: "Apple Design", localFile: "AppleDesginColors", entity: entity, insertInto: context)
        self.palettes.append(pal)
        
        guard pal.save() else {
            print("Failed to save material design color palette")
            return
        }
    }
    
    func getPalette(for name: String) -> [Palette] {
        return self.palettes.filter { $0.paletteName == name }
    }
    
    func updateCurrentGroup(groupId: String) {
        let curPal = self.palettes[curPaletteIndex]
        let groupExists = curPal.paletteData?.contains(where: { (key, value) in value.getIdentifier() == groupId }) ?? false
        
        guard groupExists else {
            print("Provided groupId doesn't exist")
            return
        }
        
        self.palettes[curPaletteIndex].curGroupId = groupId
    }
    
    func nextPalette() -> Palette {
        print("next")
        let nextIndex = self.curPaletteIndex + 1
        
        guard nextIndex < self.palettes.count else {
            self.curPaletteIndex = 0
            return self.palettes[curPaletteIndex]
        }
        
        self.curPaletteIndex = nextIndex
        return self.palettes[nextIndex]
    }
    
    func prevPalette() -> Palette {
        print("prev")
        let prevIndex = self.curPaletteIndex - 1
        
        guard prevIndex >= 0 else {
            self.curPaletteIndex = self.palettes.count - 1
            return self.palettes[self.palettes.count - 1]
        }
        
        self.curPaletteIndex = prevIndex
        return self.palettes[prevIndex]
    }
    
    func onPalettesFetched(_ block: @escaping () -> ()) {
        self.postSetupQueue.async {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    func onOperationQueue(_ block: @escaping () -> ()) {
        self.operationQueue.async {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
