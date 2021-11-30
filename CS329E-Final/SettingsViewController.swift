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

class SettingsViewController: UIViewController, AddSettings, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    
    var userEntity : NSManagedObject? = nil
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey:"userID")
        userEntity = retrieveUser(userID:email!)
        
        profilePic.contentMode = .scaleToFill
        
        if (userEntity != nil) {
            nameField.text = userEntity!.value(forKey:"name") as? String
            let propicdata = userEntity?.value(forKey:"propic") as? Data
            if (propicdata != nil) {
                profilePic.image = UIImage(data:propicdata!)
            }
        }
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
    
    //updates user name in coredata
    @IBAction func updateName(_ sender: UIButton) {
        if (userEntity != nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            userEntity?.setValue(nameField.text, forKey:"name")
            
            do{
                try context.save()
                
                let alert = UIAlertController(title: "Name Change", message: "New name successfully changed!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated:true)
            } catch{
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                
                let alert = UIAlertController(title: "Name Change", message: "Something went wrong!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated:true)
                
                abort()
            }
        }
    }
    
    //hides keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //brings up imagepicker to update user profile picture in core data
    @IBAction func updateProfilePic(_ sender: UIButton) {
        if (userEntity != nil) {
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }
    }
    
    //updates user profile picture in core data
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.originalImage] as! UIImage
        let imageData = chosenImage.jpegData(compressionQuality: 0.75)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        userEntity?.setValue(imageData, forKey:"propic")
        
        do{
            try context.save()
            
            let alert = UIAlertController(title: "Profile Picture Change", message: "New profile picture successfully changed!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated:true)
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            
            let alert = UIAlertController(title: "Profile Picture Change", message: "Something went wrong!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated:true)
            
            abort()
        }
        
        let propicdata = userEntity?.value(forKey:"propic") as? Data
        if (propicdata != nil) {
            profilePic.image = UIImage(data:propicdata!)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //dismisses imagepicker if no image is selected
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //retrieves user from CoreData
    private func retrieveUser(userID e:String) -> NSManagedObject? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"User")
        var fetchedResults:[NSManagedObject]? = nil
        
        let predicate = NSPredicate(format: "email == '\(e)'")
        request.predicate = predicate
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if fetchedResults!.count>0 {
            return fetchedResults![0]
        }
        else {
            return nil
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
