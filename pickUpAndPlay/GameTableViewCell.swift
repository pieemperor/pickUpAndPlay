//
//  GameTableViewCell.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 7/24/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//

import UIKit

class GameTableViewCell: GreenTableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var spotsRemainingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setGame(_ game:Game){
        //set the cell's labels to their corresponding values for each game in the gameList array
        self.timeLabel.text = game.time
        self.dateLabel.text = game.date
        self.spotsRemainingLabel.text = String(game.spotsRemaining)
        
        //Check to see what sport the game is and set the cell's image appropriately
        if game.sport == "soccer" {
            self.sportImage.image = UIImage(named: "soccerBall")
        } else if game.sport == "basketball" {
            self.sportImage.image = UIImage(named: "basketball")
        } else if game.sport == "volleyball" {
            self.sportImage.image = UIImage(named: "volleyball")
        } else if game.sport == "ultimate" {
            self.sportImage.image = UIImage(named: "ultimate")
        } else if game.sport == "discGolf" {
            self.sportImage.image = UIImage(named: "discGolf")
        } else if game.sport == "tennis" {
            self.sportImage.image = UIImage(named: "tennis")
        } else {
            print("That is not a valid sport")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
