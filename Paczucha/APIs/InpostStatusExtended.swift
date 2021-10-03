//
//  InpostStatusExtended.swift
//  Paczucha
//
//  Created by Darek on 02/10/2021.
//

import Foundation


// MARK: - Inpost Status Extended
struct InpostStatusExtendedModel: Codable {
    let items: [Item]
}

// MARK: - Item
struct Item: Codable {
    let name, title, itemDescription: String

    enum CodingKeys: String, CodingKey {
        case name, title
        case itemDescription = "description"
    }
}

class InpostStatusExtended {
    let url = URL(string: "https://api-shipx-pl.easypack24.net/v1/statuses")
    
    func downloadInpostStatusExtended(statusName: String, completion: @escaping ((_ statusInfo: Item?) -> Void)){
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let parsedJSON = try jsonDecoder.decode(InpostStatusExtendedModel.self, from: data)
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
