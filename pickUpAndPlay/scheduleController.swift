//
//  scheduleController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/18/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FacebookLogin
import AVFoundation
import GoogleMaps
import AlamofireImage
import Alamofire

class scheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var upcomingGamesLabel: UILabel!
    @IBOutlet weak var tableSpinner: UIActivityIndicatorView!
   
    //location sent from EmbeddedMapViewController
    var passedLocation = Location()
    var gameList = [Game]()
    //timeArray gets sent to the createGameController to make sure the user doesn't create a game at the same time at the same place
    var timeArray = [Double]()
    //selectedGame gets passed to the eventDetails controller
    var selectedGame = Game()
    var eventsHandle = DatabaseHandle()
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeArray = [Double]()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.separatorColor = .clear
        locationName.text = passedLocation.name
        fetchLocationImage()
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        fetchGames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ref.removeObserver(withHandle: eventsHandle)
    }
    
    //MARK: Table View Delegate methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection: Int)-> Int{
        // an int that represents the number of games being held at this location
        return gameList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath) as? GameTableViewCell
        
        if gameList.count > 0 {
        let game = gameList[indexPath.row]
        //Sets all of the cell's outlets to the properties stored in game
        cell?.setGame(game)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGame = self.gameList[indexPath.row]
        self.performSegue(withIdentifier: "goToEventDetails", sender: self)
    }
    
    //MARK: Table View appearance setup / rigging
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let gtvCell = cell as? GameTableViewCell {
            gtvCell.setSizeAndColor(tableView.frame.width)
        }
    }
    
    private func setupButtons() {
        createGameButton.layer.cornerRadius = createGameButton.frame.height/2
        
        locationName.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    }//End setupButtons
    
    //MARK: TODO: Make table only display games once on creation and make spinner stop spinning when there's no data
    func fetchGames() {
        gameList = [Game]()
        tableView.reloadData()
        tableSpinner.startAnimating()
        let currentDate = Date().timeIntervalSince1970
        eventsHandle = ref.child("locationEvents/\(passedLocation.locationId)").queryOrdered(byChild: "time").queryStarting(atValue: currentDate).observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                    let gameId = snapshot.key
                    //Format the date stored in the database
                    let df = DateFormatter()
                    
                    let dateAsDate = Date(timeIntervalSince1970: dictionary["time"] as! Double)

                    df.dateFormat = "EEE, MMM d"
                    let justDate = df.string(from: dateAsDate)
                    df.dateFormat = "h:mm a"
                    let timeString = df.string(from: dateAsDate)
                
                    self.ref.child("eventUsers").child("\(gameId)").observeSingleEvent(of: .value, with: {(snapshot) in
                        let eventUserDict = snapshot.value as? NSDictionary
                        let numberOfPlayers = eventUserDict?.allKeys.count

                        if numberOfPlayers! > 0 {
                            //Set values of game variable from database information
                            let sport = dictionary["sport"]
                            let time = timeString
                            let date = justDate
                            let spotsRemaining = dictionary["playerLimit"] as! Int - numberOfPlayers!
                            
                            let locationDict = dictionary["location"] as! [String: [String:Any]]
                            
                                for(key, value) in locationDict {
                                    let location = Location(key, value["availableSports"] as! [String], value["locationName"] as! String, value["longitude"] as! CLLocationDegrees, value["latitude"] as! CLLocationDegrees, value["image"] as! String)
                                    let game = Game(gameId, sport as! String, time , date, dateAsDate, spotsRemaining, dictionary["playerLimit"] as! Int, location)
                                    self.gameList.append(game)
                                    self.tableView.reloadData()
                                }//End for
                        }//End if let numberOfPlayers
                })//End ref eventUsers
            } //End if let dictionary
            self.tableSpinner.stopAnimating()
        }) //End observe snapshot
    } //End fetchGames
    
    func fetchLocationImage() {
        let imageURL = passedLocation.locationImageURL
            let url = URL(string: imageURL)
        self.locationImage.af_setImage(withURL: url!, placeholderImage: UIImage(named: "profileBG"))
    }
    
    @IBAction func unwindToSchedule(unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateGame" {
            
            // send the the location to the createGame view
            let x : createGameController = segue.destination as! createGameController
            x.location = self.passedLocation
            x.timeArray = self.timeArray
        }
        
        if segue.identifier == "goToEventDetails"{
            let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
            x.game = self.selectedGame
            x.cameFrom = "schedule"
        }
    }//End prepare for segue
} // End class
