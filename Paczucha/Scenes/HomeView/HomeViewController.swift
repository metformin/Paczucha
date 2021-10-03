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
        homeViewModel.fetchAllParcelsFromDB()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65.0

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        homeViewModel.statuses
            .sink { _ in
                self.tableView.reloadData()
            }.store(in: &subscriptions)
        
        homeViewModel.fetchAllParcelsFromDB()
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
        if let labelStatus = homeViewModel.statuses.value[homeViewModel.parcels.value[indexPath.row]]?.first{
            cell.labelStatus.text = labelStatus.statusDetails?.title ?? "xD"
        }
        
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


