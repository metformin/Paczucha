//
//  ViewController.swift
//  Paczucha
//
//  Created by Darek on 05/10/2020.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    // MARK: - Variables
    let homeViewModel = HomeViewModel()
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - IBOulets
    @IBOutlet var labelMain: UILabel!
    @IBOutlet var tableView: UITableView!
    
    // MARK: - IBActions
    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "addPresent", sender: self)
    }
    @IBAction func refreshButton(_ sender: Any) {
        print("Test Button activated")
        homeViewModel.downloadAllParcels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        homeViewModel.parcels
            .sink { _ in
                self.tableView.reloadData()
            }.store(in: &subscriptions)
        
        homeViewModel.downloadAllParcels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showParcelDetails"{
            if let destVC = segue.destination as? ParcelDetailsViewController {
                destVC.selectedParcelNumber = homeViewModel.passParcelNumber
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.parcels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as! cellController
        
        cell.labelName.text = homeViewModel.parcels.value[indexPath.row].parcelName
        cell.labelNumber.text = homeViewModel.parcels.value[indexPath.row].parcelNumber
        cell.imageCell.image = UIImage(named: homeViewModel.parcels.value[indexPath.row].parcelCompany ?? "impost")
        cell.parcelNumber = homeViewModel.parcels.value[indexPath.row].parcelNumber

        
//        let lastStatus: [Statuses] = CDHandler.fetchStatuses(parcelNumber: cell.parcelNumber)!
//        if lastStatus.count > 0 {
//            let lastStatusStatus = lastStatus.first?.status
//            let lastStatusDate = lastStatus.first?.date
//            let lastStatusAgency = lastStatus.first?.agency
//            let dateFormatter = DateFormatter()
//            dateFormatter.locale = Locale(identifier: "pl_PL")
//            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+2:00")
//            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
//            let finalLastStatusDate = dateFormatter.string(from: lastStatusDate!)
//
//
//
//            cell.labelStatus.text = lastStatusStatus
//            cell.labelStatusTime.text = finalLastStatusDate + "\n" + (lastStatusAgency ?? "")
//        }

        cell.contentViewCell.layer.cornerRadius = 10
        cell.contentViewCell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! cellController
        print ("DEBUG: Selected parcel number:" + (cell.labelName.text ?? ""))
        homeViewModel.passParcelNumber = cell.parcelNumber
        performSegue(withIdentifier: "showParcelDetails", sender: self)
    }
}



class cellController: UITableViewCell{
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var labelNumber: UILabel!
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var contentViewCell: UIView!
    
    var parcelNumber: String!
}


