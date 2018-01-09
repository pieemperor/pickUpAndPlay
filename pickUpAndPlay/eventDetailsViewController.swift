//
//  eventDetailsViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/30/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FacebookLogin
import AVFoundation
import GoogleMaps
import UserNotifications

class eventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var spotsLeftLabel: UILabel!
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var tableSpinner: UIActivityIndicatorView!
    @IBOutlet weak var joinSpinner: UIActivityIndicatorView!
    
    var cameFrom = ""
    var game = Game()
    var playerList = [Player]()
    var idList = [String]()
    var selectedPlayer = ""
    var passedLocation = Location()
    var latitude = 0.0
    var longitude = 0.0
    var inGame = false {
        didSet {
            updateButtonSelectionStates()
        }
    }
    var profilePicURL = URL(string: "")
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        fetchLocationImage()
        setDetailLabels()
        fetchPlayers()
        updateButtonSelectionStates()
        self.locationName.text = passedLocation.name
        
        //set table view delegate to self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        }
    
    
    //MARK: Table View Delegate methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection: Int)-> Int{
        // an int that represents the number of players at this event
        return playerList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        let player = playerList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell", for: indexPath) as? PlayerTableViewCell
        cell?.setPlayer(player)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = playerList[indexPath.row]
        self.selectedPlayer = player.playerId

        self.performSegue(withIdentifier: "goToUserPage", sender: self)
        
    }
    
    //MARK: Table View appearance setup / rigging
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let gtvCell = cell as? PlayerTableViewCell {
            gtvCell.setSizeAndColor(tableView.frame.width)
        }
    }
    
    //Make sure the user is not in the game already - Then,  check to see if there are any spots open in that game. If not, tell the user that the game is full. If there are spots left, get the user's profile picture and info and create a player object and add it to the playerList and add that player's id to the playerList in the database
    //If the user is already in the game, remove the user from the playerList in Firebase
    @IBAction func joinGame(_ sender: Any) {
        if !inGame {
            ref.child("eventUsers").child(game.gameId).child(Auth.auth().currentUser!.uid ).observe(.childAdded, with: {(snapshot) in
                if let user = snapshot.value as? [String : Any]{
                    let profilePicURL = user["photo"] as? String
                    var userProfilePic = UIImage()
                    
                    if profilePicURL != "", profilePicURL != nil , profilePicURL != "none"{
                        self.profilePicURL = URL(string: profilePicURL!)
                        //MARK: NEED TO DO ASYNC - Attempt to load image
                        let data = try? Data(contentsOf: self.profilePicURL!)
                        userProfilePic = UIImage(data : data!)!
                    } else {
                        self.profilePicURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/image_uploaded_from_ios.jpg?alt=media&token=a931d6aa-7945-471e-aa40-cfb3acf463b0")
                        userProfilePic = UIImage(named: "defaultProfilePic")!
                    }
                    
                    let player = Player(Auth.auth().currentUser!.uid, user["firstName"] as! String, user["lastName"] as! String, userProfilePic,(self.profilePicURL?.absoluteString)!)
                    
                    self.playerList.append(player)
                    self.idList.append(player.playerId)
                    
                    if self.idList.count < self.game.playerLimit {
                        
                        let eventDict = [
                            "gameType": self.game.gameType,
                            "location": self.game.locationId,
                            "playerLimit": self.game.playerLimit,
                            "sport": self.game.sport,
                            "time": self.game.dateTime.timeIntervalSince1970
                            ] as [String : Any]
                        
                        self.ref.updateChildValues(["events/\(self.game.gameId)/playerList":self.idList,
                                                    "eventUsers/\(self.game.gameId)/\(player.playerId)": user,
                                                    "userEvents/\(player.playerId)/\(self.game.gameId)": eventDict,
                                                    "locationEvents/\(self.game.locationId)/\(self.game.gameId)": eventDict
                                                    ])
                        self.tableView.reloadData()
                        self.inGame = true
                        self.spotsLeftLabel.text = String(self.game.spotsRemaining) +  " Spots Remaining"
                        
                        self.createNotification(gameKey: self.game.gameId)
                        
                        self.joinSpinner.stopAnimating()
                    } else {
                        let alertController = UIAlertController(title: "Game Full", message: "This game is full.", preferredStyle: .alert)
                        let actionOk = UIAlertAction(title: "OK",
                                                     style: .default,
                                                     handler: nil) //You can use a block here to handle a press on this button
                        alertController.addAction(actionOk)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            })
        } /* End if !in game */ else {
            ref.child("events").queryOrderedByKey().queryEqual(toValue: self.game.gameId).observe(.childAdded, with: {(snapshot) in
                if let eventsDictionary = snapshot.value as? [String : AnyObject] {
                        if let playerListCount = eventsDictionary["playerList"]?.count! {
                            if playerListCount == 1 {
                                let alertController = UIAlertController(title: "Delete Game?", message: "You are the only player left in this game. If you leave this game, it will be deleted", preferredStyle: .alert)
                                let actionCancel = UIAlertAction(title: "Cancel",
                                                                 style: .default,
                                                                 handler: nil) //You can use a block here to handle a press on this button
                                
                                let actionDelete = UIAlertAction(title: "Delete Game",
                                                                 style: .destructive,
                                                                 handler: { UIAlertAction in
                                                                    //Find index for userid to remove
                                                                    if let index = self.idList.index(of: Auth.auth().currentUser!.uid) {
                                                                        self.idList.remove(at: index)
                                                                        self.playerList.remove(at: index)
                                                                        self.tableView.reloadData()
                                                                        self.inGame = false
                                                                    }
                                                                    
                                                                    self.ref.updateChildValues(["events/\(self.game.gameId)":NSNull(),
                                                                                                "eventUsers/\(self.game.gameId)/\(Auth.auth().currentUser!.uid)": NSNull(),
                                                                                                "userEvents/\(Auth.auth().currentUser!.uid)/\(self.game.gameId)": NSNull(),
                                                                                                "locationEvents/\(self.game.locationId)/\(self.game.gameId)": NSNull()
                                                                        ])
                                                                    
                                                                    if #available(iOS 10.0, *) {
                                                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [snapshot.key])
                                                                    } else {
                                                                        // Fallback on earlier versions
                                                                    }
                                                                    
                                                                    self.goBack()
                                })
                                
                                alertController.addAction(actionCancel)
                                alertController.addAction(actionDelete)
                                self.present(alertController, animated: true, completion: nil)
                            }/* End if playerListCount == 1 */ else {
                                if let index = self.idList.index(of: Auth.auth().currentUser!.uid) {
                                    self.idList.remove(at: index)
                                    self.playerList.remove(at: index)
                                    self.tableView.reloadData()
                                    self.inGame = false
                                }
                                
                                let eventsHandle = self.ref.child("events").child(self.game.gameId)
                                eventsHandle.updateChildValues(["playerList":self.idList])
                                let spotsRemaining = eventsDictionary["playerLimit"] as! Int - playerListCount
                                self.spotsLeftLabel.text = String(spotsRemaining + 1) +  " Spots Remaining"
                            }//End else
                        }//End if let playerListCount
                }//end if let eventsDictionary
            })//End .child("events").observe
        }//End else
    }//End joinGame
    
    @IBAction func getDirections(_ sender: UIButton) {
        if longitude == 0 && latitude == 0 {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:
                        "comgooglemaps://?saddr=&daddr=\(Float(self.passedLocation.lat)),\(Float(self.passedLocation.long))")! as URL, options: [:])
                } else {
                    UIApplication.shared.openURL(URL(string: "comgooglemaps://?saddr=&daddr=\(Float(self.passedLocation.lat)),\(Float(self.passedLocation.long))")!)
                }
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:
                        "https://www.google.com/maps/place/\(Float(self.passedLocation.lat)),\(Float(self.passedLocation.long))")! as URL, options: [:])
                } else {
                    UIApplication.shared.openURL(URL(string:
                        "https://www.google.com/maps/place/\(Float(self.passedLocation.lat)),\(Float(self.passedLocation.long))")!)
                }
            }
        } else {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:
                        "comgooglemaps://?saddr=&daddr=\(Float(self.latitude)),\(Float(self.longitude))&directionsmode=driving")! as URL, options: [:])
                } else {
                    UIApplication.shared.openURL(URL(string:
                        "comgooglemaps://?saddr=&daddr=\(Float(self.latitude)),\(Float(self.longitude))&directionsmode=driving")!)
                }
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:
                        "https://www.google.com/maps/place/\(Float(self.passedLocation.lat)),\(Float(self.passedLocation.long))")! as URL, options: [:])
                } else {
                    UIApplication.shared.openURL(URL(string:
                        "https://www.google.com/maps/place/\(Float(self.passedLocation.lat)),\(Float(self.passedLocation.long))")!)                }
            }
        }
    }
    
    private func updateButtonSelectionStates() {
        if inGame == true {
            joinButton.isSelected = true
        } else {
            joinButton.isSelected = false
        }
    }
    
    private func setupButtons() {
        joinButton.layer.cornerRadius = joinButton.frame.height/2
        joinButton.setTitle("Bail", for: .selected)
        joinButton.setTitle("Join", for: .normal)
        
        locationName.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    }
    
    func fetchPlayers() {
        tableSpinner.startAnimating()
        ref.child("eventUsers/\(self.game.gameId)").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
               let firstName = dictionary["firstName"]
               let lastName = dictionary["lastName"]
               var profilePicURL = dictionary["photo"] as? String
               var userProfilePic = UIImage()
                
                if(snapshot.key == Auth.auth().currentUser!.uid){
                    self.inGame = true
                }
               
               if profilePicURL != "", profilePicURL != nil , profilePicURL != "none", profilePicURL != " "{
                   let url = URL(string: profilePicURL!)
                   let data = try? Data(contentsOf: url!)
                   userProfilePic = UIImage(data : data!)!
               }/* End if profilePicURL != "" */ else {
                    profilePicURL = "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/image_uploaded_from_ios.jpg?alt=media&token=a931d6aa-7945-471e-aa40-cfb3acf463b0"
                    userProfilePic = UIImage(named: "defaultProfilePic")!
               }
                let player = Player(snapshot.key, firstName as! String, lastName as! String, userProfilePic, profilePicURL!)
                self.idList.append(player.playerId)
                self.playerList.append(player)
                self.tableView.reloadData()
                self.tableSpinner.stopAnimating()
            }//End if let dictionary
        })//End snapshot in
    }//End fetchPlayers
    
    private func setDetailLabels() {
        self.timeLabel.text = game.time
        self.dateLabel.text = game.date
        self.gameTypeLabel.text = game.gameType
        self.spotsLeftLabel.text = String(game.spotsRemaining) + " Spots Remaining"
        
        if game.sport == "soccer" {
            sportImage.image = UIImage(named: "soccerBall")
        } else if game.sport == "basketball" {
            sportImage.image = UIImage(named: "basketball")
        } else if game.sport == "volleyball" {
            sportImage.image = UIImage(named: "volleyball")
        } else if game.sport == "ultimate" {
            sportImage.image = UIImage(named: "ultimate")
        } else if game.sport == "discGolf" {
            sportImage.image = UIImage(named: "discGolf")
        } else if game.sport == "tennis" {
            sportImage.image = UIImage(named: "tennis")
        } else {
            print("That is not a valid sport")
        }
    }
    
    func fetchLocationImage() {
        if passedLocation.locationImageURL == "" {
            ref.child("events").observe(.childAdded, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    if snapshot.key == self.game.gameId {
                        let locationName = dictionary["location"] as? String
                        
                        self.ref.child("locations").observe(.childAdded, with: {(snapshot) in
                            if let dict = snapshot.value as? [String : AnyObject] {
                                if dict["locationName"] as? String == locationName {
                                    self.passedLocation = Location(snapshot.key, dict["availableSports"] as! [String], dict["locationName"] as! String, dict["longitude"] as! CLLocationDegrees, dict["latitude"] as! CLLocationDegrees, dict["image"] as! String)
                                    let url = URL(string: self.passedLocation.locationImageURL)
                                    
                                    //MARK: NEED TO DO ASYNC - Attempt to download image
                                    let data = try? Data(contentsOf: url!)
                                    self.locationImage.image = UIImage(data : data!)
                                } else {
                                    if let subLocations = dict["subLocations"]{

                                        do {
                                            let jsonData = try JSONSerialization.data(withJSONObject: subLocations, options: .prettyPrinted)
                                            // here "jsonData" is the dictionary encoded in JSON data
                                            print("jsonData: ", jsonData, "\n\n\n\n")
                                            
                                            if let decoded = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : [String : Any]]{
                                                for(_, value) in decoded {
                                                    if value["locationName"] as? String == locationName {
                                                    self.passedLocation = Location(snapshot.key, value["availableSports"] as! [String], value["locationName"] as! String, dict["longitude"] as! CLLocationDegrees, dict["latitude"] as! CLLocationDegrees, value["image"] as! String)
                                                        
                                                        let url = URL(string: self.passedLocation.locationImageURL)
                                                        let data = try? Data(contentsOf: url!)
                                                        self.locationImage.image = UIImage(data : data!)
                                                    }
                                                }
                                            }
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            })
        } else {
            let url = URL(string: self.passedLocation.locationImageURL)
            let data = try? Data(contentsOf: url!)
            self.locationImage.image = UIImage(data : data!)
        }
    }
    
    func goBack(){
        if cameFrom == "schedule" {
            performSegue(withIdentifier: "unwindToSchedule", sender: nil)
        } else if cameFrom == "userHome" {
            performSegue(withIdentifier: "unwindToUserHome", sender: nil)
        } else if cameFrom == "userPage" {
            performSegue(withIdentifier: "unwindToUserPage", sender: nil)
        } else if cameFrom == "gamesList" {
            performSegue(withIdentifier: "unwindToGamesList", sender: nil)
        }
    }
    
    func convertSportToPhrase(_ sport:String) -> String{
        var sportName = "game"
        if sport == "discGolf" {
            sportName = "a disc golf game"
        } else if sport == "ultimate" {
            sportName = "an ultimate frisbee game"
        } else if sport == "basketball" {
            sportName = "a basketball game"
        } else if sport == "volleyball" {
            sportName = "a volleyball game"
        } else if sport == "soccer" {
            sportName = "a soccer game"
        } else if sport == "tennis" {
            sportName = "a tennis match"
        }
        return sportName
    }
    
    func createNotification(gameKey:String){
        //Add notification to pop up one hour before the game.
        if #available(iOS 10.0, *) {
            
            let content = UNMutableNotificationContent()
            content.title = "Upcoming Game"
            content.body = "You have \(self.convertSportToPhrase(self.game.sport)) in one hour. Don't miss it!"
            // Configure the trigger for 1 hour before the game
            
            let notificationTime = Date(timeIntervalSince1970: self.game.dateTime.timeIntervalSince1970 - 3600)
            
            let dateInfo = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationTime)
            print(dateInfo)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
            
            // Create the request object.
            let request = UNNotificationRequest(identifier: "\(gameKey)", content: content, trigger: trigger)
            
            // Schedule the request.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }//End createNotification
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserPage" {
            let x : UserPageViewController = segue.destination as! UserPageViewController
            x.userId = self.selectedPlayer
        }
    }//End prepare for segue
}//End class
