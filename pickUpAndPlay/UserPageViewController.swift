//
//  UserPageViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 6/1/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase

class UserPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userId = ""
    var gameList: [Game] = []
    var selectedGame = Game()
    var ref: DatabaseReference! = Database.database().reference()
    
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableSpinner: UIActivityIndicatorView!
    @IBOutlet weak var userSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupButtons()
        getUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    
    func setupButtons() {
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        backgroundImage.clipsToBounds = true
    }
    
    func getUserInfo () {
        //Get the user's first and last name from Firebase
        userSpinner.startAnimating()
        ref.child("users").child(self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? "Didn't work"
            let lastName = value?["lastName"] as? String ?? "Didn't work"
            self.nameLabel.text = firstName + " " + lastName
            self.gameLabel.text = "\(firstName)'s Games"
            
            let profilePicURL = value?["photo"] as? String? ?? "Didn't work"
            
            if profilePicURL != "", profilePicURL != nil {
                let url = URL(string: profilePicURL!)
                let data = try? Data(contentsOf: url!)
                self.profilePic.image = UIImage(data : data!)
                self.userSpinner.stopAnimating()
                
            } else {
                self.profilePic.image = UIImage(named: "defaultProfilePic")
                print("No profile pic URL")
            }

            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }//End getUserInfo
    
    func fetchGames() {
        gameList = [Game]()
        self.tableView.reloadData()
        tableSpinner.startAnimating()
        ref.child("events").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                if let playerArray = dictionary["playerList"] as? [String] {
                    if playerArray.contains(self.userId) {
                        
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
                            
                            let game = Game(gameId, sport as! String, time , date, dateAsDate, spotsRemaining, gameType as! String)
                            self.gameList.append(game)
                            self.tableView.reloadData()
                        }
                    } //End if location
                }//End if let playerArray = dictionary
                //Sort games by date
                self.gameList.sort(by: {$0.dateTime.compare($1.dateTime) == .orderedAscending })
            } //End if let dictionary
            self.tableSpinner.stopAnimating()
        }) //End observe snapshot
    } //End fetchGames
    
    @IBAction func unwindtoUserPage(unwindSegue: UIStoryboardSegue){}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
        x.game = self.selectedGame
        x.cameFrom = "userPage"
    }
}//End class
