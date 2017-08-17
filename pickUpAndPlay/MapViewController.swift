//
//  MapViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/16/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//
//TODO: Create Filter function
//TODO: Create multi sport marker
//TODO: Add CPA courts and Tennis Courts
//TODO: Add intermediate screen for the CPA and Tennis courts

import UIKit
import GoogleMaps
import Firebase

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    
    //selected location that will be sent in prepare for segue
    var locationToPass = Location()
    
    // the coordinates are reversed from the url
    //Create Location objects with list of sports available at those locations, name, coordinates, and Image
    let locations = [
        Location(["basketball"], "Davis Basketball Court", -82.3639571, 36.3035454, UIImage(named: "davisBBall")!),
        Location(["basketball"], "Buc Ridge Basketball Court", -82.3592807, 36.2997041, UIImage(named: "bucRidgeBBall")!),
        Location(["volleyball"], "Davis Beach Volleyball Court (Outside)", -82.3637902, 36.3035529, UIImage(named: "davisVBall")!),
        Location(["volleyball"], "Buc Ridge Beach Volleyball Court", -82.3592885, 36.3000031, UIImage(named: "brvbCourt")!),
        Location(["volleyball"], "Campus Ridge Beach Volleyball Court", -82.3746753, 36.2954593, UIImage(named: "campusRidgeVBCourt")!),
        Location(["soccer", "ultimate"], "CPA Front Yard", -82.373986, 36.301344, UIImage(named: "cpaFrontYard")!),
        Location(["ultimate"], "CPA Side Yard", -82.3748875, 36.300691, UIImage(named: "cpaSideYard")!),
        Location(["ultimate"], "The Quad", -82.3698213, 36.3029164, UIImage(named: "quad")!),
        Location(["ultimate"], "Tri-Hall Field", -82.3642177, 36.3038811, UIImage(named: "triHallField")!),
        Location(["discGolf"], "ETSU Disc Golf Course", -82.362922, 36.30044, UIImage(named: "etsuDiscGolf")!)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        navigationController?.navigationBar.tintColor = .white
    }
    
    //on click for each marker
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let selectedLocation = marker.userData as! Location
        self.locationToPass = selectedLocation
        self.performSegue(withIdentifier: "goToSchedule", sender: self)
        return true
    }
    
    func setupMap() {
        
        //google map stuff
        let camera = GMSCameraPosition.camera(withLatitude:36.3035454 , longitude: -82.363957, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        self.view = mapView
        
        
        
        //make markers from locations array and set icons
        for location in locations {
            let state_marker = GMSMarker()
            state_marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
            state_marker.title = location.name
            state_marker.snippet = location.name
            state_marker.map = mapView
            state_marker.userData = location
            
            if location.availableSports.count == 1 {
                if location.availableSports.contains("basketball") {
                    state_marker.icon = UIImage(named: "basketballMarker")
                } else if location.availableSports.contains("volleyball") {
                    state_marker.icon = UIImage(named: "volleyballMarker")
                } else if location.availableSports.contains("soccer") {
                    state_marker.icon = UIImage(named: "soccerMarker")
                } else if location.availableSports.contains("tennis") {
                    state_marker.icon = UIImage(named: "tennisMarker")
                } else if location.availableSports.contains("discGolf") {
                    state_marker.icon = UIImage(named: "discGolfMarker")
                } else if location.availableSports.contains("ultimate") {
                    state_marker.icon = UIImage(named: "ultimateMarker")
                } else {
                    print ("No sport selected")
                }
            } else if location.availableSports.count > 1 {
                state_marker.icon = UIImage(named: "multiSportMarker")
            }
        }
    }
    
    //send location to schedule controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSchedule" {
            let x : scheduleController = segue.destination as! scheduleController
            x.passedLocation = self.locationToPass
        }
    }
}
