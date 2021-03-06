//
//  AddEntryViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import CoreData
import Firebase

protocol ReloadCollectionViewDelegate {
    func refreshCalendar()
}

class AddEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var moods:[String] = ["Fantastic", "Good", "Okay", "Bad", "Awful"]
    var mood_dict:[String:Int16] = ["Fantastic":0, "Good":1, "Okay":2, "Bad":3, "Awful":4]
    var finalMood:String = ""
    var delegate:ReloadCollectionViewDelegate? = nil
    
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
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey:"dark mode") {
            let background = UIColor.init(red: 0.11, green: 0.11, blue: 0.118, alpha: 1)
            view.backgroundColor = background
            datePicker.backgroundColor = background
            pickerView.backgroundColor = background
            datePicker.setValue(UIColor.white, forKeyPath:"textColor")
            datePicker.setValue(false, forKeyPath: "highlightsToday")
            pickerView.setValue(UIColor.white, forKeyPath:"textColor")
        }
        else {
            view.backgroundColor = .white
            datePicker.backgroundColor = .white
            pickerView.backgroundColor = .white
            datePicker.setValue(UIColor.black, forKeyPath:"textColor")
            datePicker.setValue(false, forKeyPath: "highlightsToday")
            pickerView.setValue(UIColor.black, forKeyPath:"textColor")
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
        
        entity.setValue(mood_dict[finalMood], forKey: "mood")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        entity.setValue(dateFormatter.string(from:datePicker.date), forKey: "date")
        
        do{
            try context.save()
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        self.delegate!.refreshCalendar()
        performSegue(withIdentifier:"addUnwindSegue", sender: self)
    }

}
