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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var soundEffectLabel: UILabel!
    @IBOutlet weak var soundEffectsSwitch: UISwitch!
    
    var userEntity : NSManagedObject? = nil
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        let leEmail = user?.email ?? "none"
        
        picker.delegate = self
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "userID")
        userEntity = retrieveUser(userID:email!)
        
        profilePic.contentMode = .scaleAspectFill
        
        if (userEntity != nil) {
            
            //changing this real quick to email + , see if that helps
            let name = userEntity!.value(forKey: "name") as? String
            if (name != nil) {
                nameField.text = name
            }
            let propicdata = userEntity?.value(forKey:"propic") as? Data
            if (propicdata != nil) {
                profilePic.image = UIImage(data:propicdata!)
            }
            let notifdate = userEntity?.value(forKey: "notif") as? String
            if (notifdate != nil) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat =  "HH:mm"
                timePicker.date = dateFormatter.date(from: notifdate!)!
            }
        }
        
        let swipeRecogRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
        swipeRecogRight.direction = .right
        self.view.addGestureRecognizer(swipeRecogRight)
        
        //making code vibrate
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    

    @IBAction func soundEffect(_ sender: UISwitch) {
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"

        if soundEffectsSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: email + "sound effect")
        } else {
            UserDefaults.standard.setValue(false, forKey: email + "sound effect")
        }
    }
    
    @IBAction func darkMode(_ sender: UISwitch) {
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        if darkModeSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: email + "dark mode")
            view.backgroundColor = .darkBackground
            darkModeLabel.textColor = .lightBackground
            fontStyleLabel.textColor = .lightBackground
            vibrationLabel.textColor = .lightBackground
            nameField.backgroundColor = .darkGray
            nameField.textColor = .lightBackground
            timeLabel.textColor = .lightBackground
            soundEffectLabel.textColor = .lightBackground
            settingsLabel.textColor = .lightBackground
            profileLabel.textColor = .lightBackground
            timePicker.setValue(UIColor.lightBackground, forKey: "textColor")
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController?.navigationBar.barStyle = .black
        } else {
            UserDefaults.standard.setValue(false, forKey: email + "dark mode")
            view.backgroundColor = .lightBackground
            soundEffectLabel.textColor = .darkBackground
            darkModeLabel.textColor = .darkBackground
            fontStyleLabel.textColor = .darkBackground
            vibrationLabel.textColor = .darkBackground
            profileLabel.textColor = .darkBackground
            nameField.backgroundColor = .white
            nameField.textColor = .darkBackground
            timeLabel.textColor = .darkBackground
            settingsLabel.textColor = .darkBackground
            timePicker.setValue(UIColor.darkBackground, forKey: "textColor")
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navigationController?.navigationBar.barStyle = .default
        }
    }
    
    @IBAction func fontStyle(_ sender: UISwitch) {
        
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        if fontStyleSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: email + "large font style")
            soundEffectLabel.font = soundEffectLabel.font.withSize(30)
            fontStyleLabel.font = fontStyleLabel.font.withSize(30)
            darkModeLabel.font = darkModeLabel.font.withSize(30)
            vibrationLabel.font = vibrationLabel.font.withSize(30)
            nameField.font = nameField.font?.withSize(30)
            timeLabel.font = timeLabel.font.withSize(30)
            settingsLabel.font = settingsLabel.font.withSize(35)
            profileLabel.font = profileLabel.font.withSize(35)
        } else {
            UserDefaults.standard.setValue(false, forKey: email + "large font style")
            soundEffectLabel.font = soundEffectLabel.font.withSize(16)
            fontStyleLabel.font = fontStyleLabel.font.withSize(16)
            darkModeLabel.font = darkModeLabel.font.withSize(16)
            vibrationLabel.font = vibrationLabel.font.withSize(16)
            nameField.font = nameField.font?.withSize(16)
            timeLabel.font = timeLabel.font.withSize(16)
            settingsLabel.font = settingsLabel.font.withSize(21)
            profileLabel.font = profileLabel.font.withSize(21)
        }
    }
    
    @IBAction func vibration(_ sender: UISwitch) {
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
           
        if vibrationSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: email + "vibration")
            generator.impactOccurred()
        } else {
            UserDefaults.standard.setValue(false, forKey:email + "vibration")
        }
    }
    
    //updates user name in coredata
    @IBAction func updateName(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        if (userEntity != nil) {
            self.view.endEditing(true)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            userEntity?.setValue(nameField.text, forKey: email + "name")
            
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
        
        if soundEffectsSwitch.isOn {
            AudioServicesPlaySystemSound(1026)
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
        
        //sound when click button
        if soundEffectsSwitch.isOn {
            AudioServicesPlaySystemSound(1026)
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
        
        //sound when click button
        if soundEffectsSwitch.isOn {
            AudioServicesPlaySystemSound(1026)
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
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        //allow for vibration when button clicked
        if vibrationSwitch.isOn {
            generator.impactOccurred()
        }
        
        //sound when click button
        if soundEffectsSwitch.isOn {
            AudioServicesPlaySystemSound(1026)
        }
    }
    
    @IBAction func onTimeChanged(_ sender: Any) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["repeatingNotif"])
        print("Time selected is: \(timePicker.date)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        userEntity?.setValue(dateFormatter.string(from: timePicker.date), forKey: "notif")
        
        do{
            try context.save()
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            
            abort()
        }
        
        // create an object that holds the data for our notification
        let notification = UNMutableNotificationContent()
        notification.title = "Time to check-in!"
        notification.body = "Don't forget to chart your mood daily!"

        // set up the notification's trigger
        let now = Date()
        let selectedDate = Calendar.current.dateComponents([.hour, .minute, .second], from: timePicker.date)
        var triggerDate = Calendar.current.dateComponents([.hour, .minute, .second], from: now)
        
        //set one to trigger @ a date
        triggerDate.hour = selectedDate.hour
        triggerDate.minute = selectedDate.minute
        triggerDate.second = 0
        
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

        // set up a request to tell iOS to submit the notification with that trigger
        let request = UNNotificationRequest(identifier: "repeatingNotif",
                                            content: notification,
                                            trigger: notificationTrigger)


        // submit the request to iOS
        UNUserNotificationCenter.current().add(request) { (error) in
            print("Request error: ",error as Any)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        if vibrationSwitch.isOn {
            generator.impactOccurred()
        }
        
        //sound when click button
        if soundEffectsSwitch.isOn {
            AudioServicesPlaySystemSound(1026)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //so the stuff is specific to each user
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        if UserDefaults.standard.bool(forKey: email + "sound effect") {
            soundEffectsSwitch.setOn(true, animated: false)
        } else {
            soundEffectsSwitch.setOn(false, animated: false)
        }
        
        //view for dark mode
        if UserDefaults.standard.bool(forKey: email + "dark mode") {
            darkModeSwitch.setOn(true, animated: false)
            view.backgroundColor = .darkBackground
            soundEffectLabel.textColor = .lightBackground
            darkModeLabel.textColor = .lightBackground
            fontStyleLabel.textColor = .lightBackground
            vibrationLabel.textColor = .lightBackground
            settingsLabel.textColor = .lightBackground
            timeLabel.textColor = .lightBackground
            profileLabel.textColor = .lightBackground
            nameField.backgroundColor = .darkGray
            nameField.textColor = .lightBackground
            timePicker.setValue(UIColor.lightBackground, forKey: "textColor")
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController?.navigationBar.barStyle = .black
        }
        else {
            darkModeSwitch.setOn(false, animated: false)
            view.backgroundColor = .lightBackground
            soundEffectLabel.textColor = .darkBackground
            darkModeLabel.textColor = .darkBackground
            fontStyleLabel.textColor = .darkBackground
            vibrationLabel.textColor = .darkBackground
            settingsLabel.textColor = .darkBackground
            timeLabel.textColor = .darkBackground
            profileLabel.textColor = .darkBackground
            nameField.backgroundColor = .cellBackground
            nameField.textColor = .darkBackground
            timePicker.setValue(UIColor.darkBackground, forKey: "textColor")
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navigationController?.navigationBar.barStyle = .default
        }
        
        //view for font size
        if UserDefaults.standard.bool(forKey: email + "large font style") {
            fontStyleSwitch.setOn(true, animated: false)
            soundEffectLabel.font = soundEffectLabel.font.withSize(30)
            fontStyleLabel.font = fontStyleLabel.font.withSize(30)
            darkModeLabel.font = darkModeLabel.font.withSize(30)
            vibrationLabel.font = vibrationLabel.font.withSize(30)
            nameField.font = nameField.font?.withSize(30)
            timeLabel.font = timeLabel.font.withSize(30)
            settingsLabel.font = settingsLabel.font.withSize(35)
            profileLabel.font = profileLabel.font.withSize(35)
        }
        else {
            fontStyleSwitch.setOn(false, animated: false)
            soundEffectLabel.font = soundEffectLabel.font.withSize(16)
            fontStyleLabel.font = fontStyleLabel.font.withSize(16)
            darkModeLabel.font = darkModeLabel.font.withSize(16)
            vibrationLabel.font = vibrationLabel.font.withSize(16)
            nameField.font = nameField.font?.withSize(16)
            timeLabel.font = timeLabel.font.withSize(16)
            settingsLabel.font = settingsLabel.font.withSize(21)
            profileLabel.font = profileLabel.font.withSize(21)
        }
        
        //view for vibration
        if UserDefaults.standard.bool(forKey: email + "vibration") {
            vibrationSwitch.setOn(true, animated: false)
            generator.impactOccurred()
        }
        else {
            vibrationSwitch.setOn(false, animated: false)
        }
    }
    
    //MARK: Button Actions
    //logs user out(removes userdefaults)
    @IBAction func logoutButton(_ send:UIButton) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey:"userID")
        defaults.synchronize()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        if vibrationSwitch.isOn {
            generator.impactOccurred()
        }
        
        if soundEffectsSwitch.isOn {
            AudioServicesPlaySystemSound(1026)
        }
    }
    
    @IBAction func swipeRight (recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .right {
            print("Right swipe")
            _ = navigationController?.popViewController(animated: true)
         }
    }
}
