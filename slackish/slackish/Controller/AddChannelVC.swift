//
//  AddChannelVC.swift
//  slackish
//
//  Created by Kilyan SOCKALINGUM on 02/01/2020.
//  Copyright © 2020 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit

class AddChannelVC: UIViewController {
    //Outlets
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var channelDescrTxt: UITextField!
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }


    @IBAction func closeModalPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createChannelPressed(_ sender: Any) {
        
    }
    
    func setupView() {
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(AddChannelVC.closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
        
        nameTxt.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: PURPLE_PLACEHOLDER])
        channelDescrTxt.attributedPlaceholder = NSAttributedString(string: "Description", attributes: [NSAttributedString.Key.foregroundColor: PURPLE_PLACEHOLDER])
    }
    
    @objc func closeTap(_ recognizer:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
