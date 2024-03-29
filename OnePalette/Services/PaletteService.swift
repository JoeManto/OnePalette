//
//  PaletteService.swift
//  OnePalette
//
//  Created by Joe Manto on 12/4/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import AppKit
import Combine

class PaletteService {
    
    static let shared = PaletteService()
    
    private(set) var palettes = [Palette]()
    
    private var curPaletteIndex: Int
    
    static let nextPaletteNavigationNotification = Notification(name: Notification.Name("NextPaletteNavNotification"))
    static let prevPaletteNavigationNotification = Notification(name: Notification.Name("PrevPaletteNavNotification"))
    static let paletteInstalledNotification = Notification(name: Notification.Name("PaletteInstalled"))
    
    /// The current palette being presented in PaletteView
    var lastUsed: Palette? {
        guard curPaletteIndex < self.palettes.count else {
            return nil
        }
        return self.palettes[curPaletteIndex]
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
    
    private let importer: PaletteImporter
    
    private var subs = Set<AnyCancellable>()
    
    private init() {
        self.context = (NSApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
        self.entity = NSEntityDescription.entity(forEntityName: "Pal", in: context)!
        self.curPaletteIndex = 0 // TODO update search for value from userdefaults if not found default to first palette
        
        self.importer = PaletteImporter(onCancel: {}, entity: entity, insertInto: context)
        self.importer.$importedPalette.sink { pal in
            if let pal = pal {
                self.install(palette: pal)
            }
        }
        .store(in: &subs)
                          
        onOperationQueue {
            if self.fetchAllPalettes() == 0 {
                // If the user has no saved palettes install the default palettes
                self.installMaterialDesignPalette()
                //self.installAppleDesignPalette()
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
    
    func installMaterialDesignPalette() {
        let pal = Palette(name: "Material Design", localFile: "MaterialDesginColors", entity: entity, insertInto: context)
        self.install(palette: pal)
    }
    
    func installAppleDesignPalette() {
        let pal = Palette(name: "Apple Design", localFile: "AppleDesginColors", entity: entity, insertInto: context)
        self.install(palette: pal)
    }
    
    /// Saves an empty palette.
    /// Returns the newly created palette
    func installEmptyPalette() -> Palette {
        var paletteName = "New Palette"
      
        while self.isNameTaken(name: paletteName) {
            let comps = paletteName.split(separator: " ")
            
            guard comps.count >= 3, let prevNum = Int(comps[2]) else {
                paletteName = "\(paletteName) 1"
                continue
            }
            paletteName = "New Palette \(prevNum + 1)"
        }
        
        let pal = Palette(name: paletteName, entity: entity, insertInto: context)
        pal.addColorGroup(group: OPColorGroup.newGroup(), save: false)
        
        return self.install(palette: pal)
    }
    
    @discardableResult private func install(palette: Palette) -> Palette {
        self.palettes.append(palette)
        
        guard palette.save() else {
            assert(false, "Failed to save <\(palette.paletteName)> color palette")
            return palette
        }
        
        NotificationCenter.default.post(Self.paletteInstalledNotification)
        
        return palette
    }
    
    func delete(palette: Palette) {
        let palettesToRemove = self.palettes.filter { $0.id == palette.id }
        self.palettes.removeAll(where: { $0.id == palette.id })
        for pal in palettesToRemove {
            context.delete(pal)
        }
        
        do {
            try context.save()
        }
        catch {
            assert(false, "Failed to save after deleting palette(s)")
        }
    }
    
    func getPalette(for name: String) -> [Palette] {
        return self.palettes.filter { $0.paletteName == name }
    }
    
    func setCurrentGroup(groupId: String) {
        let curPal = self.palettes[curPaletteIndex]
        let groupExists = curPal.paletteData?.contains(where: { (key, value) in value.identifier == groupId }) ?? false
        
        guard groupExists else {
            assert(false, "Provided groupId doesn't exist")
            return
        }
        
        self.palettes[curPaletteIndex].curGroupId = groupId
    }
    
    func nextPalette() -> Palette {
        print("next")
        NotificationCenter.default.post(Self.nextPaletteNavigationNotification)
        
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
        NotificationCenter.default.post(Self.prevPaletteNavigationNotification)
        
        let prevIndex = self.curPaletteIndex - 1
        
        guard prevIndex >= 0 else {
            self.curPaletteIndex = self.palettes.count - 1
            return self.palettes[self.palettes.count - 1]
        }
        
        self.curPaletteIndex = prevIndex
        return self.palettes[prevIndex]
    }
    
    private func removeAllPalettes() {
        self.palettes = []
        self.curPaletteIndex = 0
        OPUtil.flushData(entity: self.entity, insertInto: self.context)
    }
    
    func isNameTaken(name: String) -> Bool {
        for palette in palettes {
            if palette.paletteName == name {
                return true
            }
        }
        return false
    }
    
    func cleanInstall() {
        self.onOperationQueue {
            self.removeAllPalettes()
            self.installMaterialDesignPalette()
            //self.installAppleDesignPalette()
        }
    }
    
    func importPalette() {
        self.importer.import()
    }
    
    func exportPalette() {
        
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
