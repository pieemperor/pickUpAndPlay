//
//  GreenTableViewCell.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 1/4/18.
//  Copyright © 2018 Dakota Cowell. All rights reserved.
//

import UIKit

class GreenTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSizeAndColor(_ tableViewWidth:CGFloat){
        self.backgroundColor = .clear
        
        let myGreen = UIColor(red:46.0/255.0, green:204.0/255.0, blue:114.0/255.0, alpha:1.0)
        
        let greenRoundedView: UIView = UIView(frame: CGRect(x:0,y:5,width:tableViewWidth, height:80))
        greenRoundedView.layer.backgroundColor = myGreen.cgColor
        greenRoundedView.layer.masksToBounds = false
        greenRoundedView.layer.cornerRadius = 10.0
        greenRoundedView.layer.shadowOpacity = 0.0
        
        self.contentView.addSubview(greenRoundedView)
        self.contentView.sendSubviewToBack(greenRoundedView)
    }

}
