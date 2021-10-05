//
//  PlacesModel.swift
//  Good Places
//
//  Created by Alexander on 29.09.2021.
//

import RealmSwift

class Place: Object {
    
    @Persisted var name = ""
    @Persisted var location: String?
    @Persisted var type: String?
    @Persisted var imageData: Data?
    
    let goodPlacesName = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes", "Speak Easy", "Morris Pub", "Вкусные истории", "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    func savePlaces(){
        for place in goodPlacesName {
            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else { return }
            
            let newPlace = Place()
            
            newPlace.name = place
            newPlace.location = "Samara"
            newPlace.type = "Restaurant"
            newPlace.imageData = imageData
        }
    }
}
