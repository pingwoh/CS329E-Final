//
//  QuestionaireViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import CoreData
import Firebase

class QuestionaireViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //REGION: variables
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var questions : [String] = ["What is your name?", "How are you feeling today?"]
    var answers : [String] = ["Fantastic", "Good", "Okay", "Bad", "Awful"]
    
    var questionIndex : Int = 0
    var name : String = ""
    var finalSelection : String = ""
    
    //REGION: On Start
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
    }
    
    //REGION: Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return answers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return answers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(answers[row])
        finalSelection = answers[row]
    }
    
    //stores user in CoreData
    func storeUser(name n:String,mail e:String) {
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
    
    //REGION: Button Actions
    @IBAction func onNextPressed(_ sender: Any) {
        print("next question")
        
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
            name = nameField.text! //save answer
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
    }
    
    @IBAction func onSubmitPressed(_ sender: Any) {
        //TODO: save name and finalSelection to core data
        print("save data and segue to calendar")
        print("final: \(finalSelection) \nname: \(name)")
        performSegue(withIdentifier: "CalendarSegue", sender: nil)
    }
    
    //for darkmode in settings
    override func viewWillAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        let email:String = user?.email ?? "none"
        
        if UserDefaults.standard.bool(forKey: email + "dark mode") {
            view.backgroundColor = .black
            titleLabel.textColor = .white
            questionText.textColor = .white
            
        } else {
            view.backgroundColor = .white
            titleLabel.textColor = .black
            questionText.textColor = .black
        }
    }
}
