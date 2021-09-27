//
//  InpostAPI.swift
//  Paczucha
//
//  Created by Darek on 05/10/2020.
//

import Foundation




func APIInpost(parcelNumber: String, completion: @escaping (() -> Void)){

    
    var InpostCompleteData = [[Any]]()

    print("Tablica INPOST COMPLETE DATA przed pobraniem czegokolwiek: ", InpostCompleteData.count)
    // MARK: - InpostTrackDetails
    struct TrackingDetail: Codable {
        let status: String
        let datetime: String
        let agency: String?

    }

    struct Inpost: Codable {
        let trackingDetails: [TrackingDetail]
        enum CodingKeys: String, CodingKey {
            case trackingDetails = "tracking_details"
        }
    }
    
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
                        
                        print("Data do sformatowania jako string:", trackingDetails.datetime)
                        let formattedDate = dateFormatter.date(from: trackingDetails.datetime)
                        print(formattedDate!)
                        
                        InpostCompleteData.append([trackingDetails.status, formattedDate!, trackingDetails.agency])
                        
                        print(InpostCompleteData)

                       

                    }
                    DispatchQueue.global().async {
                        print("API INPOST POBRAŁ I PRZEKAZAŁ DO ZAPISANIA STĘPUJĄCĄ ILOŚĆ STATUSÓW:", InpostCompleteData.count)
                        CDHandler().updateStatuses(fetchedStatuses: InpostCompleteData, parcelNumber: parcelNumber)
                    completion()
                    }





                } catch {
                    print(error)
                }
            }
        }.resume()
    }


    
}



