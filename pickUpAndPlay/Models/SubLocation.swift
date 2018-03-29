//
//  SubLocation.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 9/25/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import Foundation

class SubLocation {
    var availableSports: [String]
    var name: String
    var locationImageURL: String
    
    init(){
        self.availableSports = []
        self.name = ""
        self.locationImageURL = ""
    }
    
    init(_ availableSports: [String], _ name: String, _ locationImageURL: String) {
        self.availableSports = availableSports
        self.name = name
        self.locationImageURL = locationImageURL
    }
}

