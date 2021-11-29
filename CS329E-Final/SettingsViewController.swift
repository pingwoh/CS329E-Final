//
//  SettingsViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import Firebase
import CoreData

protocol AddSettings {
    func storeSettings(darkMode: String)
}

class SettingsViewController: UIViewController, AddSettings {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var darkModeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func darkMode(_ sender: UISwitch) {
        if darkModeSwitch.isOn {
            view.backgroundColor = .black
            darkModeLabel.textColor = .white
            //darkModeSwitch.setOn(false, animated: true)
            print("On") //testcase
        } else {
            view.backgroundColor = .white
            darkModeLabel.textColor = .black
            //darkModeSwitch.setOn(true, animated: true)
            print("off") //test case
        }
    }
    
    internal func storeSettings(darkMode: String) {
        let user = Auth.auth().currentUser
        let email:String = user?.email ?? "none"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let settings = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"User")
        var fetchedResults:[NSManagedObject]? = nil
        
        settings.setValue(darkModeSwitch, forKey: email + "darkMode")
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
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

//who knows if we need this
func retrieveSettings() -> [NSManagedObject] {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName:"User")
    var fetchedResults:[NSManagedObject]? = nil
    
        let predicate = NSPredicate(format: "name CONTAINS[c] 'ie'")
        request.predicate = predicate
    
    do {
        try fetchedResults = context.fetch(request) as? [NSManagedObject]
    } catch {
        // If an error occurs
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
    }
    
    return(fetchedResults)!
}
