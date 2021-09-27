//
//  HomeViewModel.swift
//  Paczucha
//
//  Created by Darek on 27/09/2021.
//

import Foundation
import Combine

class HomeViewModel{
    
    // MARK: - Variables-
    var status:Array<String> = []
    var parcels = CurrentValueSubject<[Parcels],Never>([])
    var cdHandler = CDHandler()
    var passParcelNumber: String?
    
    func downloadAllParcels(){
        if cdHandler.fetchData() != nil{
            parcels.send(cdHandler.fetchData()!)
        }
    }
    
    func downloadStatusesForAllParcels() {

            let myGroup = DispatchGroup()

        for parcel in parcels.value {
                myGroup.enter()

                switch parcel.parcelCompany {
                case "impost":
                    APIInpost(parcelNumber: parcel.parcelNumber!) {
                        print("KONIEC API INPOST")
                        myGroup.leave()
                    }
                    break
                case "pp":
                    ppAPI(parcelNumber: parcel.parcelNumber!) {
                        myGroup.leave()
                    }
                    break
                default:
                    print("Błąd pobierania statusów z DB")
                    myGroup.leave()
                }
        }
        myGroup.notify(queue: .main) {
            print("Finished all parcels data request - reload data")
        }
    }
}


