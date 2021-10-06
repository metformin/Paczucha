//
//  InpostStatusExtended.swift
//  Paczucha
//
//  Created by Darek on 02/10/2021.
//

import Foundation


// MARK: - Inpost Status Extended
struct InpostStatusDetailsModel: Codable {
    let items: [StatusDetails]
}

// MARK: - Item
struct StatusDetails: Codable {
    let name, title, itemDescription: String

    enum CodingKeys: String, CodingKey {
        case name, title
        case itemDescription = "description"
    }
}

class InpostStatusDetails {
    private let url = URL(string: "https://api-shipx-pl.easypack24.net/v1/statuses")
    
    func downloadInpostStatusExtended(statusName: String, completion: @escaping ((_ statusInfo: StatusDetails?) -> Void)){
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let parsedJSON = try jsonDecoder.decode(InpostStatusDetailsModel.self, from: data)
                    let status = parsedJSON.items.filter({$0.name == statusName})
                    if status.count > 0 {
                        completion(status.first)
                    } else {
                        completion(nil)
                    }
            
                } catch {
                    print("DEBUG: Error dataTast URL SESSION \(error)")
                    completion(nil)
                }
            }
        }.resume()
    }
}
