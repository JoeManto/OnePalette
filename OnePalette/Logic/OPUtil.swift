//
//  OPUtil.swift
//  OnePalette
//
//  Created by Joe Manto on 6/8/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

class OPUtil: NSObject {
    static func genIdOfLength(len: Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 1...len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return String(randomString).trimmingCharacters(in: NSCharacterSet.whitespaces) as NSString
    }
    
    
    static func flushData(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!){
        let Deleterequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        //Deleterequest.predicate = NSPredicate(format: "paletteName = %@", "Material")
        do {
            let result = try context.fetch(Deleterequest)
            for data in result as! [NSManagedObject] {
                context.delete(data)
                try context.save()
            }
        } catch {
            print("Failed to remove data")
        }
    }
    
    static func deleteFaultingData(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
        let Deleterequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        //Deleterequest.predicate = NSPredicate(format: "paletteName = %@", "Material")
        do {
            let result = try context.fetch(Deleterequest)
            for data in result as! [NSManagedObject] {
                if(data.isFault){
                    context.delete(data)
                    try context.save()
                }
            }
        } catch {
            print("Failed to remove data")
        }
    }
    
    static func deleteMangedObject(dataObject:NSManagedObject, insertInto context: NSManagedObjectContext!){
        context.delete(dataObject)
        do{
        try context.save()
        }catch{print("failed to remove data object")}
    }
    
    static func printSavedData(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data)
            }
        } catch {
            print("Failed to remove data")
        }
    }
    /*retrives a pal entity from the managedContent with a name predicate*/
    static func retrievePaletteForName(name:String) ->NSArray{
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {return NSArray.init()}
        let context = appDelegate.persistentContainer.viewContext

        let palettesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        palettesFetch.predicate = NSPredicate(format: "paletteName = %@", name)
        
        do {
            let fetchedPalettes = try context.fetch(palettesFetch)
            print("Searching For Palettes Of Name %@",name)
            return fetchedPalettes as NSArray;
        } catch {
            fatalError("Failed to fetch palettes: \(error)")
        }
        return NSArray.init()
    }
    
    
}
