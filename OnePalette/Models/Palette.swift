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
        self.curGroupId = (data.first?.value.getIdentifier()) ?? ""
        self.dateCreated = date
    }
    
    /// Inits a palette object from an import from a local json file that contains palette data
    /// This method is used when the user first runs the application so it can intital install
    /// pre installed palettes
    convenience init(name: String, localFile: String, entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        self.init(name: name, entity: entity, insertInto: context)
        let path = Bundle.main.url(forResource: localFile, withExtension: "json")
        let content = try? String(contentsOf: path!)
        
        let jsonWithObjectRoot = content!
        let data = jsonWithObjectRoot.data(using:.utf8)!
        do {
            let json = try JSONSerialization.jsonObject(with:data)
            if let dictionary = json as? [String: Any] {
                if let nestDictionary = dictionary["keys"] as? [String: Any] {
                    let keys:NSArray = nestDictionary["values"] as! NSArray
                    self.paletteKey = Array(repeating: "", count: keys.count)
                    for (index, i) in keys.enumerated(){
                        let stringVal:String = i as! String
                        self.paletteKey![index] = stringVal
                    }
                }
                
                if let nestDictionary = dictionary["weights"] as? [String: Any] {
                    let weights:NSArray = nestDictionary["values"] as! NSArray
                    for (index, i) in weights.enumerated() {
                        let stringVal:String = i as! String
                        self.paletteWeights![index] = Int(stringVal)!
                    }
                }
                for palKey in self.paletteKey! {
                    self.groupsOrder?.append(palKey)
                    if let nestDictionary = dictionary[palKey] as? [String: Any] {
                        let colorGroup:NSArray = nestDictionary["values"] as! NSArray

                        self.paletteData![palKey] = OPColorGroup.init(id: palKey)
                        for (index, i) in colorGroup.enumerated(){
                            self.paletteData![palKey]?.addColor(color: OPColor.init(hexString: i as! String, alpha: 1.0, weight: self.paletteWeights![index]))
                        }
                        self.paletteData![palKey]?.findHeaderColor()
                    }
                }
                
                if let nestDictionary = dictionary["Names"] as? [String:Any] {
                    let names: NSArray = nestDictionary["values"] as! NSArray
                    for (index, i) in (self.paletteKey?.enumerated())! {
                        let name = names[index] as! String
                        self.paletteData?[i]?.setName(name: name)
                    }
                }
            }
            
            self.curGroupId = (self.paletteData?.first?.value.getIdentifier()) ?? ""
        } catch {
            print("Error parsing Json")
        }
    }
    
    // MARK: Group Methods
    
    /// Adds a colorgroup to the palatte data
    func addColorGroup(group: OPColorGroup) {
        paletteData![group.getIdentifier()] = group
        print("added colorGroup")
    }
    
    /// Adds an empty color group to the palette data with a name
    func addEmptyGroup(with groupID: String) {
        print("added empty group")
        paletteData![groupID] = OPColorGroup(id: groupID)
    }
    
    /// Updates an existing color group value
    func updateColorGroup(group: OPColorGroup, for groupID: String) {
        paletteData![groupID] = group
    }
    
    func updateColorGroup(group: OPColorGroup, save: Bool) {
        self.updateColorGroup(group: group, for: group.getIdentifier())
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
    
    /// Generates a simple color group used for when the user inserts a new color group in to a palette
    func generateTempColorGroup() -> OPColorGroup {
        let randomId = UUID().uuidString
        let group = OPColorGroup(id:randomId)
        let random = arc4random_uniform(201) + 30
        let color = OPColor(hexString: String(format:"%2X%2X%2X", random, random, random), weight: 50)
        group.addColor(color: color)
        paletteKey?.append(randomId)
        group.headerColorIndex = 0
        self.addColorGroup(group: group)
        return group
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
