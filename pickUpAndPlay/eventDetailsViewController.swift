//
//  eventDetailsViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/30/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//https://www.youtube.com/watch?v=B9sH_VxPPo4&t=81s

//TODO: Add all info to page
//TODO: Pass location to this view controller and display background image
//TODO: Fix crash if there are no players in playerList array


import UIKit
import Firebase
import FirebaseAuth
import FacebookLogin
import AVFoundation

class eventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        getGameInfo()
        fetchPlayers()
        
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
    
    
    @IBAction func joinGame(_ sender: Any) {
        let ref = Database.database().reference()
        _ = ref.child("users").observe(.childAdded, with: {(snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                if snapshot.key == Auth.auth().currentUser!.uid {
                    if !self.idList.contains(Auth.auth().currentUser!.uid) {
                        
                        
                        let profilePicURL = dict["photo"] as? String
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
                                
                                let player = Player(Auth.auth().currentUser!.uid, dict["firstName"] as! String, dict["lastName"] as! String, userProfilePic)
                                self.playerList.append(player)
                                
                                self.idList.append(player.playerId)
                                
                                let eventsHandle = Database.database().reference().child("events").child(self.game.gameId)
                                eventsHandle.updateChildValues(["playerList":self.idList])
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserPage" {
        let x : UserPageViewController = segue.destination as! UserPageViewController
        x.userId = self.selectedPlayer
        }
    }//End prepare for segue
    
    private func setupButtons() {
        joinButton.layer.cornerRadius = joinButton.frame.height/2
        locationImage.image = passedLocation.locationImage
        locationImage.clipsToBounds = true
    }
    
    func fetchPlayers() {
        let ref = Database.database().reference()
        _ = ref.child("events").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                if snapshot.key == self.game.gameId {
                self.locationName.text = dictionary["location"] as? String
                    if let playerIdArray = dictionary["playerList"] as? [String] {
                        for player in playerIdArray {
                            _ = ref.child("users").observe(.childAdded, with: {(snapshot) in
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
    
    private func getGameInfo() {
        self.timeLabel.text = game.time
        self.dateLabel.text = game.date
        self.gameTypeLabel.text = game.gameType
        
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
}//End class
