//
//  TableViewController.swift
//  Good Places
//
//  Created by Alexander on 28.09.2021.
//

import UIKit

class MainViewController: UITableViewController {

//    var goodPlaces = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return goodPlaces.count
//    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
//
//        let place = goodPlaces[indexPath.row]
//
//        cell.nameLabel?.text = place.name
//        cell.locationLabel?.text = place.location
//        cell.typeLabel?.text = place.type
//
//        if place.image == nil {
//            cell.placeImage?.image = UIImage(named: place.placeImage!)
//        } else {
//            cell.placeImage?.image = place.image
//        }
//
//        cell.placeImage?.layer.cornerRadius = cell.placeImage.frame.size.height / 2
//        cell.placeImage?.clipsToBounds = true
//
//        return cell
//    }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.saveNewPlace()
//        goodPlaces.append(newPlaceVC.newPlace!)
        tableView.reloadData()
    }
}
