//
//  StorageManager.swift
//  Good Places
//
//  Created by Alexander on 05.10.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}
