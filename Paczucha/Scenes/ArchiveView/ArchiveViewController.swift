//
//  ArchiveViewController.swift
//  Paczucha
//
//  Created by Darek on 06/10/2021.
//

import UIKit

class ArchiveViewController: UIViewController {
    
    // MARK: - Constants
    let archiveViewModel = ArchiveViewModel()
    
    // MARK: - IBOulets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        archiveViewModel.statuses
            .sink { _ in
                self.tableView.reloadData()
            }.store(in: &archiveViewModel.subscriptions)
        
        archiveViewModel.parcels
            .sink { _ in
                self.tableView.reloadData()
            } .store(in: &archiveViewModel.subscriptions)
        archiveViewModel.fetchAllParcelsFromDB()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showParcelDetails"{
            if let destVC = segue.destination as? ParcelDetailsViewController {
                destVC.selectedParcelNumber = archiveViewModel.passParcelNumber
            }
        }
    }
}

extension ArchiveViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        archiveViewModel.parcels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as! cellController
        
        cell.labelName.text = archiveViewModel.parcels.value[indexPath.row].parcelName
        cell.labelNumber.text = archiveViewModel.parcels.value[indexPath.row].parcelNumber
        cell.imageCell.image = UIImage(named: archiveViewModel.parcels.value[indexPath.row].parcelCompany ?? "impost")
        cell.parcelNumber = archiveViewModel.parcels.value[indexPath.row].parcelNumber
        if let labelStatus = archiveViewModel.statuses.value[archiveViewModel.parcels.value[indexPath.row]]?.first{
            cell.labelStatus.text = labelStatus.statusDetails?.title ?? "xD"
        }
        
        cell.contentViewCell.layer.cornerRadius = 10
        cell.contentViewCell.layer.masksToBounds = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! cellController
        print ("DEBUG: Selected parcel number:" + (cell.labelName.text ?? ""))
        archiveViewModel.passParcelNumber = cell.parcelNumber
        performSegue(withIdentifier: "showParcelDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! cellController

        //MoveToActive:
        let moveToActiveAction = UIContextualAction(style: .normal, title: "") { action, sourceView, completionHandler in
            self.archiveViewModel.moveParcelToActive(parcelNumber: cell.parcelNumber)
            completionHandler(true)
        }
        moveToActiveAction.backgroundColor = .green
        let moveToArchiveImage = UIImage(named: "moveToArchiveActionIcon")
        moveToActiveAction.image = moveToArchiveImage
        
        //DeletaAction:
        let deleteAction = UIContextualAction(style: .destructive, title: "") { action, sourceView, completionHandler in
            self.archiveViewModel.deleteParcelAndStatuses(for: cell.parcelNumber){
                self.archiveViewModel.fetchAllParcelsFromDB()
                completionHandler(true)
            }
        }
        let deleteImage = UIImage(named: "deleteActionIcon")
        deleteAction.image = deleteImage
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, moveToActiveAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }
}
