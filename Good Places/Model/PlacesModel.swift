//
//  PlacesModel.swift
//  Good Places
//
//  Created by Alexander on 29.09.2021.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var image: UIImage?
    
   let goodPlacesName = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes", "Speak Easy", "Morris Pub", "Вкусные истории", "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    func savePlaces(){
        for place in goodPlacesName {
           let newPlace = Place()
           newPlace.name = place
        }
    }
}
