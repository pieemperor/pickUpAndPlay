//
//  PlayerTableViewCell.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 8/11/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
