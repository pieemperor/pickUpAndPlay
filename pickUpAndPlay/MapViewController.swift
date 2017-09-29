//
//  MapViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/16/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class MapViewController: UIViewController, GMSMapViewDelegate {
    //selected location that will be sent in prepare for segue
    var locationToPass = Location()
    var ref = Database.database().reference()
    var locations = [Location]()
    var mapView = GMSMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLocations()
        setupMap()
        navigationController?.navigationBar.tintColor = .white
    }
    
    //on click for each marker
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let selectedLocation = marker.userData as! Location
        self.locationToPass = selectedLocation
        
        if selectedLocation.subLocations != nil{
            self.performSegue(withIdentifier: "goToSelectSpecificLocation", sender: self)
        } else {
            self.performSegue(withIdentifier: "goToSchedule", sender: self)
        }
        return true
    }
    
    func setupMap() {
        
        //google map stuff
        let camera = GMSCameraPosition.camera(withLatitude:36.3035454 , longitude: -82.363957, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        self.view = mapView
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
        
        func fetchLocations(){
            ref.child("locations").observe(.childAdded, with: {(snapshot) in
                if let dict = snapshot.value as? [String : AnyObject] {
                    var subLocationsObjectArray = [SubLocation]()
                    if let subLocations = dict["subLocations"]{
                        
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: subLocations, options: .prettyPrinted)
                            // here "jsonData" is the dictionary encoded in JSON data
                            print("jsonData: ", jsonData, "\n\n\n\n")
                        
                            if let decoded = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : [String : Any]]{
                                for(_, value) in decoded {
                                    let subLocation = SubLocation(value["availableSports"] as! [String], value["locationName"] as! String, value["image"] as! String)
                                    subLocationsObjectArray.append(subLocation)
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                        subLocationsObjectArray = subLocationsObjectArray.sorted{ $0.name < $1.name }
                        let location = Location(dict["availableSports"] as! [String], dict["locationName"] as! String, dict["longitude"] as! CLLocationDegrees, dict["latitude"] as! CLLocationDegrees, dict["image"] as! String, subLocationsObjectArray)
                        self.locations.append(location)
                        
                        let state_marker = GMSMarker()
                        state_marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
                        state_marker.title = location.name
                        state_marker.snippet = location.name
                        state_marker.map = self.mapView
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
                    } else {
                        let location = Location(dict["availableSports"] as! [String], dict["locationName"] as! String, dict["longitude"] as! CLLocationDegrees, dict["latitude"] as! CLLocationDegrees, dict["image"] as! String)
                        self.locations.append(location)
                        
                        let state_marker = GMSMarker()
                        state_marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
                        state_marker.title = location.name
                        state_marker.snippet = location.name
                        state_marker.map = self.mapView
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

                    }//End else
                }//End if let subLocations = dict["subLocations"]{
            })//End observe locations
        }//End fetchLocations
    
    //send location to schedule controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSchedule" {
            let x : scheduleController = segue.destination as! scheduleController
            x.passedLocation = self.locationToPass
        } else if segue.identifier == "goToSelectSpecificLocation" {
            let x : SelectSpecificLocationViewController = segue.destination as! SelectSpecificLocationViewController
            x.passedLocation = self.locationToPass
        }
    }
}
