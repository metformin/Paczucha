//
//  addParcelViewController.swift
//  Paczucha
//
//  Created by Darek on 08/10/2020.
//

import Foundation
import UIKit

class AddParcelViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var companies: [[String]] = [
                                    ["Inpost","impost"],
                                    ["DPD", "dpd"],
                                    ["Poczta Polska","pp"],
                                    ["Inpost","impost"],
                                    ["DPD", "dpd"],
                                    ["Poczta Polska","pp"]
                                ]
    
    var parcelCompany:String? = nil
    
    var isSelected: IndexPath? {
        didSet{
            
            let contentOffset = companyCollectionView.contentOffset
            companyCollectionView.reloadData()
            companyCollectionView.layoutIfNeeded()
            companyCollectionView.setContentOffset(contentOffset, animated: false)
            companyCollectionView.scrollToItem(at: isSelected!, at: .centeredHorizontally, animated: true)


        }
    }
    

    @IBOutlet var companyCollectionView: UICollectionView!
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet var parcelNumberTextField: UITextField!
    @IBOutlet var parcelNameTextField: UITextField!
    
    @IBAction func addParcelButton(_ sender: Any) {
        if parcelCompany != nil && parcelNumberTextField != nil && parcelNameTextField != nil{
            CDHandler().saveData(parcelNumber: parcelNumberTextField.text!, parcelName: parcelNameTextField.text!, parcelCompany: parcelCompany!)
        
            performSegue(withIdentifier: "toHomeAfterAddingParcelToDB", sender: self)
        } else {
            print("Wypełnij wszystkie wymagane pola.")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyCollectionView.delegate = self
        companyCollectionView.dataSource = self
        companyCollectionView.allowsMultipleSelection = false;
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return companies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = companyCollectionView.dequeueReusableCell(withReuseIdentifier: "companyCell", for: indexPath) as! companyCellController
        
        cell.companyNameLabel.text = companies[indexPath.row][0]
        cell.companyImage.image = UIImage.init(named: companies[indexPath.row][1])
        cell.companyNameForDB = companies[indexPath.row][1]
        
        if indexPath == isSelected {
            cell.layer.borderWidth = 2
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor(red: 45.0/255.0, green: 187.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
            }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = companyCollectionView.cellForItem(at: indexPath) as! companyCellController
        parcelCompany = cell.companyNameForDB
        isSelected = indexPath
    }
}


class companyCellController: UICollectionViewCell{
    
    @IBOutlet var companyImage: UIImageView!
    @IBOutlet var companyNameLabel: UILabel!
    var companyNameForDB: String? = nil
    
}
