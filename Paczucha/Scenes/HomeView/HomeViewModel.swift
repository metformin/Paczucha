//
//  HomeViewModel.swift
//  Paczucha
//
//  Created by Darek on 27/09/2021.
//

import Foundation
import Combine

class HomeViewModel{
    
    // MARK: - Variables
    var statuses = CurrentValueSubject<[Parcels : [Status]],Never>([:])
    var parcels = CurrentValueSubject<[Parcels],Never>([])
    var subscriptions = Set<AnyCancellable>()
    var cdHandler = CDHandler()
    var passParcelNumber: String?
    
    init(){
        parcels.sink { _ in
            self.downloadNewStatusesForAllParcelsToDB {
                self.fetchAllStatusesForAllParcels()
            }
        }.store(in: &subscriptions)
        
        statuses
            .sink { results in
                print("DEBUG: All statuses dic: \(results)")
            }.store(in: &subscriptions)
    }
    
    func fetchAllParcelsFromDB(){
        if cdHandler.fetchParcels() != nil{
            parcels.send(cdHandler.fetchParcels()!)
        }
    }
    func fetchAllStatusesForAllParcels(){
        let myGroup = DispatchGroup()
        var allStatuses: [Parcels : [Status]] = [:]
        
        for parcel in parcels.value {
            myGroup.enter()
            var parcelStatuses: [Status]?
            guard let parcelNumber = parcel.parcelNumber else {
                myGroup.leave()
                return
            }
            cdHandler.fetchStatuses(forParcel: parcelNumber) { statuses in
                parcelStatuses = statuses
                if let parcelStatuses = parcelStatuses {
                    print("DEBUG: parcelStatuses: \(parcelStatuses)")
                    allStatuses.updateValue(parcelStatuses, forKey: parcel)
                }
                myGroup.leave()
            }

        }
        myGroup.notify(queue: .main) {
            print("Finished all statuses data request")
            self.statuses.send(allStatuses)
        }
    }
    func downloadNewStatusesForAllParcelsToDB(completion: @escaping () -> Void) {
        let myGroup = DispatchGroup()
        for parcel in parcels.value {
                myGroup.enter()

                switch parcel.parcelCompany {
                case "impost":
                    InpostAPI(parcelNumber: parcel.parcelNumber!) {
                        print("END OF API INPOST")
                        myGroup.leave()
                    }
                    break
                case "pp":
                    PocztaPolskaAPI(parcelNumber: parcel.parcelNumber!) {
                        myGroup.leave()
                    }
                    break
                default:
                    myGroup.leave()
                }
        }
        myGroup.notify(queue: .main) {
            print("Finished all parcels data request - reload data")
            completion()
        }
    }
}


