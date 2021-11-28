//
//  QuestionaireViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit

class QuestionaireViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //REGION: variables
    @IBOutlet weak var questionNumber: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var questions : [String] = ["What is your name?", "How are you feeling today?"]
    var answers : [String] = ["Good", "Neutral", "Bad"]
    
    var questionIndex : Int = 0
    var name : String!
    var finalSelection : String!
    
    //REGION: On Start
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.navigationItem.leftBarButtonItem = nil
        submitButton.isHidden = true
        nameField.isHidden = true
        pickerView.isHidden = true
        
        titleLabel.text = "Hello there! Welcome to the app, let's start by answering a few questions."
        questionText.text = ""
        questionNumber.text = ""
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
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        finalSelection = answers[row]
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
            nameField.isHidden = true
            name = nameField.text! //save answer
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
        performSegue(withIdentifier: "CalendarSegue", sender: nil)
    }
}
