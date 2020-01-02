//
//  Message.swift
//  slackish
//
//  Created by Kilyan SOCKALINGUM on 02/01/2020.
//  Copyright © 2020 Kilyan SOCKALINGUM. All rights reserved.
//

import Foundation

struct Message {
    public private(set) var message : String!
    public private(set) var username : String!
    public private(set) var channelId : String!
    public private(set) var userAvatar : String!
    public private(set) var userAvatarColor : String!
    public private(set) var id : String!
    public private(set) var timestamp : String!
}
