//
//  AllGamesViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 9/20/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps


class AllGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var gameList: [Game] = []
    var selectedGame = Game()
    let ref = Database.database().reference()

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
        tableView.reloadData()
        spinner.startAnimating()
        ref.child("events").queryOrdered(byChild: "time").queryStarting(atValue: Date().timeIntervalSince1970).observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
               
               let gameId = snapshot.key
               //Format the date stored in the database
               let df = DateFormatter()
               
               let dateAsDate = Date(timeIntervalSince1970: dictionary["time"] as! Double)
               df.dateFormat = "EEE, MMM d"
               let justDate = df.string(from: dateAsDate)
               df.dateFormat = "h:mm a"
               let timeString = df.string(from: dateAsDate)
               
               //Set values of game variable from database information
               let sport = dictionary["sport"]
               let time = timeString
               let date = justDate
                
                self.ref.child("eventUsers").child("\(gameId)").observeSingleEvent(of: .value, with: {(snapshot) in
                   let eventUserDict = snapshot.value as? NSDictionary
                   let playersInGame = eventUserDict?.allKeys.count
                    
                   let spotsRemaining = dictionary["playerLimit"] as! Int - playersInGame!
                   
                   let locationDict = dictionary["location"] as! [String: [String:Any]]
                    
                   for(key, value) in locationDict {
                           let location = Location(key, value["availableSports"] as! [String], value["locationName"] as! String, value["longitude"] as! CLLocationDegrees, value["latitude"] as! CLLocationDegrees, value["image"] as! String)
                       let game = Game(gameId, sport as! String, time , date, dateAsDate, spotsRemaining, dictionary["playerLimit"] as! Int, location)
                       self.gameList.append(game)
                       self.tableView.reloadData()
                   }//End for
                })
            } //End if let dictionary
            self.spinner.stopAnimating()
        }) //End observe snapshot
    } //End fetchGames
    
    @IBAction func unwindtoGamesList(unwindSegue: UIStoryboardSegue){}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventDetails" {
            let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
            x.game = self.selectedGame
            x.cameFrom = "allGames"
        }
    }
}
