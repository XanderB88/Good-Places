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

}
