//
//  CoreDataStore.swift
//  Location
//
//  Created by BSSADM on 16/03/21.
//

import Foundation
import CoreData
import UIKit
class CoreDataStore : NSObject {
    
    class func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveLocationDetails(latitude:String,longitude:String,appState:String,city:String,time: String,locationStatus: String,completionHandler: @escaping (_ success: Bool) -> Void) -> Bool{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "LocationDetails", in: context)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)
        manageObject.setValue(latitude, forKey: "latitude")
        manageObject.setValue(longitude, forKey: "longitude")
        manageObject.setValue(appState, forKey: "appState")
        manageObject.setValue(city, forKey: "city")
        manageObject.setValue(time, forKey: "time")
        manageObject.setValue(locationStatus, forKey: "locationStatus")
        
        do {
            try context.save()
            print("Saved")
            completionHandler(true)
            return true
        } catch {
            
            print("Failed saving")
            completionHandler(false)
            return false
        }
        
    }
    
    class func fetchLocations()->[LocationDetails]{
        let context = getContext()
        var locations: [LocationDetails]? = nil
        
        do {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationDetails")
            request.returnsDistinctResults = true
            request.returnsObjectsAsFaults = false
            locations = try context.fetch(request) as? [LocationDetails]
            return locations!
        } catch {
            
            return locations!
        }
        
    }
    class func updateLocation(time:String) -> [LocationDetails]?{
        let context = getContext()
        let locationPredicate = NSPredicate(format: "time == %@",time)
        var updateLocation: [LocationDetails]? = nil
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationDetails")
        request.returnsDistinctResults = true
        request.returnsObjectsAsFaults = false
        request.predicate = locationPredicate
        do{
            updateLocation =  try context.fetch(request) as? [LocationDetails]
            return updateLocation!
            
        }catch{
            print("Error")
            return nil
        }
        
    }
    
    class func deleteAllData(completionHandler: @escaping (_ success: Bool) -> Void) {
        
        let managedContext =  self.getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationDetails")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results{
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
            completionHandler(true)
        } catch let error as NSError {
            print(error)
            completionHandler(false)
        }
    }
    
    class func deletePendingRecord(time:String) -> Bool{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationDetails")
        var predicate1 = NSPredicate()
        predicate1 = NSPredicate(format: "time == %@", time)
        request.predicate = predicate1
        let delete = NSBatchDeleteRequest(fetchRequest:request)
        
        do {
            try self.getContext().execute(delete)
            try self.getContext().save()
            return true
            
        }catch{
            print("Error")
            return false
        }
        
    }
    
}
