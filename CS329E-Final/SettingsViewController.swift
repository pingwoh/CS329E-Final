//
//  SettingsViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var darkModeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func darkMode(_ sender: UISwitch) {
        let user = Auth.auth().currentUser
        let email:String = user?.email ?? "none"
        UserDefaults.standard.set(sender.isOn, forKey: email + "dark mode")
        UserDefaults.standard.synchronize()
        
        if UserDefaults.standard.bool(forKey: email + "dark mode") {
            view.backgroundColor = .black
            darkModeLabel.textColor = .white
            
        } else {
            view.backgroundColor = .white
            darkModeLabel.textColor = .black
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        let email:String = user?.email ?? "none"
        
        if UserDefaults.standard.bool(forKey: email + "dark mode") {
            view.backgroundColor = .black
            darkModeLabel.textColor = .white
            
        } else {
            view.backgroundColor = .white
            darkModeLabel.textColor = .black
        }
    }

}

