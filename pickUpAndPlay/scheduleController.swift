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

class scheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var upcomingGamesLabel: UILabel!
    @IBOutlet weak var tableSpinner: UIActivityIndicatorView!
   
    //name of location sent from mapViewController
    var passedLocation = Location()
    //Sports available at that location - passed from mapViewController
    var gameList = [Game]()
    var timeArray = [String]()
    var selectedGame = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeArray = [String]()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.separatorColor = .clear
        locationName.text = passedLocation.name
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        fetchGames()
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
        
        //set the cell's labels to their corresponding values for each game in the gameList array
        cell?.timeLabel.text = game.time
        cell?.dateLabel.text = game.date
        cell?.spotsRemainingLabel.text = String(game.spotsRemaining)
        
        //Check to see what sport the game is and set the cell's image appropriately
        if game.sport == "soccer" {
            cell?.sportImage.image = UIImage(named: "soccerBall")
        } else if game.sport == "basketball" {
            cell?.sportImage.image = UIImage(named: "basketball")
        } else if game.sport == "volleyball" {
            cell?.sportImage.image = UIImage(named: "volleyball")
        } else if game.sport == "ultimate" {
            cell?.sportImage.image = UIImage(named: "ultimate")
        } else if game.sport == "discGolf" {
            cell?.sportImage.image = UIImage(named: "discGolf")
        } else if game.sport == "tennis" {
            cell?.sportImage.image = UIImage(named: "tennis")
        } else {
            print("That is not a valid sport")
        }
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
    
    private func setupButtons() {
        createGameButton.layer.cornerRadius = createGameButton.frame.height/2
        locationImage.image = passedLocation.locationImage
        locationImage.clipsToBounds = true
        
        locationName.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    }//End setupButtons
    
    func fetchGames() {
        gameList = [Game]()
        let ref = Database.database().reference()
        tableSpinner.startAnimating()
        ref.child("events").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let location = dictionary["location"] as! String
                if location == self.passedLocation.name {
                    
                    let gameId = snapshot.key
                    //Format the date stored in the database
                    let df = DateFormatter()
                    
                    df.dateFormat = "MMM d, yyyy, h:mm a"
                    let dateAsDate = df.date(from: dictionary["time"] as! String)
                    df.dateFormat = "MMMM d"
                    let justDate = df.string(from: dateAsDate!)
                    df.dateFormat = "h:mm a"
                    let timeString = df.string(from: dateAsDate!)
                    
                    if let numberOfPlayers = dictionary["playerList"]?.count {
                        
                        if dateAsDate! > Date() {
                            //Set values of game variable from database information
                            let sport = dictionary["sport"]
                            let time = timeString
                            let date = justDate
                            let spotsRemaining = dictionary["playerLimit"] as! Int - numberOfPlayers
                            let gameType = dictionary["gameType"]
                            
                            let game = Game(gameId, sport as! String, time , date, dateAsDate!, spotsRemaining, gameType as! String)
                            self.gameList.append(game)
                            self.timeArray.append(dictionary["time"] as! String)
                            self.tableView.reloadData()
                    }
                } //End if location
                }
                //Sort games by date
                self.gameList.sort(by: {$0.dateTime.compare($1.dateTime) == .orderedAscending })
            } //End if let dictionary
            self.tableSpinner.stopAnimating()
        }) //End observe snapshot
    } //End fetchGames
    
    @IBAction func unwindToSchedule(unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateGame" {
            
            // send the name of the location to the createGame view
            let x : createGameController = segue.destination as! createGameController
            x.location = self.passedLocation
            x.timeArray = self.timeArray
        }
        
        if segue.identifier == "goToEventDetails"{
            let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
            x.game = self.selectedGame
            x.passedLocation = self.passedLocation
            x.cameFrom = "schedule"
        }
    }//End prepare for segue
} // End class
