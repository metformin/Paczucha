//
//  ArchiveViewModel.swift
//  Paczucha
//
//  Created by Darek on 06/10/2021.
//

import Foundation
import Combine

class ArchiveViewModel {
    var statuses = CurrentValueSubject<[Parcels : [Status]],Never>([:])
    var parcels = CurrentValueSubject<[Parcels],Never>([])
    var subscriptions = Set<AnyCancellable>()
    var cdHandler = CDHandler()
    var inpostStatusExtendedTest = InpostStatusDetails()
    var passParcelNumber: String?

    
    init(){
        parcels.sink { parcels in
            if parcels.count > 0 {
                    self.fetchAllStatusesForAllParcels()
            }
        }.store(in: &subscriptions)
        
        statuses
            .sink { results in
                print("DEBUG: All statuses dic: \(results)")

            }.store(in: &subscriptions)
    }
    
    func fetchAllParcelsFromDB(){
        if let fetchedParcels = cdHandler.fetchParcels(areArchived: true){
            parcels.send(fetchedParcels)
        }
    }
    func fetchAllStatusesForAllParcels(){
        let allParcelsGroup = DispatchGroup()
        var allStatuses: [Parcels : [Status]] = [:]
        
        for parcel in parcels.value {
            allParcelsGroup.enter()
            var parcelStatuses: [Status] = []
            guard let parcelNumber = parcel.parcelNumber else {
                allParcelsGroup.leave()
                return
            }
            cdHandler.fetchStatuses(forParcel: parcelNumber) { statuses in
                let allStatusesGroup = DispatchGroup()

                for status in statuses {
                    allStatusesGroup.enter()
                    
                    self.inpostStatusExtendedTest.downloadInpostStatusExtended(statusName: status.name) { statusInfo in
                        var parcelStatus: Status
                        let statusDet = statusDetails(title: statusInfo!.title, describtion: statusInfo!.itemDescription)
                        parcelStatus = Status(status: status.name, date: status.date, agency: status.agency, statusDetails: statusDet)
                            parcelStatuses.append(parcelStatus)
                            print("DEBUG2: New status added")
                        
                    allStatusesGroup.leave()
                    }
                }
                
                allStatusesGroup.notify(queue: .main){
                    print("DEBUG2: parcelStatuses: \(parcelStatuses)")
                    let sortedParcelStatuses = parcelStatuses.sorted { status1, status2 in
                        status1.date > status2.date
                    }
                        allStatuses.updateValue(sortedParcelStatuses, forKey: parcel)
                    
                    allParcelsGroup.leave()
                }
            }
        }
        allParcelsGroup.notify(queue: .main) {
            print("DEBUG2: Finished all statuses data request: \(allStatuses)")
            self.statuses.send(allStatuses)
        }
    }
    func deleteParcelAndStatuses(for parcelNumber: String, completion: @escaping () -> Void){
        print("DEBUG: Delete parcel: \(parcelNumber)")
        cdHandler.deleteSpecyficParcelAndStatuses(parcelNumber: parcelNumber) {
            completion()
        }
    }
    func moveParcelToActive(parcelNumber: String){
        print("DEBUG: Move parcel to archive: \(parcelNumber)")
        cdHandler.moveParcelToActive(parcelNumber: parcelNumber)
        fetchAllParcelsFromDB()
    }
}
