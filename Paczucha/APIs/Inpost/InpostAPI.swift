//
//  InpostAPI.swift
//  Paczucha
//
//  Created by Darek on 05/10/2020.
//

import Foundation

// MARK: - InpostTrackDetails
private struct TrackingDetail: Codable {
    let status: String
    let datetime: String
    let agency: String?

}

private struct Inpost: Codable {
    let trackingDetails: [TrackingDetail]
    enum CodingKeys: String, CodingKey {
        case trackingDetails = "tracking_details"
    }
}

public func InpostAPI(parcelNumber: String, completion: @escaping (() -> Void)){

    var InpostCompleteData = [Status]()
    
    if let url = URL(string: "https://api-shipx-pl.easypack24.net/v1/tracking/" + parcelNumber){
        URLSession.shared.dataTask(with: url){data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let parsedJSON = try jsonDecoder.decode(Inpost.self, from: data)
                    
                    for trackingDetails in parsedJSON.trackingDetails{
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "pl_PL")
                        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+2:00")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000'ZZZZZ"
                        
                        let formattedDate = dateFormatter.date(from: trackingDetails.datetime)
                        print(formattedDate!)
                        
                        guard let formattedDate = formattedDate else {
                            return
                        }
                        
                        InpostCompleteData.append(Status(status: trackingDetails.status,
                                                         date: formattedDate,
                                                         agency: trackingDetails.agency, statusDetails: nil))
                        
                        print(InpostCompleteData)

                    }
                    DispatchQueue.global().async {
                        CDHandler().updateStatuses(downloadedStatuses: InpostCompleteData, parcelNumber: parcelNumber)
                    completion()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }


    
}



