//
//  ChannelCell.swift
//  slackish
//
//  Created by Kilyan SOCKALINGUM on 20/12/2019.
//  Copyright © 2019 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var channelNameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.layer.backgroundColor = UIColor(white: 1, alpha: 0.2).cgColor
        } else {
            self.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    func configureCell(channel: Channel) {
        let title = channel.channelTitle ?? ""
        channelNameLbl.text = "#\(title)"
        channelNameLbl.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        for id in MessageService.instance.unreadChannels {
            if id == channel.id {
                channelNameLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 19)
            }
        }
        
    }
    
    

}
