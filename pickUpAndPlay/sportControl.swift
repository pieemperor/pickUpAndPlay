//
//  sportControl.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 7/23/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//
/*
import UIKit

@IBDesignable class sportControl: UIStackView {
    
    //MARK: Properties
    private var sportButtons = [UIButton]()
    var selectedSport = String()
    @IBInspectable var buttonSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var buttonCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    

    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    func sportButtonTapped(button: UIButton) {
        guard let index = sportButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the sportButtons array: \(sportButtons)")
        }
        
        // Calculate the rating of the selected button
        let sportSelected =
        
        if sportSelected == selectedSport {
            // If the selected star represents the current rating, reset the rating to 0.
            selectedSport = ""
        } else {
            // Otherwise set the rating to the selected star
            selectedSport = sportSelected
        }
    }
    
    //MARK: Private Functions
    private func setupButtons() {

        
        // clear any existing buttons
        for button in sportButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        sportButtons.removeAll()
        
        
        // Load Button Images
        let bundle = Bundle(for: type(of: self))
        
        let defaultSoccerButton = UIImage(named: "soccerButton", in: bundle, compatibleWith: self.traitCollection)
        let selectedSoccerButton = UIImage(named: "selectedSoccerButton", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<buttonCount {
            let button = UIButton()
            
            // Set the button images
            button.setImage(defaultSoccerButton, for: .normal)
            button.setImage(selectedSoccerButton, for: .selected)
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(sportControl.sportButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            sportButtons.append(button)
        }
    }
    private func updateButtonSelectionStates() {
        for (index, button) in sportButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            if sportButtons[index] == selectedSport {
                button.isSelected = true
            }
        }
    }
}*/
