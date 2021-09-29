//
//  PlacesModel.swift
//  Good Places
//
//  Created by Alexander on 29.09.2021.
//

import Foundation

struct Place {
    
    var name: String
    var location: String
    var type: String
    var image: String
    
    static let goodPlacesName = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes", "Speak Easy", "Morris Pub", "Вкусные истории", "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        
        for place in goodPlacesName {
            places.append(Place(name: place, location: "Ufa", type: "Restaurant", image: place))
        }
        
        return places
    }
}
