//
//  createGameController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/20/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import UserNotifications
import AlamofireImage
import Alamofire

class createGameController: UIViewController{
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    //MARK: Properties
    //name of location
    var location = Location()
    //timeArray gets sent to the createGame from sceduleController so a game can't be made with the same time
    var timeArray = [Double]()
    private var sportButtons = [UIButton]()
    var isDatePickerShowing = false
    var numberOfSubs = 0
    var authenticatedUser = Player()
    let ref = Database.database().reference()

    
    //variables to send to Firebase
    var selectedSport = "" {
        didSet {
            updateButtonSelectionStates()
        }
    }
    var time = Double()
    var playerLimit = 0

    //MARK: Outlets
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var sportsButtonsStack: UIStackView!
    @IBOutlet weak var addSubsButton: UIButton!
    @IBOutlet weak var addSubsLabel: UILabel!
    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationLabel: UILabel!
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserInfo()
        fetchLocationImage()
        setupButtons()
        setupSportButtons()
        setupDatePicker()
        selectedSport = location.availableSports[0]
        setPlayerLimits()
        locationLabel.text = location.name        
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDatePickerShowing {
            
            // Dismiss the keyboard when the view is tapped on
            let dpSize = datePicker.bounds.size
            let size = view.bounds.size
            let y = isDatePickerShowing ? size.height : size.height - dpSize.height
            isDatePickerShowing = !isDatePickerShowing
            UIView.animate(withDuration: 0.75) {
                self.datePicker.frame = CGRect(
                    x: (size.width - dpSize.width) / 2.0,
                    y: y,
                    width: dpSize.width,
                    height: dpSize.height
                )
            }
            
            time = datePicker.date.timeIntervalSince1970
            
            let buttonTitle = DateFormatter.localizedString(from: datePicker.date, dateStyle: DateFormatter.Style.medium, timeStyle:DateFormatter.Style.short)
            timeButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    //MARK: Actions
    @IBAction func selectTime(_ sender: UIButton) {
        let dpSize = datePicker.bounds.size
        let size = view.bounds.size
        let y = isDatePickerShowing ? size.height : size.height - dpSize.height
        isDatePickerShowing = !isDatePickerShowing
        UIView.animate(withDuration: 0.75) {
            self.datePicker.frame = CGRect(
                x: (size.width - dpSize.width) / 2.0,
                y: y,
                width: dpSize.width,
                height: dpSize.height
            )
        }
        time = datePicker.date.timeIntervalSince1970
        let buttonTitle = DateFormatter.localizedString(from: datePicker.date, dateStyle: DateFormatter.Style.medium, timeStyle:DateFormatter.Style.short)
        timeButton.setTitle(buttonTitle, for: .normal)
    }
    
    @IBAction func createGameButtonTapped(_ sender: Any) {
        if selectedSport != "" {
            if time != 0.0 {
                if !timeArray.contains(time) {
                    //create a new event and add info as children
                    let optionalKey = ref.child("events").childByAutoId().key
                    
                    if let key = optionalKey {
                        let locationInfo = [
                            location.locationId : [
                                "availableSports": location.availableSports,
                                "image": location.locationImageURL,
                                "latitude": location.lat as Double,
                                "longitude": location.long as Double,
                                "locationName": location.name
                            ]
                        ]
                        let post = ["location": locationInfo,
                                    "sport": selectedSport,
                                    "time": time,
                                    "playerLimit": playerLimit,
                                    "playerList": [Auth.auth().currentUser?.uid] ] as [String : Any]
                        let userInfo = [
                                        "firstName" : authenticatedUser.firstName,
                                        "lastName" : authenticatedUser.lastName,
                                        "photo": authenticatedUser.profilePictureUrl
                        ]
                        let childUpdates = ["/events/\(String(describing: key))": post,
                                            "/locationEvents/\(location.locationId)/\(String(describing: key))": post,
                                            "/userEvents/\(Auth.auth().currentUser!.uid)/\(String(describing: key))": post,
                                            "/eventUsers/\(String(describing: key))/\(authenticatedUser.playerId)": userInfo] as [String : Any]
                        ref.updateChildValues(childUpdates)
                        
                        //************************  Create Notifications **************************//
                        //Add notification to pop up one hour before the game.
                        if #available(iOS 10.0, *) {
                            let date = Date(timeIntervalSince1970: time - 3600)

                            let content = UNMutableNotificationContent()
                            content.title = "Upcoming Game"
                            content.body = "You have \(convertSportToPhrase(selectedSport)) in one hour. Don't miss it!"
                            // Configure the trigger for 1 hour before the game

                            let dateInfo = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                            print(dateInfo)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
                            
                            // Create the request object.
                            let request = UNNotificationRequest(identifier: "\(String(describing: key))", content: content, trigger: trigger)
                            
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
                        //*********************** End of create notification ************************//

                        performSegue(withIdentifier: "unwindToSchedule", sender: self)
                    }
                } else {
                    let alertController = UIAlertController(title: "Time Slot Taken", message: "Someone has already created a game for that time.", preferredStyle: .alert)
                    let actionOk = UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil) //You can use a block here to handle a press on this button
                    alertController.addAction(actionOk)
                    self.present(alertController, animated: true, completion: nil)
                }
            } /* End if time != 0 */else {
                let alertController = UIAlertController(title: "No time selected", message: "You must select a time for your game.", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil) //You can use a block here to handle a press on this button
                
                alertController.addAction(actionOk)
                self.present(alertController, animated: true, completion: nil)
            }
        }/*End if selectedSport = nil*/ else {
            let alertController = UIAlertController(title: "No sport selected", message: "You must select a sport.", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            alertController.addAction(actionOk)
            self.present(alertController, animated: true, completion: nil)
        }
    }//End create game
 
    @IBAction func addSubs(_ sender: UIButton) {
        if addSubsButton.isSelected == false {
            addSubsButton.isSelected = true
            playerLimit = playerLimit + numberOfSubs
        } else {
            addSubsButton.isSelected = false
            playerLimit = playerLimit - numberOfSubs
        }
    }
    
    //MARK: private functions
    private func setupSportButtons() {
        
        
        // clear any existing buttons
        for button in sportButtons {
            sportsButtonsStack.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        sportButtons.removeAll()
        
        
        // Load Button Images
        let bundle = Bundle(for: type(of: self))

        //Soccer
        let defaultSoccerButton = UIImage(named: "soccerButton", in: bundle, compatibleWith: self.traitCollection)
        let selectedSoccerButton = UIImage(named: "selectedSoccerButton", in: bundle, compatibleWith: self.traitCollection)
        
        //Basketball
        let defaultBasketballButton = UIImage(named: "basketballButton", in: bundle, compatibleWith: self.traitCollection)
        let selectedBasketballButton = UIImage(named: "selectedBasketballButton", in: bundle, compatibleWith: self.traitCollection)
        
        //Volleyball
        let defaultVolleyballButton = UIImage(named: "volleyballButton", in: bundle, compatibleWith: self.traitCollection)
        let selectedVolleyballButton = UIImage(named: "selectedVolleyballButton", in: bundle, compatibleWith: self.traitCollection)
        
        //Ultimate Frisbee
        let defaultUltimateButton = UIImage(named: "ultimateButton", in: bundle, compatibleWith: self.traitCollection)
        let selectedUltimateButton = UIImage(named: "selectedUltimateButton", in: bundle, compatibleWith: self.traitCollection)
        
        //Disc Golf
        let defaultDiscGolfButton = UIImage(named: "discGolfButton", in: bundle, compatibleWith: self.traitCollection)
        let selectedDiscGolfButton = UIImage(named: "selectedDiscGolfButton", in: bundle, compatibleWith: self.traitCollection)
        
        //Tennis
        let defaultTennisButton = UIImage(named: "tennisButton", in: bundle, compatibleWith: self.traitCollection)
        let selectedTennisButton = UIImage(named: "selectedTennisButton", in: bundle, compatibleWith: self.traitCollection)
        
        
        for index in 0..<location.availableSports.count {
            let button = UIButton()
            
            // Set the button images
            if location.availableSports[index] == "soccer" {
                button.setImage(defaultSoccerButton, for: .normal)
                button.setImage(selectedSoccerButton, for: .selected)
            } else if location.availableSports[index] == "basketball" {
                button.setImage(defaultBasketballButton, for: .normal)
                button.setImage(selectedBasketballButton, for: .selected)
            } else if location.availableSports[index] == "volleyball" {
                button.setImage(defaultVolleyballButton, for: .normal)
                button.setImage(selectedVolleyballButton, for: .selected)
            } else if location.availableSports[index] == "ultimate" {
                button.setImage(defaultUltimateButton, for: .normal)
                button.setImage(selectedUltimateButton, for: .selected)
            } else if location.availableSports[index] == "discGolf" {
                button.setImage(defaultDiscGolfButton, for: .normal)
                button.setImage(selectedDiscGolfButton, for: .selected)
            } else if location.availableSports[index] == "tennis" {
                button.setImage(defaultTennisButton, for: .normal)
                button.setImage(selectedTennisButton, for: .selected)
            }
 
            
            // Setup the button action
            button.addTarget(self, action: #selector(createGameController.sportButtonTapped(button:)), for: .touchUpInside)
            
            sportsButtonsStack.addArrangedSubview(button)
            
            // Add the new button to the rating button array
            sportButtons.append(button)
        }
    }
    
    @objc func sportButtonTapped(button: UIButton) {
        guard let index = sportButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the sportButtons array: \(sportButtons)")
        }
        
        // Get the sport of the selected button
        let sportSelected = location.availableSports[index]
        
        if sportSelected == selectedSport {
            // If the selected sport represents the current sport, deselect the sport
            selectedSport = ""
        } else {
            // Otherwise set the sport to the selected sport
            selectedSport = sportSelected
            updateButtonSelectionStates()
        }
        
        setPlayerLimits()
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in sportButtons.enumerated() {
            if location.availableSports[index] == selectedSport {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
    
    private func setupDatePicker() {
        let dpSize = datePicker.bounds.size
        let size = view.bounds.size
        datePicker.frame = CGRect(
            x: (size.width - dpSize.width) / 2.0,
            y: size.height,
            width: dpSize.width,
            height: dpSize.height
        )
        datePicker.minimumDate = NSDate() as Date
        self.datePicker.backgroundColor = .white
    }
    
    private func setupButtons() {
        //Create green color
        let myGreen = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        
        //Setup time Button
        timeButton.layer.borderColor = myGreen.cgColor
        timeButton.layer.borderWidth = 1.0
        timeButton.layer.cornerRadius = 5.0
        
        //Setup Create game button
        createGameButton.layer.cornerRadius = createGameButton.frame.height/2
        
        addSubsButton.setImage(UIImage(named: "subsButton"), for: .normal)
        addSubsButton.setImage(UIImage(named: "selectedSubsButton"), for: .selected)
        
        locationLabel.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    }
    
    private func setPlayerLimits() {
        //Set the playerLimit and numberOfSubs
        if selectedSport == "soccer"{
            playerLimit = 22
            numberOfSubs = 11
        } else if selectedSport == "basketball" {
            playerLimit = 10
            numberOfSubs = 5
        } else if selectedSport == "ultimate" {
            playerLimit = 14
            numberOfSubs = 7
        } else if selectedSport == "volleyball" {
            playerLimit = 12
            numberOfSubs = 6
        } else if selectedSport == "discGolf" {
            playerLimit = 8
            numberOfSubs = 0
        } else if selectedSport == "tennis" {
            playerLimit = 4
            numberOfSubs = 2
        } else {
            print("Cannot set player limit because wrong sport")
        }
    }

    func fetchLocationImage() {
        let imageURL = location.locationImageURL
        let url = URL(string: imageURL)
        self.locationImage.af_setImage(withURL: url!, placeholderImage: UIImage(named: "profileBG"))
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
    
    //Temporary fix - need to find more efficient way to track current user
    func getUserInfo () {
        //Get the user's first and last name from Firebase
        if let userID = Auth.auth().currentUser?.uid {
            ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let firstName = value?["firstName"] as? String ?? "Didn't work"
                let lastName = value?["lastName"] as? String ?? "Didn't work"
                
                let profilePicURL = value?["photo"] as? String? ?? "Didn't work"
                
                
                if profilePicURL != "", profilePicURL != nil {
                    let url = URL(string: profilePicURL!)
                    let data = try? Data(contentsOf: url!)
                    self.authenticatedUser = Player(snapshot.key, firstName, lastName, UIImage(data: data!)!, profilePicURL!)
                } else {
                    let profilePicURL = "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/image_uploaded_from_ios.jpg?alt=media&token=a931d6aa-7945-471e-aa40-cfb3acf463b0"
                    let url = URL(string: profilePicURL)
                    let data = try? Data(contentsOf: url!)
                    self.authenticatedUser = Player(snapshot.key, firstName, lastName, UIImage(data:data!)!, "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/image_uploaded_from_ios.jpg?alt=media&token=a931d6aa-7945-471e-aa40-cfb3acf463b0")
                    
                    print("No profile pic URL")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }//End getUserInfo
}
