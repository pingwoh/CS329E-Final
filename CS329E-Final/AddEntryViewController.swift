//
//  AddEntryViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import CoreData
import Firebase

class AddEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var moods:[String] = ["Fantastic", "Good", "Okay", "Bad", "Awful"]
    var finalMood:String = ""
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //preselect default values for pickers
        finalMood = moods[0]
    }
    
    //for darkmode in settings
    override func viewWillAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        let email:String = user?.email ?? "none"
        
        if UserDefaults.standard.bool(forKey: email + "dark mode") {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }
    
    //mood picker
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
    
    @IBAction func addLog(_ send: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Log", into: context)
        
        entity.setValue(finalMood, forKey: "mood")
        entity.setValue(datePicker.date, forKey: "date")
        
        do{
            try context.save()
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        performSegue(withIdentifier:"addUnwindSegue", sender: self)
    }

}
