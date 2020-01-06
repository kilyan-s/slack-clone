//
//  ChatVC.swift
//  slackish
//
//  Created by Kilyan SOCKALINGUM on 10/12/2019.
//  Copyright © 2019 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //Outlets
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var channelNameLbl: UILabel!
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var typingUserLbl: UILabel!
    
    //Variables
    var isTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bind view to keyboard so that it scrolls when the keyboard appear
        view.bindToKeyboard()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        //automatic sizing for cells
        tableview.estimatedRowHeight = 80
        tableview.rowHeight = UITableView.automaticDimension
        
        sendButton.isHidden = true
        
        //Gestures to open drawer menu
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.view.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        //Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.userDataDidChange(_:)), name: NOTIF_USER_DATA_CHANGED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.channelSelected(_:)), name: NOTIF_CHANNEL_SELECTED, object: nil)
        
        //Socket new chat message
//        SocketService.instance.getChatMessage { (success) in
//            if success {
//                self.tableview.reloadData()
//
//                let endIndexPath = IndexPath(row: MessageService.instance.messages.count - 1, section: 0)
//                self.tableview.scrollToRow(at: endIndexPath, at: .bottom, animated: true)
//            }
//        }
        
        SocketService.instance.getChatMessage { (newMessage) in
            if newMessage.channelId == MessageService.instance.selectedChannel?.id && AuthService.instance.isLoggedIn {
                MessageService.instance.messages.append(newMessage)
                
                self.tableview.reloadData()
                let endIndexPath = IndexPath(row: MessageService.instance.messages.count - 1, section: 0)
                self.tableview.scrollToRow(at: endIndexPath, at: .bottom, animated: true)
            }
        }
        
        //Socket new typing user
        SocketService.instance.getTypingUsers { (typingUsers) in
            guard let channelId = MessageService.instance.selectedChannel?.id else { return }
            var names = ""
            var numberOfTypers = 0
            
            debugPrint(typingUsers)
            
            for (typingUser, channel) in typingUsers {
                //Check if typing user is not self and channel is our current selected channel
                if typingUser != "" && typingUser != UserDataService.instance.name && channel == channelId {
                    print("User Typing : \(typingUser)")
                    if names == "" {
                        names = typingUser
                    } else {
                        names = "\(names), \(typingUser)"
                    }
                    numberOfTypers += 1
                }
            }
            
            if numberOfTypers > 0 && AuthService.instance.isLoggedIn {
                let verb = numberOfTypers > 1 ? "are" : "is"
                self.typingUserLbl.text = "\(names) \(verb) typing a message"
            } else {
                self.typingUserLbl.text = ""
            }
        }
        
        //If user is already logged in when app launch, get user infos
        if AuthService.instance.isLoggedIn {
            AuthService.instance.findUserByEmail { (success) in
                NotificationCenter.default.post(name: NOTIF_USER_DATA_CHANGED, object: nil)
            }
        }
        
        //End editing when tap on ChatVC view occurs
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatVC.handleTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn {
            guard let channelId = MessageService.instance.selectedChannel?.id else { return }
            guard let message = messageTxt.text , messageTxt.text != "" else { return }
            
            SocketService.instance.addMessage(message: message, userId: UserDataService.instance.id, channelId: channelId) { (success) in
                if success {
                    self.messageTxt.text = ""
                    self.messageTxt.resignFirstResponder()
                    SocketService.instance.socket?.emit("stopType", UserDataService.instance.name, channelId)
                }
            }
        }
    }
    
    @IBAction func messageBoxEditing(_ sender: Any) {
        guard let channelId = MessageService.instance.selectedChannel?.id else { return }
        
        if messageTxt.text == "" {
            isTyping = false
            sendButton.isHidden = true
            //Send message to socket == user stop typing
            SocketService.instance.socket?.emit("stopType", UserDataService.instance.name, channelId)
            
        } else {
            if isTyping == false {
                sendButton.isHidden = false
                //Send message to socket == user start typing
                SocketService.instance.socket?.emit("startType", UserDataService.instance.name, channelId)
            }
            isTyping = true
        }
    }
    
    
    @objc func userDataDidChange(_ notification: Notification) {
        if AuthService.instance.isLoggedIn {
            onLoginGetMessages()
        } else {
            channelNameLbl.text = "Please log in"
            tableview.reloadData()
        }
    }
    
    @objc func channelSelected(_ notification: Notification) {
        updateWithChannel()
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    func updateWithChannel() {
        let channelName = MessageService.instance.selectedChannel?.channelTitle ?? ""
        channelNameLbl.text = "#\(channelName)"
        
        //API Request to get messages for selected channel
        getMessages()
    }
    
    func onLoginGetMessages() {
        MessageService.instance.findAllChannel { (success) in
            if success {
                if MessageService.instance.channels.count > 0 {
                    MessageService.instance.selectedChannel = MessageService.instance.channels[0]
                    self.updateWithChannel()
                } else {
                    self.channelNameLbl.text = "No channels yet"
                }
            }
        }
    }
    
    
    func getMessages() {
        guard let channelId = MessageService.instance.selectedChannel?.id else { return }
        //API call to get the messages
        MessageService.instance.findAllMessagesForChannel(channelId: channelId) { (success) in
            if success {
                self.tableview.reloadData()
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageService.instance.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell {
            let message = MessageService.instance.messages[indexPath.row]
            cell.configureCell(message: message)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
