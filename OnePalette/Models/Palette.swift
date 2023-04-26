//
//  Palette.swift
//  OnePalette
//
//  Created by Joe Manto on 3/6/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import CoreData

class Palette: NSManagedObject, Identifiable {
    
    @NSManaged var paletteDataToSave: NSData?
    @NSManaged var paletteName: String
    @NSManaged var paletteWeights: [Int]?
    @NSManaged var paletteKey: [String]?
    @NSManaged var groupsOrder: [String]?
    @NSManaged var curGroupId: String
    @NSManaged var dateCreated: Date
    
    var paletteData: [String : OPColorGroup]?
    
    /// The color groups contained in the palette in the users pefered order
    var groups: [OPColorGroup] {
        var groups = [OPColorGroup]()
        
        for id in groupsOrder ?? [] {
            groups.append(self.paletteData?[id] ?? OPColorGroup(id: "empty"))
        }
        
        return groups
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        self.dateCreated = Date()
        
        if let data = paletteDataToSave {
            self.paletteData = try? JSONDecoder().decode([String : OPColorGroup].self, from: Data(referencing: data))
        }
    }
    
    init(name: String, entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        self.paletteData = [String : OPColorGroup]()
        self.paletteName = name
        self.paletteWeights = Array(repeating: 0, count: 10)
        self.paletteKey = Array(repeating: "", count: 0)
        self.groupsOrder = Array(repeating: "", count: 0)
        self.curGroupId = ""
        self.dateCreated = Date()
    }
    
    init(name: String, data: [String : OPColorGroup], groupsOrder: [String], palWeights: [Int], palKeys: [String], date: Date, entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        self.paletteData = data
        self.paletteName = name
        self.paletteWeights = palWeights
        self.paletteKey = palKeys
        self.groupsOrder = groupsOrder
        self.curGroupId = (data.first?.value.identifier) ?? ""
        self.dateCreated = date
    }
    
    /// Inits a palette object from an import from a local json file that contains palette data
    /// This method is used when the user first runs the application so it can intital install
    /// pre installed palettes
    convenience init(name: String, localFile: String, entity: NSEntityDescription, insertInto context: NSManagedObjectContext) {
        self.init(name: name, entity: entity, insertInto: context)
        
        guard let path = Bundle.main.url(forResource: localFile, withExtension: "json") else {
            return
        }
        
        guard let content = try? Data(contentsOf: path) else {
            return
        }
        
        let importer = PaletteImporter(onCancel: {}, entity: entity, insertInto: context)
        guard let palette = importer.parsePaletteData(data: content) else {
            return
        }
        
        self.paletteData = palette.paletteData
        self.paletteName = palette.paletteName
        self.paletteWeights = palette.paletteWeights
        self.paletteKey = palette.paletteKey
        self.groupsOrder = palette.groupsOrder
        self.curGroupId = (palette.paletteData?.first?.value.identifier) ?? ""
        self.dateCreated = palette.dateCreated
    }
    
    // MARK: Group Methods
    
    /// Adds a ColorGroup to the palatte data at the end of the group order
    func addColorGroup(group: OPColorGroup, save: Bool) {
        let id = group.identifier
        self.groupsOrder?.append(id)
        paletteData?[id] = group
        
        if save {
            _ = self.save()
        }
    }
    /// Updates an existing color group value
    func updateColorGroup(group: OPColorGroup, for groupID: String) {
        paletteData![groupID] = group
    }
    
    func updateColorGroup(group: OPColorGroup, save: Bool) {
        self.updateColorGroup(group: group, for: group.identifier)
        if save {
            _ = self.save()
        }
    }
    
    func updateColorGroups(groups: [OPColorGroup], save: Bool) {
        for group in groups {
            self.updateColorGroup(group: group, save: false)
        }
        
        if save {
            _ = self.save()
        }
    }
    
    func reorderGroups(off groups: [OPColorGroup], save: Bool) {
        self.groupsOrder = groups.map { $0.identifier }
        
        if save {
            _ = self.save()
        }
    }
    
    func removeColorGroup(_ group: OPColorGroup) {
        self.groupsOrder?.removeAll(where: { $0 == group.identifier })
            
        guard let _ = self.paletteData?[group.identifier] else {
            assert(false, "Attempt to remove color group \(group.identifier) that doesn't exist")
            return
        }
        
        self.paletteData?[group.identifier] = nil
        _ = self.save()
    }
    
    // MARK:  CoreData Save
    
    /// Turns paletteData to BinaryData so it can be saved as an NSManaged objec in core data
    func saveColorData() {
        guard let data = self.paletteData else {
            return
        }
        
        self.paletteDataToSave = NSData(data: (try? JSONEncoder().encode(data)) ?? Data())
    }
    
    /// Core data saves the manangedObjectContext to the entitity
    func save() -> Bool {
        saveColorData()
        
        if managedObjectContext!.hasChanges {
            do {
                try managedObjectContext?.save()
                print("saved palette")
                return true
            } catch {
                print("failed to save")
                return false
            }
        }
        return false
    }
}
