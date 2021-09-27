//
//  ViewController.swift
//  Paczucha
//
//  Created by Darek on 05/10/2020.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var labelMain: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "addPresent", sender: self)
    }
    

    @IBAction func testButton(_ sender: Any) {
        print("Test Button activated")
        tableView.reloadData()
        
    }
    
    
    
    var status:Array<String> = []
    var parcels = [Parcels]()

    fileprivate var passParcelNumber: String?
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return parcels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as! cellController
        
        cell.labelName.text = String(parcels[indexPath.row].parcelName!)
        cell.parcelNumber = parcels[indexPath.row].parcelNumber
        cell.imageCell.image = UIImage(named: parcels[indexPath.row].parcelCompany ?? "impost")
        
        
        let lastStatus: [Statuses] = CDHandler.fetchStatuses(parcelNumber: cell.parcelNumber)!
        if lastStatus.count > 0 {
            let lastStatusStatus = lastStatus.first?.status
            let lastStatusDate = lastStatus.first?.date
            let lastStatusAgency = lastStatus.first?.agency
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pl_PL")
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+2:00")
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            let finalLastStatusDate = dateFormatter.string(from: lastStatusDate!)



            cell.labelStatus.text = lastStatusStatus
            cell.labelStatusTime.text = finalLastStatusDate + "\n" + (lastStatusAgency ?? "")
        }

        cell.contentViewCell.layer.cornerRadius = 10
        cell.contentViewCell.layer.masksToBounds = true
        
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! cellController
        print ("DEBUG: Selected parcel number:" + (cell.labelName.text ?? ""))
        passParcelNumber = cell.parcelNumber
        performSegue(withIdentifier: "showParcelDetails", sender: self)
    }
    



    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self


        
        
        if CDHandler.fetchData() != nil{
            parcels = CDHandler.fetchData()!
            downloadStatusesForAllParcels()
                
          //  self.tableView.reloadData()
                
            
        }

                
        

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        
        // Do any additional setup after loading the view.
    }


    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showParcelDetails"{
            if let destVC = segue.destination as? parcelDetailsViewController {
                destVC.selectedParcelNumber = passParcelNumber
            }

        }
    }
    func downloadStatusesForAllParcels() {
        
            
            
            let myGroup = DispatchGroup()




            for parcel in self.parcels {
                myGroup.enter()


                switch parcel.parcelCompany {
                case "impost":
                    APIInpost(parcelNumber: parcel.parcelNumber!) {
                        print("KONIEC API INPOST")
                        myGroup.leave()
                    }
                    break
                case "pp":
                    ppAPI(parcelNumber: parcel.parcelNumber!) {
                        myGroup.leave()
                    }
                    break
                default:
                    print("Błąd pobierania statusów z DB")
                    myGroup.leave()

                }
             

        }
        myGroup.notify(queue: .main) {
            print("Finished all parcels data request - reload data")

            self.tableView.reloadData()
        }
    }

}



class cellController: UITableViewCell{
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var labelStatusTime: UILabel!
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var contentViewCell: UIView!
    
    var parcelNumber: String!
    
    
}


