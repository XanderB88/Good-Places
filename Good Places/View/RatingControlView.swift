//
//  RatingControl.swift
//  Good Places
//
//  Created by Alexander on 08.10.2021.
//

import UIKit

@IBDesignable class RatingControlView: UIStackView {
    // MARK: - Properties
    private var ratingButtons = [UIButton]()
    var rating = 0
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButton()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButton()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: - Setup button with constrants
    fileprivate func setupButton() {
        //        Clear the view befor adding buttons on the view
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        //        Fill the view by buttons
        for _ in 0..<starCount {
            //            Create a button
            let button = UIButton()
            button.backgroundColor = .red
            
            //            Add constraints to the button
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //        Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            //            Add the new button in rating button array
            ratingButtons.append(button)
        }
    }
    
    // MARK: - Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        print("Rating button was tapped 👍")
    }
}
