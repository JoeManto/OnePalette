//
//  OPUtil.swift
//  OnePalette
//
//  Created by Joe Manto on 6/8/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

class OPUtil: NSObject {
    
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
    
    static func deleteMangedObject(dataObject:NSManagedObject, insertInto context: NSManagedObjectContext!) {
        context.delete(dataObject)
        do {
            try context.save()
        } catch {
            print("failed to remove data object")
        }
    }
    
    static func printSavedData(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
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
}
