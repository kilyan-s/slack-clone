//
//  UserDataService.swift
//  slackish
//
//  Created by Kilyan SOCKALINGUM on 11/12/2019.
//  Copyright © 2019 Kilyan SOCKALINGUM. All rights reserved.
//

import Foundation

class UserDataService {
    static let instance = UserDataService()
    
    public private(set) var id = ""
    public private(set) var avatarColor = ""
    public private(set) var avatarName = ""
    public private(set) var email = ""
    public private(set) var name  = ""
    
    func setUserData(id: String, color: String, avatarName: String, email: String, name: String) {
        self.id = id
        self.avatarColor = color
        self.avatarName = avatarName
        self.name = name
        self.email = email
    }
    
    func setAvatarName(avatarName: String) {
        self.avatarName = avatarName
    }
    
    func returnUIColor(components: String) -> UIColor {
        let scanner = Scanner(string: components)
        let skipped = CharacterSet(charactersIn: "[], ")
        let comma = CharacterSet(charactersIn: ",")
        
        scanner.charactersToBeSkipped = skipped
        
        var r, g, b, a: String?
        r = scanner.scanUpToCharacters(from: comma)
        g = scanner.scanUpToCharacters(from: comma)
        b = scanner.scanUpToCharacters(from: comma)
        a = scanner.scanUpToCharacters(from: comma)
        
        let defaultColor = UIColor.lightGray
        
        guard let rUnwrapped = r else { return defaultColor }
        guard let gUnwrapped = g else { return defaultColor }
        guard let bUnwrapped = b else { return defaultColor }
        guard let aUnwrapped = a else { return defaultColor }
        
        let rFloat = CGFloat((rUnwrapped as NSString).doubleValue)
        let gFloat = CGFloat((gUnwrapped as NSString).doubleValue)
        let bFloat = CGFloat((bUnwrapped as NSString).doubleValue)
        let aFloat = CGFloat((aUnwrapped as NSString).doubleValue)

        let uiColor = UIColor(red: rFloat, green: gFloat, blue: bFloat, alpha: aFloat)
        return uiColor
    }
    
    func logoutUser() {
         self.id = ""
         self.avatarColor = ""
         self.avatarName = ""
         self.name = ""
         self.email = ""
        
        AuthService.instance.isLoggedIn = false
        AuthService.instance.userEmail = ""
        AuthService.instance.authToken = ""
    }
}
