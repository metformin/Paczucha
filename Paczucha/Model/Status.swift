//
//  File.swift
//  Paczucha
//
//  Created by Darek on 29/09/2021.
//

import Foundation

class Status {
    var status: String
    var date: Date
    var agency: String?
    
    init(status: String, date: Date, agency: String?){
        self.status = status
        self.agency = agency
        self.date = date
    }
}
