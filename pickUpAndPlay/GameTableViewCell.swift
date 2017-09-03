//
//  GameTableViewCell.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 7/24/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var spotsRemainingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
