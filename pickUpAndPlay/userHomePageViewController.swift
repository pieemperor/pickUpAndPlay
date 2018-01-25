//
//  userHomePageViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 6/1/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleMaps

class userHomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableSpinner: UIActivityIndicatorView!
    
    var ref = Database.database().reference()
    var gameList: [Game] = []
    var selectedGame = Game()
    var authenticatedUser = Player()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
        fetchGames()
    }
    
    //MARK: Table View Delegate methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection: Int)-> Int{
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
    
    //MARK: Firebase functions
    func getUserInfo () {
        //Get the user's first and last name from Firebase
        if let userID = Auth.auth().currentUser?.uid {
            spinner.startAnimating()
            ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let firstName = value?["firstName"] as? String ?? "Didn't work"
                let lastName = value?["lastName"] as? String ?? "Didn't work"
                self.nameLabel.text = firstName + " " + lastName
                
                let profilePicURL = value?["photo"] as? String? ?? "Didn't work"
                
                
                if profilePicURL != "", profilePicURL != nil {
                    let url = URL(string: profilePicURL!)
                    let data = try? Data(contentsOf: url!)
                    self.authenticatedUser = Player(snapshot.key, firstName, lastName, UIImage(data: data!)!, profilePicURL!)
                    self.profilePic.image = UIImage(data : data!)
                    
                    self.spinner.stopAnimating()
                } else {
                    self.profilePic.image = UIImage(named: "defaultProfilePic")
                    self.spinner.stopAnimating()

                    print("No profile pic URL")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }//End getUserInfo
    
    func fetchGames() {
        gameList = [Game]()
        tableView.reloadData()
        tableSpinner.startAnimating()
        let currentDate = Date().timeIntervalSince1970
        ref.child("userEvents/\((Auth.auth().currentUser?.uid)!)").queryOrdered(byChild: "time").queryStarting(atValue: currentDate).observe(.childAdded, with: {(snapshot) in

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
               let playersInGame = dictionary["playerList"]?.count
               let spotsRemaining = dictionary["playerLimit"] as! Int - playersInGame!
                
               let locationDict = dictionary["location"] as! [String: [String:Any]]
               
               for(key, value) in locationDict {
                   let location = Location(key, value["availableSports"] as! [String], value["locationName"] as! String, value["longitude"] as! CLLocationDegrees, value["latitude"] as! CLLocationDegrees, value["image"] as! String)
                   let game = Game(gameId, sport as! String, time , date, dateAsDate, spotsRemaining, dictionary["playerLimit"] as! Int, location)
                   self.gameList.append(game)
                   self.tableView.reloadData()
               }//End for
            } //End if let dictionary
            self.tableSpinner.stopAnimating()
        }) //End observe snapshot
    } //End fetchGames
    
    private func setupButtons() {
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        backgroundImage.clipsToBounds = true
    }
    
    @IBAction func unwindtoProfile(unwindSegue: UIStoryboardSegue){}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventDetails" {
            let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
            x.game = self.selectedGame
            x.cameFrom = "userHome"
        }
    }//End prepare for segue
}//End class
