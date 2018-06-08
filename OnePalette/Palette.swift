//
//  Palette.swift
//  OnePalette
//
//  Created by Joe Manto on 3/6/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import CoreData

class Palette: NSManagedObject {
    
    @NSManaged var paletteDataToSave:NSData?
    var paletteData: [String:OPColorGroup]?
    @NSManaged var paletteName:String
    @NSManaged var paletteWeights:[Int]?
    @NSManaged var paletteKey:[String]?
    @NSManaged var curGroupIndex:Int
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(name:String,entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        self.paletteData = NSDictionary.init() as? [String : OPColorGroup]
        self.paletteName = name
        self.paletteWeights = Array(repeating: 0, count: 10)
        self.paletteKey = Array(repeating: "", count: 0)
        self.curGroupIndex = 0
    }
   
     init(name:String,data:[String:OPColorGroup],palWeights:[Int],palKeys:[String],entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        self.paletteData = data
        self.paletteName = name
        self.paletteWeights = palWeights
        self.paletteKey = palKeys
        self.curGroupIndex = 0
    }
    
    /*inits a palette object from an import from a local json file that contains palette data
     This method is used when the user first runs the application so it can intital install
     pre installed palettes*/
    convenience init(name:String,localFile:String,entity: NSEntityDescription, insertInto context: NSManagedObjectContext?){
        self.init(name: name, entity: entity, insertInto: context)
        let path = Bundle.main.url(forResource: localFile, withExtension: "json")
        let content = try? String(contentsOf: path!)
        
        let jsonWithObjectRoot = content!
        let data = jsonWithObjectRoot.data(using:.utf8)!
        do {
            let json = try JSONSerialization.jsonObject(with:data)
            if let dictionary = json as? [String: Any] {
                if let nestDictionary = dictionary["keys"] as? [String: Any]
                {
                    let keys:NSArray = nestDictionary["values"] as! NSArray
                    self.paletteKey = Array(repeating: "", count: keys.count)
                    for (index, i) in keys.enumerated(){
                        let stringVal:String = i as! String
                        self.paletteKey![index] = stringVal
                        //print(self.paletteKey[index])
                    }
                }
                if let nestDictionary = dictionary["weights"] as? [String: Any]
                {
                    let weights:NSArray = nestDictionary["values"] as! NSArray
                    for (index, i) in weights.enumerated(){
                        let stringVal:String = i as! String
                        self.paletteWeights![index] = Int(stringVal)!
                        //print(self.paletteWeights[index])
                    }
                }
                for  palKey in self.paletteKey!{
                    if let nestDictionary = dictionary[palKey] as? [String: Any]
                    {
                        let colorGroup:NSArray = nestDictionary["values"] as! NSArray
                        self.paletteData![palKey] = OPColorGroup.init(name: palKey)
                        for (index, i) in colorGroup.enumerated(){
                            self.paletteData![palKey]?.addColor(color: OPColor.init(hexString: i as! String, alpha: 1.0, weight: self.paletteWeights![index]))
                        }
                        self.paletteData![palKey]?.findHeaderColor()
                       // print(self.paletteData![palKey]?.getColorArray().count as Any ," ",self.paletteData![palKey]?.getName() as Any)
                    }
                }
            }
        } catch {
            print("Error parsing Json")
        }
    }
    
    //----------------Group Methodds-------------------------
    /*adds a colorgroup to the palatte data*/
    func addColorGroup(group:OPColorGroup) {
        paletteData![group.getName().lowercased()] = group
        //print(paletteData![group.getName().lowercased()])
        //print(paletteData)
        print("added colorGroup")
    }
    
    /*Adds an empty color group to the palette data with a name*/
    func addEmptyGroup(with name:String) {
        print("added empty group")
        paletteData![name] = OPColorGroup(name: name)
    }
    /*updates an existing color group value*/
    func updateColorGroup(group:OPColorGroup, for name:String){
        paletteData![name] = group
    }
    
    /*generates a simple color group used for when the user inserts a new color group in to a palette*/
    func generateTempColorGroup() -> OPColorGroup {
        let group = OPColorGroup(name:"Blank")
        let random = arc4random_uniform(201) + 30
        print(String(format:"%2X%2X%2X",random,random,random))
        group.addColor(color: OPColor(hexString: String(format:"%2X%2X%2X",random,random,random), weight: 50))
        paletteKey?.append("blank")
        self.addColorGroup(group: group)
        return group
    }
    
    //------------------CoreData Save------------------------
    /*Turns paletteData to BinaryData so it can be saved as an NSManaged objec in core data*/
    func saveColorData(){
        self.paletteDataToSave = NSKeyedArchiver.archivedData(withRootObject: self.paletteData!) as NSData
    }
    /*Core data saves the manangedObjectContext to the entitity*/
    func save() ->  Bool{
        saveColorData()
        
        if (managedObjectContext?.hasChanges)!{
            do{
                try managedObjectContext?.save()
                print("saved palette")
                return true
            }catch{
                print("failed to save")
                return false
            }
        }
        return false
    }
}
