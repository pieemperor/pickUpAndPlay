//
//  Game.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 7/25/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit

class Game {
    var gameId: String
    var sport: String
    var time: String
    var date: String
    var dateTime: Date
    var spotsRemaining: Int
    var gameType: String
    var playerLimit: Int
    var locationId: String
    
    init(_ gameId: String, _ sport: String, _ time: String, _ date: String, _ dateTime: Date, _ spotsRemaining: Int, _ gameType: String, _ playerLimit: Int, _ locationId: String) {
        self.gameId = gameId
        self.sport = sport
        self.time = time
        self.date = date
        self.dateTime = dateTime
        self.spotsRemaining = spotsRemaining
        self.gameType = gameType
        self.playerLimit = playerLimit
        self.locationId = locationId
    }
    
    init() {
        self.gameId = ""
        self.sport = ""
        self.time = ""
        self.date = ""
        self.dateTime = Date()
        self.spotsRemaining = 0
        self.gameType = ""
        self.playerLimit = 0
        self.locationId = ""
    }
}
