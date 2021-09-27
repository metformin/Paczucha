//
//  parcelDetailsViewController.swift
//  Paczucha
//
//  Created by Darek on 14/10/2020.
//

import Foundation
import UIKit

class parcelDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var parcelNameLabel: UILabel!

    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    var selectedParcelNumber: String?
    var statuses = [Statuses]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        parcelNameLabel.text = selectedParcelNumber
        
        
        
        if CDHandler.fetchStatuses(parcelNumber: selectedParcelNumber!) != nil{
            statuses = CDHandler.fetchStatuses(parcelNumber: selectedParcelNumber!)!

            self.tableView.reloadData()
        }
       // print("Parcel number test: ", parcelNumber ?? "xd" )
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath) as! detailsCellController
  

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pl_PL")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+2:00")
        dateFormatter.dateFormat = "HH:mm"

        let finalDate = dateFormatter.string(from: statuses[indexPath.row].date!)
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let finalTime = dateFormatter.string(from: statuses[indexPath.row].date!)

        cell.dateLabel.text = finalDate
        cell.timeLabel.text = finalTime

        cell.statusLabel.text = statuses[indexPath.row].status!

        
        
        
        
        
        
        
        return cell
    }
    
    
}


class detailsCellController: UITableViewCell{
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
}
