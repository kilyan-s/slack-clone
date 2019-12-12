 //
//  CreateAccountVC.swift
//  slackish
//
//  Created by Kilyan SOCKALINGUM on 10/12/2019.
//  Copyright © 2019 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {

    //Outlets
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //Variables
    var avatarName = "profileDefault"
    var avatarColor = "[0.5, 0.5, 0.5, 1]"
    var bgColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View did appear")
        if UserDataService.instance.avatarName != "" {
            print("avatar name \(UserDataService.instance.avatarName)")
            userImg.image = UIImage(named: UserDataService.instance.avatarName)
            avatarName = UserDataService.instance.avatarName
            
            if avatarName.contains("light") && bgColor == nil {
                self.userImg.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    @IBAction func closePressed(_ sender: Any) {
        performSegue(withIdentifier: UNWIND, sender: nil)
    }
    
    @IBAction func pickAvatarPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_AVATAR_PICKER, sender: nil)
    }
    
    @IBAction func pickBgColorPressed(_ sender: Any) {
        let r = CGFloat(arc4random_uniform(255)) / 255
        let g = CGFloat(arc4random_uniform(255)) / 255
        let b = CGFloat(arc4random_uniform(255)) / 255
        
        bgColor = UIColor(red: r, green: g, blue: b, alpha: 1)
        UIView.animate(withDuration: 0.2) {
            self.userImg.backgroundColor = self.bgColor
        }
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimating()
        
        guard let username = usernameTxt.text , usernameTxt.text != "" else { return }
        guard let email = emailTxt.text , emailTxt.text != "" else { return }
        guard let password = passwordTxt.text, passwordTxt.text != "" else { return }
        
        AuthService.instance.registerUser(email: email, password: password) { (success) in
            if success {
                print("Registered user !")
                AuthService.instance.loginUser(email: email, password: password) { (success) in
                    if success {
                        print("Logged in user !", AuthService.instance.authToken)
                        AuthService.instance.createUser(name: username, email: email, avatarName: self.avatarName, avatarColor: self.avatarColor) { (success) in
                            if success {
                                print("User created !")
                                self.spinner.isHidden = true
                                self.spinner.stopAnimating()
                                self.performSegue(withIdentifier: UNWIND, sender: nil)
                                
                                NotificationCenter.default.post(name: NOTIF_USER_DATA_CHANGED, object: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupView() {
        spinner.isHidden = true
        
        usernameTxt.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: PURPLE_PLACEHOLDER])
        emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: PURPLE_PLACEHOLDER])
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: PURPLE_PLACEHOLDER])
        
        //Tap on view to close keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
 }
