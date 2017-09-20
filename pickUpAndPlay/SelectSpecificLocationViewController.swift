//
//  SelectSpecificLocationViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 8/23/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase

class SelectSpecificLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = Database.database().reference()
    var passedLocation = Location()
    var possibleLocations = [Location]()
    var selectedLocation = Location()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocations()
        setLocationImage()
        setupLabel()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupLocations() {
        if passedLocation.name == "CPA" {
            possibleLocations = [
                Location(["basketball"], "CPA Court 1", -82.3745716, 36.2998606, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FCPA%20Court%201?alt=media&token=1dec1627-1be3-485d-9fdf-15a3b1d73de5"),
                Location(["basketball"], "CPA Court 2", -82.3745716, 36.2998606, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FCPA%20Court%202?alt=media&token=4bf1c073-180d-4790-bf05-d26ab4a0d718"),
                Location(["basketball", "volleyball"], "CPA Court 3", -82.3745716, 36.2998606, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FCPA%20Court%203?alt=media&token=30e31846-915a-40b5-8979-92bff7fafbc7"),
                Location(["basketball", "soccer"], "CPA Court 4", -82.3745716, 36.2998606, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FCPA%20Court%204?alt=media&token=614c86a6-4abd-449c-ab24-09f85c1d95a1")
            ]
            
                ref.child("locations").updateChildValues(["subLocations": ["-KtSfjvhB1CzfEnCYnwV", "-KtSfjtJRyD65v4gx0GM", "-KtSfjtPKJZpW5wSMnuR", "-KtSfjtUWqJqjKTGcuh-"]])
        } else if passedLocation.name == "ETSU Tennis Courts" {
            possibleLocations = [
                Location(["tennis"], "ETSU Tennis Court 1", -82.3772667, 36.2974996, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FETSU%20Tennis%20Courts?alt=media&token=b13d40e1-bcd8-43c2-8a0d-5d84ba701c62"),
                Location(["tennis"], "ETSU Tennis Court 2", -82.3772667, 36.2974996, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FETSU%20Tennis%20Courts?alt=media&token=b13d40e1-bcd8-43c2-8a0d-5d84ba701c62"),
                Location(["tennis"], "ETSU Tennis Court 3", -82.3772667, 36.2974996, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FETSU%20Tennis%20Courts?alt=media&token=b13d40e1-bcd8-43c2-8a0d-5d84ba701c62"),
                Location(["tennis"], "ETSU Tennis Court 4", -82.3772667, 36.2974996, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FETSU%20Tennis%20Courts?alt=media&token=b13d40e1-bcd8-43c2-8a0d-5d84ba701c62"),
                Location(["tennis"], "ETSU Tennis Court 5", -82.3772667, 36.2974996, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FETSU%20Tennis%20Courts?alt=media&token=b13d40e1-bcd8-43c2-8a0d-5d84ba701c62"),
                Location(["tennis"], "ETSU Tennis Court 6", -82.3772667, 36.2974996, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/locationImages%2FETSU%20Tennis%20Courts?alt=media&token=b13d40e1-bcd8-43c2-8a0d-5d84ba701c62")
            ]
        }
    }
    
    private func setupLabel() {
        locationName.text = passedLocation.name
        locationName.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    }
    
    //MARK: Table View Delegate methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection: Int)-> Int{
        // an int that represents the number of games being held at this location
        return possibleLocations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = possibleLocations[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedLocation = self.possibleLocations[indexPath.row]
        self.performSegue(withIdentifier: "goToScheduleController", sender: self)
    }
    
    //MARK: Table View appearance setup / rigging
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
        let myGreen = UIColor(displayP3Red:46.0/255.0, green:204.0/255.0, blue:114.0/255.0, alpha:1.0)
        
        let greenRoundedView: UIView = UIView(frame: CGRect(x:0,y:5,width:tableView.frame.width, height:80))
        greenRoundedView.layer.backgroundColor = myGreen.cgColor
        greenRoundedView.layer.masksToBounds = false
        greenRoundedView.layer.cornerRadius = 10.0
        greenRoundedView.layer.shadowOpacity = 0.0
        
        cell.contentView.addSubview(greenRoundedView)
        cell.contentView.sendSubview(toBack: greenRoundedView)
    }
    
    
    //send location to schedule controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToScheduleController" {
            let x : scheduleController = segue.destination as! scheduleController
            x.passedLocation = self.selectedLocation
        }
    }

    func setLocationImage() {
        if passedLocation.name == "CPA" {
            locationImage.image = UIImage(named: "CPA")
        } else if passedLocation.name == "ETSU Tennis Courts" {
            locationImage.image = UIImage(named: "tennisCourts")
        }
    }
}//End SelectSpecificLocationViewController
