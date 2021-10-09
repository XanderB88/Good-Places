//
//  CustomTableViewCell.swift
//  Good Places
//
//  Created by Alexander on 29.09.2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControlView!
}
