//
//  CoreData.swift
//  Paczucha
//
//  Created by Darek on 08/10/2020.
//

import Foundation
import CoreData
import Combine
import UIKit


class CDHandler: NSObject{
    let inpostStatusDetailsInfo = InpostStatusExtended()
    
    
    private func getContest() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    public func saveData(parcelNumber:String, parcelName: String, parcelCompany:String){
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
    
     func fetchParcels() -> [Parcels]?{
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
    
    func fetchSpecyficParcel(parcelNumber: String, completion: @escaping ((Parcels)) -> Void){
       let context = getContest()
       var parcel: [Parcels]?
        let fetchRequest = NSFetchRequest<Parcels>(entityName: "Parcels")
        fetchRequest.predicate = NSPredicate(format: "parcelNumber == %@ ",parcelNumber)

       do {
           parcel = try context.fetch(fetchRequest)
           guard let parcel = parcel else {
               return
           }
           completion(parcel.first!)
       } catch {
           return
       }
   }
    
    public func fetchStatuses(forParcel number: String, completion: @escaping ((_ statuses: [Status]) -> Void)){
        let context = getContest()
        let fetchRequest = NSFetchRequest<Statuses>(entityName: "Statuses")
        fetchRequest.predicate = NSPredicate(format: "ofParcel.parcelNumber == %@ ", number)
        let sdSortDate = NSSortDescriptor.init(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sdSortDate]
        
        do {
            let request = try context.fetch(fetchRequest)
            var statuses: [Status] = []
            if (request.count) > 0{
                for status in request {
                    print("Fetched Status from DB: ", status.status ?? "No status")
                    statuses.append(Status(status: status.status!, date: status.date!, agency: status.agency, statusDetails: nil))
                }
            }
            completion(statuses)
        } catch {
            print("Fetch failed")
            return
        }
    }
    
    public func updateStatuses(downloadedStatuses: [Status], parcelNumber:String){
        let context = getContest()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Parcels")
        fetchRequest.predicate = NSPredicate(format: "parcelNumber == %@ ",parcelNumber)
        
        var fetchedStatusesFromDB: [Status] = []
        fetchStatuses(forParcel: parcelNumber) { statuses in
            for status in statuses {
                fetchedStatusesFromDB.append((Status(status: status.name, date: status.date, agency: status.agency, statusDetails: nil)))
            }
        }
        
        do {
            let results = try context.fetch(fetchRequest) as? [Parcels]
            
            for downloadedStatus in downloadedStatuses {
                print("DEBUG: Checking now status: \(downloadedStatus)")

                if !fetchedStatusesFromDB.contains(where: {$0.name == downloadedStatus.name}) {
                    print("Status is not in the database -  saved new status")

                    let status = Statuses(context: context)
                    status.status = downloadedStatus.name
                    status.date = downloadedStatus.date
                    status.agency = downloadedStatus.agency

                    if results?.count != 0{
                        results![0].addToStatuses(status)
                    }
                } else {
                    print("Status is already in the database - not saved")
                }
            }
        } catch {
            return
        }
        
        do {
            try context.save()
            print("Context saved")
        } catch {
            print("Context save failed")
        }
    }
    
    func downloadStatusDetailsInfo(for Company: String, statusName: String) -> Future<statusDetails?, Never>{
        Future { promise in
            switch Company{
            case "impost":
                self.inpostStatusDetailsInfo.downloadInpostStatusExtended(statusName: statusName) { statusInfo in
                    guard let statusInfo = statusInfo else {
                        return promise(.success(nil))
                    }
                    let statusDet = statusDetails(title: statusInfo.title, describtion: statusInfo.itemDescription)
                    promise(.success(statusDet))
                }
                break
            case "pp":
                return promise(.success(nil))
                
            default:
                return promise(.success(nil))
                
            }
        }
    }

}
