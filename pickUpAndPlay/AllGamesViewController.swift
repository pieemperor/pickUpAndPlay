//
//  AllGamesViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 9/20/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase

class AllGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var gameList: [Game] = []
    var selectedGame = Game()
    var locationToPass = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
            print("Cannot set cell's image")
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
        
        let myGreen = UIColor(red:46.0/255.0, green:204.0/255.0, blue:114.0/255.0, alpha:1.0)
        
        let greenRoundedView: UIView = UIView(frame: CGRect(x:0,y:5,width:tableView.frame.width, height:80))
        greenRoundedView.layer.backgroundColor = myGreen.cgColor
        greenRoundedView.layer.masksToBounds = false
        greenRoundedView.layer.cornerRadius = 10.0
        greenRoundedView.layer.shadowOpacity = 0.0
        
        cell.contentView.addSubview(greenRoundedView)
        cell.contentView.sendSubview(toBack: greenRoundedView)
    }

    
    func fetchGames() {
        gameList = [Game]()
        self.tableView.reloadData()
        let ref = Database.database().reference()
        self.spinner.startAnimating()
        ref.child("events").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                    
                        let gameId = snapshot.key
                        //Format the date stored in the database
                        let df = DateFormatter()
                        
                        let dateAsDate = Date(timeIntervalSince1970: dictionary["time"] as! Double)
                        df.dateFormat = "MMMM d"
                        let justDate = df.string(from: dateAsDate)
                        df.dateFormat = "h:mm a"
                        let timeString = df.string(from: dateAsDate)
                        
                        if dateAsDate > Date() {
                        //Set values of game variable from database information
                        let sport = dictionary["sport"]
                        let time = timeString
                        let date = justDate
                        let playersInGame = dictionary["playerList"]?.count
                        let spotsRemaining = dictionary["playerLimit"] as! Int - playersInGame!
                        let gameType = dictionary["gameType"]
                        self.locationToPass = dictionary["location"] as! String
                
                        
                        let game = Game(gameId, sport as! String, time , date, dateAsDate, spotsRemaining, gameType as! String)
                        self.gameList.append(game)
                        self.tableView.reloadData()
                    }
                    //Sort games by date
                    self.gameList.sort(by: {$0.dateTime.compare($1.dateTime) == .orderedAscending })
            } //End if let dictionary
            self.spinner.stopAnimating()
        }) //End observe snapshot
    } //End fetchGames
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventDetails" {
            let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
            x.game = self.selectedGame
            x.cameFrom = "userHome"
        }
    }
}
