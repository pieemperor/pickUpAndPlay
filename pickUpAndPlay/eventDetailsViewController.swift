//
//  eventDetailsViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/30/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//https://www.youtube.com/watch?v=B9sH_VxPPo4&t=81s

//TODO: Fix crash if there are no players in playerList array

import UIKit
import Firebase
import FirebaseAuth
import FacebookLogin
import AVFoundation

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
    
    //event key sent from schedulecontroller
    var game = Game()
    var playerList = [Player]()
    var idList = [String]()
    var selectedPlayer = ""
    var passedLocation = Location()
    var otherPassedLocation = ""
    var latitude = 0.0
    var longitude = 0.0
    var inGame = false {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupLocations()
        setDetailLabels()
        fetchPlayers()
        updateButtonSelectionStates()
        
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
        cell?.playerNameLabel.text = player.firstName + " " + player.lastName
            cell?.profilePic?.image = player.profilePicture
            cell?.profilePic.clipsToBounds = true
            cell?.profilePic?.layer.cornerRadius = (cell?.profilePic?.frame.width)! / 2
        
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
        cell.backgroundColor = .clear
        
        let myGreen = UIColor(displayP3Red:46.0/255.0, green:204.0/255.0, blue:114.0/255.0, alpha:1.0)
        
        let greenRoundedView: UIView = UIView(frame: CGRect(x:0,y:5,width:tableView.frame.width, height:80))
        greenRoundedView.layer.backgroundColor = myGreen.cgColor
        greenRoundedView.layer.masksToBounds = false
        greenRoundedView.layer.cornerRadius = 10.0
        greenRoundedView.layer.shadowOffset = CGSize(width:-1,height: 0)
        greenRoundedView.layer.shadowOpacity = 0.2
        
        
        cell.contentView.addSubview(greenRoundedView)
        cell.contentView.sendSubview(toBack: greenRoundedView)
    }
    
    //Make sure the user is not in the game already - Then,  check to see if there are any spots open in that game. If not, tell the user that the game is full. If there are spots left, get the user's profile picture and info and create a player object and add it to the playerList and add that player's id to the playerList in the database
    //If the user is already in the game, remove the user from the playerList in Firebase
    @IBAction func joinGame(_ sender: Any) {
        let ref = Database.database().reference()
        if !inGame {
            ref.child("events").observe(.childAdded, with: {(snapshot) in
                if let eventsDictionary = snapshot.value as? [String : AnyObject] {
                    if snapshot.key == self.game.gameId {
                        if let playerListCount = eventsDictionary["playerList"]?.count! {
                            let spotsRemaining = eventsDictionary["playerLimit"] as! Int - playerListCount
                            if spotsRemaining > 0 {
                                ref.child("users").observe(.childAdded, with: {(snapshot) in
                                    if let usersDictionary = snapshot.value as? [String : AnyObject] {
                                        if snapshot.key == Auth.auth().currentUser!.uid {
                                            let profilePicURL = usersDictionary["photo"] as? String
                                            var userProfilePic = UIImage()
                                            
                                            if profilePicURL != "", profilePicURL != nil , profilePicURL != "none"{
                                                
                                                let picRef = Storage.storage().reference(forURL: profilePicURL!)
                                                
                                                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                                                picRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
                                                    if let error = error {
                                                        // Uh-oh, an error occurred!
                                                        print("The following error occurred - \(error)")
                                                    } else {
                                                        // Data for "images/island.jpg" is returned
                                                        userProfilePic = UIImage(data: data!)!
                                                    }
                                                    
                                                    let player = Player(Auth.auth().currentUser!.uid, usersDictionary["firstName"] as! String, usersDictionary["lastName"] as! String, userProfilePic)
                                                    self.playerList.append(player)
                                                    
                                                    self.idList.append(player.playerId)
                                                    
                                                    let eventsHandle = ref.child("events").child(self.game.gameId)
                                                    eventsHandle.updateChildValues(["playerList":self.idList])
                                                    self.tableView.reloadData()
                                                    self.inGame = true
                                                }//End get data
                                            }//End if profilePicURL != ""
                                        }//End if snapshot.key == Auth.auth().currentUser
                                    }//If let usersDictionary =
                                })//End ref.child("users").observe
                            }/* End if there are spots left */ else {
                                let alertController = UIAlertController(title: "Game Full", message: "This game is full.", preferredStyle: .alert)
                                let actionOk = UIAlertAction(title: "OK",
                                                             style: .default,
                                                             handler: nil) //You can use a block here to handle a press on this button
                                alertController.addAction(actionOk)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }//End if snapshot key = gameID
                }//End eventsDictionary
            })//End ref.child("events").observe
        } /* End if in game */ else {
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
                                                
                                                let eventsHandle = ref.child("events").child(self.game.gameId)
                                                eventsHandle.updateChildValues(["playerList":self.idList])
            })
            
            alertController.addAction(actionCancel)
            alertController.addAction(actionDelete)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func getDirections(_ sender: UIButton) {
        if longitude == 0 && latitude == 0 {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:
                    "comgooglemaps://?saddr=&daddr=\(Float(self.passedLocation.lat)),\(Float(self.passedLocation.long))&directionsmode=driving")! as URL, options: [:])
            } else {
                print("Can't use com.google.maps://")
            }
        } else {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:
                    "comgooglemaps://?saddr=&daddr=\(Float(self.latitude)),\(Float(self.longitude))&directionsmode=driving")! as URL, options: [:])
            } else {
                print("Can't use com.google.maps://")
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
        
        locationName.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    }
    
    private func setupLocations() {
        if otherPassedLocation != "" {
            if otherPassedLocation == "Davis Basketball Court" {
                locationImage.image = UIImage(named: "davisBBall")!
                self.latitude = 36.3035454
                self.longitude = -82.3639571
            } else if otherPassedLocation == "Buc Ridge Basketball Court" {
                locationImage.image = UIImage(named: "bucRidgeBBall")!
                self.latitude = 36.2997041
                self.longitude = -82.3592807
            } else if otherPassedLocation == "Davis Beach Volleyball Court (Outside)" {
                locationImage.image = UIImage(named: "davisVBall")!
                self.latitude = 36.3035529
                self.longitude = -82.3637902
            } else if otherPassedLocation == "Buc Ridge Beach Volleyball Court" {
                locationImage.image = UIImage(named: "brvbCourt")!
                self.latitude = 36.3000031
                self.longitude = -82.3592885
            } else if otherPassedLocation == "Campus Ridge Beach Volleyball Court" {
                locationImage.image = UIImage(named: "campusRidgeVBCourt")!
                self.latitude = 36.2954593
                self.longitude = -82.3746753
            } else if otherPassedLocation == "CPA Front Yard" {
                locationImage.image = UIImage(named: "cpaFrontYard")!
                self.latitude = 36.301344
                self.longitude = -82.373986
            } else if otherPassedLocation == "CPA Side Yard" {
                locationImage.image = UIImage(named: "cpaSideYard")!
                self.latitude = 36.300691
                self.longitude = -82.3748875
            } else if otherPassedLocation == "The Quad" {
                locationImage.image = UIImage(named: "quad")!
                self.latitude = 36.3029164
                self.longitude = -82.3698213
            } else if otherPassedLocation == "Tri-Hall Field" {
                locationImage.image = UIImage(named: "triHallField")!
                self.latitude = 36.3038811
                self.longitude = -82.3642177
            } else if otherPassedLocation == "ETSU Disc Golf Course" {
                locationImage.image = UIImage(named: "etsuDiscGolf")!
                self.latitude = 36.30044
                self.longitude = -82.362922
            } else {
                print("Invalid location passed to page")
            }
        } else {
            locationImage.image = passedLocation.locationImage
            locationImage.clipsToBounds = true
        }
    }
    
    func fetchPlayers() {
        let ref = Database.database().reference()
        ref.child("events").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                if snapshot.key == self.game.gameId {
                self.locationName.text = dictionary["location"] as? String
                    if let playerIdArray = dictionary["playerList"] as? [String] {
                        if playerIdArray.contains(Auth.auth().currentUser!.uid) {
                            self.inGame = true
                        }
                        for player in playerIdArray {
                            ref.child("users").observe(.childAdded, with: {(snapshot) in
                                if let userDictionary = snapshot.value as? [String : AnyObject] {
                                    if player == snapshot.key {
                                        let firstName = userDictionary["firstName"]
                                        let lastName = userDictionary["lastName"]
                                        let profilePicURL = userDictionary["photo"] as? String
                                        var userProfilePic = UIImage()
                                        
                                        if profilePicURL != "", profilePicURL != nil , profilePicURL != "none"{
                                            
                                            let picRef = Storage.storage().reference(forURL: profilePicURL!)
                                            
                                            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                                            picRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
                                                if let error = error {
                                                    // Uh-oh, an error occurred!
                                                    print("The following error occurred - \(error)")
                                                } else {
                                                    // Data for "images/island.jpg" is returned
                                                    userProfilePic = UIImage(data: data!)!
                                                }
                                                
                                                let player = Player(player, firstName as! String, lastName as! String, userProfilePic)
                                                self.idList.append(player.playerId)
                                                self.playerList.append(player)
                                                self.tableView.reloadData()
                                            }
                                        }//End if profilePicURL != ""
                                    }//End if player == snapshot.key
                                }//End if let userDictionary
                            })//End .child("users").observe
                        }//End for player in playerIdArray
                    }//End if gameId = snapshot
                }//End if let playerIdArray
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserPage" {
            let x : UserPageViewController = segue.destination as! UserPageViewController
            x.userId = self.selectedPlayer
        }
    }//End prepare for segue
}//End class
