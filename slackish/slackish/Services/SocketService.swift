//
//  SocketService.swift
//  slackish
//
//  Created by Kilyan SOCKALINGUM on 02/01/2020.
//  Copyright © 2020 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit
import SocketIO

class SocketService: NSObject {
    static let instance = SocketService()
    
    let manager = SocketManager(socketURL: URL(string: BASE_URL)!, config: [.log(true), .compress])
    var socket : SocketIOClient?
    
    override init() {
        super.init()
        socket = self.manager.defaultSocket
    }
    
    
    func establishConnection() {
        socket?.connect()
    }
    
    func closeConnection() {
        socket?.disconnect()
    }
    
    func addChannel(channelName: String, channelDescription: String, completion: @escaping CompletionHandler) {
        socket?.emit("newChannel", channelName, channelDescription)
        completion(true)
    }
    
    func getChannel(completion: @escaping CompletionHandler) {
        socket?.on("channelCreated", callback: { (dataArray, ack) in
            guard let channelName = dataArray[0] as? String else { return }
            guard let channelDescr = dataArray[1] as? String else { return }
            guard let channelId = dataArray[2] as? String else { return }
            
            let newChannel = Channel(channelTitle: channelName, channelDescription: channelDescr, id: channelId)
            MessageService.instance.channels.append(newChannel)
            
            completion(true)
        })
    }
    
}
