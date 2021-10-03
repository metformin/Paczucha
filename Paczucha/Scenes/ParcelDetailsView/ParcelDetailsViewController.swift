//
//  parcelDetailsViewController.swift
//  Paczucha
//
//  Created by Darek on 14/10/2020.
//

import Foundation
import UIKit

class ParcelDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var parcelNameLabel: UILabel!
    @IBOutlet var parcelNumberLabel: UILabel!
    var parcelDetailsViewModel = ParcelDetailsViewModel()
    var selectedParcelNumber: String?

    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        parcelDetailsViewModel = ParcelDetailsViewModel()
        parcelDetailsViewModel.selectedParcelNumer = selectedParcelNumber
        parcelNumberLabel.text = selectedParcelNumber
        
        tableView.delegate = self
        tableView.dataSource = self
        parcelNameLabel.text = selectedParcelNumber
        
        parcelDetailsViewModel.statuses.sink { _ in
            self.tableView.reloadData()
        }.store(in: &parcelDetailsViewModel.subscriptions)
        parcelDetailsViewModel.parcel.sink {[weak self] parcel in
            if parcel != nil {
                self?.parcelNameLabel.text = parcel?.parcelName
            }
        }.store(in: &parcelDetailsViewModel.subscriptions)
        parcelDetailsViewModel.fetchStatusesForParcel()
        parcelDetailsViewModel.fetchParcel()

    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parcelDetailsViewModel.statuses.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath) as! detailsCellController
  
        print(parcelDetailsViewModel.statuses.value[indexPath.row])
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pl_PL")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+2:00")
        dateFormatter.dateFormat = "HH:mm"

        let finalDate = dateFormatter.string(from: parcelDetailsViewModel.statuses.value[indexPath.row].date)
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let finalTime = dateFormatter.string(from: parcelDetailsViewModel.statuses.value[indexPath.row].date)

        cell.dateLabel.text = finalDate
        cell.timeLabel.text = finalTime
        cell.statusLabel.text = parcelDetailsViewModel.statuses.value[indexPath.row].statusDetails?.title
        cell.descLabel.text = parcelDetailsViewModel.statuses.value[indexPath.row].statusDetails?.describtion

       
        return cell
    }
}


class detailsCellController: UITableViewCell{
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
}
