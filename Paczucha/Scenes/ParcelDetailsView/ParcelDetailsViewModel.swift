//
//  ParcelDetailsViewModel.swift
//  Paczucha
//
//  Created by Darek on 03/10/2021.
//

import Foundation
import Combine

class ParcelDetailsViewModel {
    var statuses = CurrentValueSubject<[Status], Never>([])
    var parcel = CurrentValueSubject<Parcels?, Never>(nil)

    var cdHanlder: CDHandler
    var selectedParcelNumer: String?
    var subscriptions = Set<AnyCancellable>()

    init(){
        cdHanlder = CDHandler()
    }
    
    func fetchParcel(){
        guard let selectedParcelNumer = selectedParcelNumer else {
            return
        }
        cdHanlder.fetchSpecyficParcel(parcelNumber: selectedParcelNumer) { parcel in
            self.parcel.send(parcel)
        }
    }
    
    func fetchStatusesForParcel(){
        guard let selectedParcelNumer = selectedParcelNumer else {
            return
        }

        cdHanlder.fetchStatuses(forParcel: selectedParcelNumer) { statuses in
            var newStatuses: [Status] = []
            let group = DispatchGroup()
            for status in statuses {
                group.enter()
                self.cdHanlder.downloadStatusDetailsInfo(for: "impost", statusName: status.name)
                    .sink { statusDetails in
                        let newStatus = Status(status: status.name, date: status.date, agency: status.agency, statusDetails: statusDetails)
                        newStatuses.append(newStatus)
                        group.leave()
                    }.store(in: &self.subscriptions)
            }
            group.notify(queue: .main){
                self.statuses.send(newStatuses)
            }
        }

    }
}
