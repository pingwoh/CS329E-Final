//
//  SettingsViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import Firebase
import CoreData
import AVFoundation
import AudioToolbox

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var fontStyleLabel: UILabel!
    @IBOutlet weak var fontStyleSwitch: UISwitch!
    @IBOutlet weak var vibrationLabel: UILabel!
    @IBOutlet weak var vibrationSwitch: UISwitch!
    
    
    var userEntity : NSManagedObject? = nil
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey:"userID")
        userEntity = retrieveUser(userID:email!)
        
        profilePic.contentMode = .scaleAspectFill
        
        if (userEntity != nil) {
            let name = userEntity!.value(forKey:"name") as? String
            if (name != nil) {
                nameField.text = name
            }
            let propicdata = userEntity?.value(forKey:"propic") as? Data
            if (propicdata != nil) {
                profilePic.image = UIImage(data:propicdata!)
            }
        }
        
        //making code vibrate
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @IBAction func darkMode(_ sender: UISwitch) {
        if darkModeSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey:"dark mode")
            view.backgroundColor = .black
            darkModeLabel.textColor = .lightText
            fontStyleLabel.textColor = .lightText
            vibrationLabel.textColor = .lightText
            nameField.backgroundColor = .darkGray
            nameField.textColor = .lightGray
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController?.navigationBar.barStyle = .black
        }
        else {
            UserDefaults.standard.setValue(false, forKey:"dark mode")
            view.backgroundColor = .white
            darkModeLabel.textColor = .black
            fontStyleLabel.textColor = .black
            vibrationLabel.textColor = .black
            nameField.backgroundColor = .white
            nameField.textColor = .black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navigationController?.navigationBar.barStyle = .default
        }
    }
    
    @IBAction func fontStyle(_ sender: UISwitch) {
        if fontStyleSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey:"large font style")
            fontStyleLabel.font = fontStyleLabel.font.withSize(30)
            darkModeLabel.font = darkModeLabel.font.withSize(30)
            vibrationLabel.font = vibrationLabel.font.withSize(30)
            
        } else {
            UserDefaults.standard.setValue(false, forKey:"large font style")
            fontStyleLabel.font = fontStyleLabel.font.withSize(16)
            darkModeLabel.font = darkModeLabel.font.withSize(16)
            vibrationLabel.font = vibrationLabel.font.withSize(16)
        }
    }
    
    @IBAction func vibration(_ sender: UISwitch) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
           
        if vibrationSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey:"vibration")
            generator.impactOccurred()
        } else {
            UserDefaults.standard.setValue(false, forKey:"vibration")
        }
    }
    
    //updates user name in coredata
    @IBAction func updateName(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        if (userEntity != nil) {
            self.view.endEditing(true)
            
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
        
        //allow vibration when clicking button
        if vibrationSwitch.isOn {
            generator.impactOccurred()
        }
    }
    
    //hides keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //brings up imagepicker to update user profile picture in core data
    @IBAction func updateProfilePic(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        if (userEntity != nil) {
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }
        
        //vibration when clicking button
        if vibrationSwitch.isOn {
            generator.impactOccurred()
        }
    }
    
    @IBAction func cameraProfilePic(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) {
                    accessGranted in
                    guard accessGranted == true else { return }
                }
            case .authorized:
                break
            default:
                print("Access denied")
                return
            }
            
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            
            present(picker, animated: true, completion: nil)
        
        } else {
            
            let alertVC = UIAlertController(
                title: "No camera",
                message: "Buy a better phone",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
            
        }
        
        //allow for vibration when clicking button
        if vibrationSwitch.isOn {
            generator.impactOccurred()
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
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            
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
    
    @IBAction func resetLogs() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Log")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest:fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult
            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }
            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects,into:[context])
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        //allow for vibration when button clicked
        if vibrationSwitch.isOn {
            generator.impactOccurred()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        //view for dark mode
        if UserDefaults.standard.bool(forKey:"dark mode") {
            darkModeSwitch.setOn(true, animated: false)
            view.backgroundColor = .black
            darkModeLabel.textColor = .white
            fontStyleLabel.textColor = .white
            vibrationLabel.textColor = .white
            nameField.backgroundColor = UIColor.init(red: 0.11, green: 0.11, blue: 0.118, alpha: 1)
            nameField.textColor = .lightGray
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController?.navigationBar.barStyle = .black
        }
        else {
            darkModeSwitch.setOn(false, animated: false)
            view.backgroundColor = .white
            darkModeLabel.textColor = .black
            fontStyleLabel.textColor = .black
            vibrationLabel.textColor = .black
            nameField.backgroundColor = .white
            nameField.textColor = .black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navigationController?.navigationBar.barStyle = .default
        }
        
        //view for font size
        if UserDefaults.standard.bool(forKey:"large font style") {
            fontStyleSwitch.setOn(true, animated: false)
            fontStyleLabel.font = fontStyleLabel.font.withSize(30)
            darkModeLabel.font = darkModeLabel.font.withSize(30)
            vibrationLabel.font = vibrationLabel.font.withSize(30)
        }
        else {
            fontStyleSwitch.setOn(false, animated: false)
            fontStyleLabel.font = fontStyleLabel.font.withSize(16)
            darkModeLabel.font = darkModeLabel.font.withSize(16)
            vibrationLabel.font = vibrationLabel.font.withSize(16)
        }
        
        //view for vibration
        if UserDefaults.standard.bool(forKey: "vibration") {
            vibrationSwitch.setOn(true, animated: false)
            generator.impactOccurred()
        }
        else {
            vibrationSwitch.setOn(false, animated: false)
        }
    }
}
