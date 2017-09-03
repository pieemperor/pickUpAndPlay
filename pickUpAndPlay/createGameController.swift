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

class createGameController: UIViewController{
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    //MARK: Properties
    //name of location
    var location = Location()
    //timeArray gets sent to the createGame from sceduleController so a game can't be made with the same time
    var timeArray = [String]()
    private var sportButtons = [UIButton]()
    var isDatePickerShowing = false
    var numberOfSubs = 0
    
    //variables to send to Firebase
    var selectedSport = "" {
        didSet {
            updateButtonSelectionStates()
        }
    }
    var time = String()
    var repeatFrequency = "Never"
    var gameType = "Recreational"
    var playerLimit = 0
    //let repeatOptions = ["Never", "Every Day", "Every Week", "Every 2 Weeks", "Every Month"]

    //MARK: Outlets
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var sportsButtonsStack: UIStackView!
    @IBOutlet weak var addSubsButton: UIButton!
    @IBOutlet weak var addSubsLabel: UILabel!
    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var skillSelector: UISegmentedControl!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationLabel: UILabel!
    //@IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var repeatPicker: UIPickerView!
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupSportButtons()
        setupDatePicker()
        locationLabel.text = location.name
        locationImage.image = location.locationImage
        
        
        /*
        //Setup Picker View
        repeatPicker.isHidden = true
        repeatPicker.delegate = self
        repeatPicker.dataSource = self
        */
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
            time = DateFormatter.localizedString(from: datePicker.date, dateStyle: DateFormatter.Style.medium, timeStyle:DateFormatter.Style.short)
            timeButton.setTitle(time, for: .normal)
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
        time = DateFormatter.localizedString(from: datePicker.date, dateStyle: DateFormatter.Style.medium, timeStyle:DateFormatter.Style.short)
        timeButton.setTitle(time, for: .normal)
    }
    
    
    @IBAction func gameTypeChanged(_ sender: UISegmentedControl) {
        if skillSelector.selectedSegmentIndex == 0 {
            gameType = "Recreational"
        } else if skillSelector.selectedSegmentIndex == 1 {
            gameType = "Competitive"
        } else {
            print("Invalid selector option")
        }
    }
    
    @IBAction func createGameButtonTapped(_ sender: Any) {
        if selectedSport != "" {
            if time != "" {
                if !timeArray.contains(time) {
                    //create a new event and add info as children
                    let ref = Database.database().reference()
                    let key = ref.child("events").childByAutoId().key
                    let post = ["createdBy": Auth.auth().currentUser?.uid as Any,
                                "location": location.name,
                                "sport": selectedSport,
                                "time": time,
                                "repeatFrequency": repeatFrequency,
                                "gameType": gameType,
                                "playerLimit": playerLimit,
                                "playerList": [Auth.auth().currentUser?.uid] ] as [String : Any]
                    let childUpdates = ["/events/\(key)": post]
                    ref.updateChildValues(childUpdates)
                    performSegue(withIdentifier: "unwindToSchedule", sender: self)
                } else {
                    let alertController = UIAlertController(title: "Time Slot Taken", message: "Someone has already created a game for that time.", preferredStyle: .alert)
                    let actionOk = UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil) //You can use a block here to handle a press on this button
                    alertController.addAction(actionOk)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                let alertController = UIAlertController(title: "No time selected", message: "You must select a time for your game.", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil) //You can use a block here to handle a press on this button
                
                alertController.addAction(actionOk)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "No sport selected", message: "You must select a sport.", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            alertController.addAction(actionOk)
            self.present(alertController, animated: true, completion: nil)
        }
    }
 
    @IBAction func addSubs(_ sender: UIButton) {
        if addSubsButton.isSelected == false {
            addSubsButton.isSelected = true
            playerLimit = playerLimit + numberOfSubs
        } else {
            addSubsButton.isSelected = false
            playerLimit = playerLimit - numberOfSubs
        }
    }
    
    /*
     @IBAction func showRepeatPicker(_ sender: UIButton) {
     if repeatPicker.isHidden == false {
        repeatPicker.isHidden = true
     } else {
        repeatPicker.isHidden = false
     }
     }
    */
    
    /*
    //MARK: PickerView functions
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeatOptions.count
    }
    
    // Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repeatOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repeatButton.setTitle(repeatOptions[row], for: .normal)
        repeatFrequency = repeatOptions[row]
    }
     */
    
    
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
    
    func sportButtonTapped(button: UIButton) {
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
        let myGreen = UIColor(displayP3Red:46.0/255.0, green:204.0/255.0, blue:114.0/255.0, alpha:1.0)
        
        //Setup skill Selector button
        skillSelector.layer.cornerRadius = 5.0
        
        //Setup time Button
        timeButton.layer.borderColor = myGreen.cgColor
        timeButton.layer.borderWidth = 1.0
        timeButton.layer.cornerRadius = 5.0
        
        //Setup Create game button
        createGameButton.layer.cornerRadius = createGameButton.frame.height/2
        
        /*
        //Setup repeat button
        repeatButton.layer.borderWidth = 1.0
        repeatButton.layer.borderColor = myGreen.cgColor
        repeatButton.layer.cornerRadius = 5.0
        */
        
        let white: UIColor = .white
        skillSelector.setTitleTextAttributes([NSForegroundColorAttributeName: white], for: .normal)
        skillSelector.setTitleTextAttributes([NSForegroundColorAttributeName: white], for: .selected)
        
        addSubsButton.setImage(UIImage(named: "subsButton"), for: .normal)
        addSubsButton.setImage(UIImage(named: "selectedSubsButton"), for: .selected)
        
        locationLabel.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
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
}
