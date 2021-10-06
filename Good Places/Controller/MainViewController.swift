//
//  TableViewController.swift
//  Good Places
//
//  Created by Alexander on 28.09.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
  
    var goodPlaces: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        Add items from data base
        goodPlaces = realm.objects(Place.self)
    }
    
    //      MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = goodPlaces[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
}
    
    // MARK: - Table view data source
    extension MainViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return goodPlaces.isEmpty ? 0 : goodPlaces.count
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            
            let place = goodPlaces[indexPath.row]
            
            cell.nameLabel.text = place.name
            cell.locationLabel.text = place.location
            cell.typeLabel.text = place.type
            cell.placeImage.image = UIImage(data: place.imageData!)
            
            cell.placeImage?.layer.cornerRadius = cell.placeImage.frame.size.height / 2
            cell.placeImage?.clipsToBounds = true
            
            return cell
        }
    }

    // MARK: - Table view delegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = goodPlaces[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
  
    
   
