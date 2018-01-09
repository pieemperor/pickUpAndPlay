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
        
        let game = gameList[indexPath.row]
        
        //Sets all of the cell's outlets to the properties stored in game
        cell?.setGame(game)
        
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

    
    func fetchGames() {
        gameList = [Game]()
        self.tableView.reloadData()
        let ref = Database.database().reference()
        self.spinner.startAnimating()
        ref.child("events").queryOrdered(byChild: "time").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                    
                        let gameId = snapshot.key
                        //Format the date stored in the database
                        let df = DateFormatter()
                        
                        let dateAsDate = Date(timeIntervalSince1970: dictionary["time"] as! Double)
                        df.dateFormat = "EEE, MMM d"
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
                
                        
                        let game = Game(gameId, sport as! String, time , date, dateAsDate, spotsRemaining, gameType as! String, dictionary["playerLimit"] as! Int, dictionary["location"] as! String)
                        self.gameList.append(game)
                        self.tableView.reloadData()
                    }
            } //End if let dictionary
            self.spinner.stopAnimating()
        }) //End observe snapshot
    } //End fetchGames
    
    @IBAction func unwindtoGamesList(unwindSegue: UIStoryboardSegue){}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventDetails" {
            let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
            x.game = self.selectedGame
            x.cameFrom = "gamesList"
        }
    }
}
