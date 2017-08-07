//
//  Player.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 7/26/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//

import UIKit

class Player {
    
    var playerId: String
    var firstName: String
    var lastName: String
    var profilePicture: UIImage
    
    init(_ playerId: String, _ firstName: String, _ lastName: String, _ profilePicture: UIImage) {
        self.playerId = playerId
        self.firstName = firstName
        self.lastName = lastName
        self.profilePicture = profilePicture
    }
    
    init() {
        self.playerId = ""
        self.firstName = ""
        self.lastName = ""
        self.profilePicture = UIImage()
    }
}
