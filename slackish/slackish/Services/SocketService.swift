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
    
    //CONNECTION
    func establishConnection() {
        socket?.connect()
    }
    
    func closeConnection() {
        socket?.disconnect()
    }
    
    //CHANNELS
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
    
    //MESSAGE
    func addMessage(message: String, userId: String, channelId: String, completion: @escaping CompletionHandler) {
        let user = UserDataService.instance
        
        socket?.emit("newMessage", message, userId, channelId, user.name, user.avatarName, user.avatarColor)
        
        completion(true)
    }
    
    func getChatMessage(completion: @escaping (_ newMessage: Message) -> Void ){
        socket?.on("messageCreated", callback: { (dataArray, ack) in
            guard let messageBody = dataArray[0] as? String else { return }
            guard let channelId = dataArray[2] as? String else { return }
            guard let username = dataArray[3] as? String else { return }
            guard let userAvatar = dataArray[4] as? String else { return }
            guard let userAvatarColor = dataArray[5] as? String else { return }
            guard let id = dataArray[6] as? String else { return }
            guard let timestamp = dataArray[7] as? String else { return }
            
            let newMessage = Message(message: messageBody, username: username, channelId: channelId, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timestamp: timestamp)
            
            completion(newMessage)
            
//            //check if incomming message is in the same channel as us
//            if(channelId == MessageService.instance.selectedChannel?.id && AuthService.instance.isLoggedIn) {
//                MessageService.instance.messages.append(newMessage)
//
//                completion(true)
//            } else {
//                //Not the same channel
//                completion(false)
//            }
        })
    }
    
    
    func getTypingUsers(_ completion: @escaping (_ typingUsers: [String: String]) -> Void) {
        socket?.on("userTypingUpdate", callback: { (dataArray, ack) in
            guard let typingUsers = dataArray[0] as? [String: String] else { return }
            completion(typingUsers)
        })
    }
    
}
