//
//  MessageCell.swift
//  slackish
//
//  Created by Kilyan SOCKALINGUM on 02/01/2020.
//  Copyright © 2020 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    //outlets
    @IBOutlet weak var userImg: CircleImage!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(message: Message) {
        messageLbl.text = message.message
        usernameLbl.text = message.username
        userImg.image = UIImage(named: message.userAvatar)
        userImg.backgroundColor = UserDataService.instance.returnUIColor(components: message.userAvatarColor)
        
        //Convert message timestamp to readable date
        guard var isoDate = message.timestamp else { return }
        let isoDateEnd = isoDate.index(isoDate.endIndex, offsetBy: -5)
        isoDate = String(isoDate[..<isoDateEnd])
        isoDate.append("Z")
        print(isoDate)
        
        let isoFormatter = ISO8601DateFormatter()
        let messageDate = isoFormatter.date(from: isoDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        if let finalDate = messageDate {
            let finaleDate = dateFormatter.string(from: finalDate)
            timestampLbl.text = finaleDate
        }
    }
}
