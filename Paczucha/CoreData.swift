//
//  CoreData.swift
//  Paczucha
//
//  Created by Darek on 08/10/2020.
//

import Foundation
import CoreData
import UIKit


class CDHandler: NSObject{
    private class func getContest() -> NSManagedObjectContext{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    public class func saveData(parcelNumber:String, parcelName: String, parcelCompany:String){
        let context = getContest()
        let entity = NSEntityDescription.entity(forEntityName: "Parcels", in: context)
        let newParcel = NSManagedObject(entity: entity!, insertInto: context)
        newParcel.setValue(parcelNumber, forKey: "parcelNumber")
        newParcel.setValue(parcelName, forKey: "parcelName")
        newParcel.setValue(parcelCompany, forKey: "parcelCompany")
        
        do {
            try context.save()
            print("DEBUG: New parcel saved")
        } catch {
            print("DEBUG: Error during add new parcel")
        }
        
    }
    
    public class func fetchData() -> [Parcels]?{
        let context = getContest()
        var parcels: [Parcels]? =  nil
        var request = NSFetchRequest<NSFetchRequestResult>()
        request = Parcels.fetchRequest()
        request.returnsObjectsAsFaults =  false

        do {
            parcels = try context.fetch(request) as? [Parcels] ?? []
            print("DEBUG: Data fetched from DB")
            return parcels
        } catch {
            return parcels
        }
    }
    
    public class func fetchStatuses(parcelNumber: String) -> [Statuses]?{
        let context = getContest()
        var statuses: [Statuses]? = nil
        let fetchRequest = NSFetchRequest<Statuses>(entityName: "Statuses")
        fetchRequest.predicate = NSPredicate(format: "ofParcel.parcelNumber == %@ ",parcelNumber)
        let sdSortDate = NSSortDescriptor.init(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sdSortDate]
        
        do {
            statuses = try context.fetch(fetchRequest)
            
            if (statuses?.count)! > 0{
                for status in statuses! {
                    print("POBRANY STATUS: ", status.status!)
                }
            }
            return statuses

            
        } catch {
            print("Fetch failed")
            return statuses
        }
    }
    
    public class func updateStatuses(fetchedStatuses: [[Any]],parcelNumber:String){
        let context = getContest()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Parcels")
        fetchRequest.predicate = NSPredicate(format: "parcelNumber == %@ ",parcelNumber)
        
        let statusesAlreadySavedInDB = NSFetchRequest<NSFetchRequestResult>(entityName: "Statuses")
        statusesAlreadySavedInDB.predicate = NSPredicate(format: "ofParcel.parcelNumber == %@ ",parcelNumber)
        
        do {
            let results = try context.fetch(fetchRequest) as? [Parcels]
            let downloadStatusesAlreadySavedInDB = try context.fetch(statusesAlreadySavedInDB) as? [String]
            
            for fetchedStatus in fetchedStatuses {
                
                if downloadStatusesAlreadySavedInDB?.contains(fetchedStatus[0] as! String) == false {
                    print("Status is not in the database -  saved new status")

                    let status = Statuses(context: context)
                    status.status = fetchedStatus[0] as! String
                    status.date = fetchedStatus[1] as! Date
                    
                    if fetchedStatus.count == 3 {
                    status.agency = fetchedStatus[2] as? String 
                    }




                    if results?.count != 0{
                        results![0].addToStatuses(status)
                    }
                } else {
                    print("Status is already in the database - not saved")
                }

            }
            
        } catch {
            print("Fetch failed")
        }
        do {
            try context.save()
            print("Context saved")
            DispatchQueue.main.sync {

            }
        } catch {
            print("Context save failed")
        }


    }

    
}
