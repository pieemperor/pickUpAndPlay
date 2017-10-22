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

class MapViewController: UIViewController{
    @IBOutlet weak var gamesListView: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
    }
    
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            gamesListView.isHidden = true
            mapView.isHidden = false
        case 1:
            gamesListView.isHidden = false
            mapView.isHidden = true
        default:
            break;
        }
    }
}
