//
//  QuestionaireViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import CoreData
import Firebase
import AudioToolbox
import AVFoundation

class QuestionaireViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //REGION: variables
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    
    var questions : [String] = ["What is your name?", "When would you like to be reminded?", "How are you feeling today?"]
    var moods:[String] = ["Fantastic", "Good", "Okay", "Bad", "Awful"]
    var mood_dict:[String:Int16] = ["Fantastic":0, "Good":1, "Okay":2, "Bad":3, "Awful":4]
    var finalMood:String = ""
    
    var questionIndex : Int = 0
    
    //MARK: On Start
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.navigationItem.hidesBackButton = true
        submitButton.isHidden = true
        nameField.isHidden = true
        pickerView.isHidden = true
        timePicker.isHidden = true
        
        titleLabel.text = "Hello there! Welcome to the app, let's start by answering a few questions."
        questionText.text = ""
        finalMood = moods[0]
    }
    
    //for darkmode in settings
    override func viewWillAppear(_ animated: Bool) {
        
        //so the stuff is specific to each user
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        if UserDefaults.standard.bool(forKey: email + "dark mode") {
            view.backgroundColor = .darkBackground
            titleLabel.textColor = .lightBackground
            questionText.textColor = .lightBackground
            
        } else {
            view.backgroundColor = .lightBackground
            titleLabel.textColor = .darkBackground
            questionText.textColor = .darkBackground
        }
        
        if UserDefaults.standard.bool(forKey: email + "large font style") {
            questionText.font = questionText.font.withSize(30)
            titleLabel.font = titleLabel.font.withSize(30)
        }
        else {
            questionText.font = questionText.font.withSize(16)
            titleLabel.font = titleLabel.font.withSize(16)
        }
    }
    
    //MARK: Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return moods.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return moods[row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(moods[row])
        finalMood = moods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()

        //label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "AmericanTypewriter", size: 18)

        // where data is an Array of String
        label.text = moods[row]

        return label
      }

    
    //MARK: Button Actions
    @IBAction func onNextPressed(_ sender: Any) {
        
        //so the stuff is specific to each user
        let user = Auth.auth().currentUser
        let leEmail = user?.email ?? "none"
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        switch questionIndex {
        case 0:
            nameField.isHidden = false
            questionText.text = questions[questionIndex]
            titleLabel.text = ""
            break
        case 1:
            nameField.isHidden = true
            questionText.text = questions[questionIndex]
            timePicker.isHidden = false
            
            break
        case 2:
            timePicker.isHidden = true
            pickerView.isHidden = false
            submitButton.isHidden = false
            nextButton.isHidden = true
            questionText.text = questions[questionIndex]
            
            //creates and stores user in core data
            let defaults = UserDefaults.standard
            let email = defaults.string(forKey:"userID")
            let default_pic = UIImage(named: "default_propic")
            storeUser(name:nameField.text != nil ? nameField.text! : "User",mail:email!,propic:default_pic!,notime:timePicker.date)
            
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
            
            break
        default:
            print("Something has gone horribly wrong")
            break
        }
        
        questionIndex += 1
        
        //allow vibration if button pressed
        if UserDefaults.standard.bool(forKey: leEmail + "vibration") {
            generator.impactOccurred()
        }
        
        if UserDefaults.standard.bool(forKey: leEmail + "sound effect") {
            AudioServicesPlaySystemSound(1026)
        }
    }
    
    @IBAction func onSubmitPressed(_ sender: Any) {
        //so the stuff is specific to each user
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        //TODO: save name and finalSelection to core data
        

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Log", into: context)

        entity.setValue(mood_dict[finalMood], forKey: "mood") //selective mood *gulp*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        entity.setValue(dateFormatter.string(from: Date()), forKey: "date")
        let logOwner = UserDefaults.standard.string(forKey:"userID")!
        entity.setValue(logOwner, forKey: "logOwner")

        do{
            try context.save()
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        performSegue(withIdentifier: "CalendarSegue", sender: nil)
        
        //allow for vibration if button pressed
        if UserDefaults.standard.bool(forKey: email + "vibration") {
            generator.impactOccurred()
        }
        
        if UserDefaults.standard.bool(forKey: email + "sound effect") {
            AudioServicesPlaySystemSound(1026)
        }
    }
    
    //MARK: Helper Functions
    //stores user in CoreData
    func storeUser(name n:String,mail e:String,propic p:UIImage,notime:Date) {
        
        self.view.endEditing(true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        
        entity.setValue(n, forKey: "name")
        entity.setValue(e, forKey: "email")
        
        let p_data = p.jpegData(compressionQuality: 0.75)
        entity.setValue(p_data, forKey: "propic")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        entity.setValue(dateFormatter.string(from: notime), forKey: "notif")
        
        do{
            try context.save()
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    //hides keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
