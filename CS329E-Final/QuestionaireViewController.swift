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

class QuestionaireViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //REGION: variables
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var questions : [String] = ["What is your name?", "How are you feeling today?"]
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
        
        titleLabel.text = "Hello there! Welcome to the app, let's start by answering a few questions."
        questionText.text = ""
        finalMood = moods[0]
    }
    
    //for darkmode in settings
    override func viewWillAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "dark mode") {
            view.backgroundColor = .black
            titleLabel.textColor = .white
            questionText.textColor = .white
            
        } else {
            view.backgroundColor = .white
            titleLabel.textColor = .black
            questionText.textColor = .black
        }
        
        if UserDefaults.standard.bool(forKey:"large font style") {
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return moods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(moods[row])
        finalMood = moods[row]
    }
    
    //MARK: Button Actions
    @IBAction func onNextPressed(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        switch questionIndex {
        case 0:
            nameField.isHidden = false
            questionText.text = questions[questionIndex]
            titleLabel.text = ""
            break
        case 1:
            let defaults = UserDefaults.standard
            let email = defaults.string(forKey:"userID")
            storeUser(name:nameField.text!,mail:email!)
            nameField.isHidden = true
            nameField.text = ""
            questionText.text = questions[questionIndex]
            pickerView.isHidden = false
            submitButton.isHidden = false
            nextButton.isHidden = true
            break
        default:
            print("Something has gone horribly wrong")
            break
        }
        
        questionIndex += 1
        
        //allow vibration if button pressed
        if UserDefaults.standard.bool(forKey: "vibration") {
            generator.impactOccurred()
        }
    }
    
    @IBAction func onSubmitPressed(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        //TODO: save name and finalSelection to core data
        

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Log", into: context)

        entity.setValue(mood_dict[finalMood], forKey: "mood")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        entity.setValue(dateFormatter.string(from: Date()), forKey: "date")

        
        do{
            try context.save()
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        performSegue(withIdentifier: "CalendarSegue", sender: nil)
        
        //allow for vibration if button pressed
        if UserDefaults.standard.bool(forKey: "vibration") {
            generator.impactOccurred()
        }
    }
    
    //MARK: Helper Functions
    //stores user in CoreData
    func storeUser(name n:String,mail e:String) {
        self.view.endEditing(true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        
        entity.setValue(n, forKey: "name")
        entity.setValue(e, forKey: "email")
        
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
