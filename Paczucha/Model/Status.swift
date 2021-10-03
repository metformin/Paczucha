//
//  File.swift
//  Paczucha
//
//  Created by Darek on 29/09/2021.
//

import Foundation

struct Status {
    var name: String
    var date: Date
    var agency: String?
    var statusDetails: statusDetails?
    
    init(status: String, date: Date, agency: String?, statusDetails: statusDetails?){
        self.name = status
        self.date = date
        self.agency = agency
        self.statusDetails = statusDetails
    }
}

struct statusDetails{
    var title: String
    var describtion: String
}



