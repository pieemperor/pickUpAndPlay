//
//  Location.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 8/1/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//
import GoogleMaps

class Location {
    var availableSports: [String]
    var name: String
    var long: CLLocationDegrees
    var lat: CLLocationDegrees
    var locationImageURL: String
    var subLocations: [SubLocation]?

    init(){
        self.availableSports = []
        self.name = ""
        self.long = 0
        self.lat = 0
        self.locationImageURL = ""
        self.subLocations = [SubLocation()]
    }
    
    init(_ availableSports: [String], _ name: String, _ long: CLLocationDegrees, _ lat: CLLocationDegrees, _ locationImageURL: String) {
        self.availableSports = availableSports
        self.name = name
        self.long = long
        self.lat = lat
        self.locationImageURL = locationImageURL
    }
    
    init(_ availableSports: [String], _ name: String, _ long: CLLocationDegrees, _ lat: CLLocationDegrees, _ locationImageURL: String, _ subLocations: [SubLocation]) {
        self.availableSports = availableSports
        self.name = name
        self.long = long
        self.lat = lat
        self.locationImageURL = locationImageURL
        self.subLocations = subLocations
    }
}
