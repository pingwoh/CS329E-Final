//
//  CalendarViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import CoreData
import Firebase

// This gets the number of days in current month
let cal = Calendar(identifier: .gregorian)
let monthRange = cal.range(of: .day, in: .month, for: Date())!
let daysInMonth = monthRange.count
// Dynamically finds the name of the current month
let monthInt = Calendar.current.component(.month, from: Date())
let monthStr = Calendar.current.monthSymbols[monthInt-1]
// Dynamically finds the current year
let yearInt = Calendar.current.component(.year, from: Date())


extension UIColor {
    static let lightBackground : UIColor = UIColor(named: "LightBackground")!
    static let darkBackground : UIColor = UIColor(named: "DarkBackground")!
    static let cellBackground : UIColor = UIColor(named: "CellBackground")!
    static let darkCellBackground : UIColor = UIColor(named: "darkCellBackground")!
}

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    //MARK: Variables
    let reuseIdentifier = "MyCell"
    var userEntity : NSManagedObject? = nil
    var arr: [Int] = Array(1...daysInMonth) // dynamically displays calendar days based on current month
    var items: [String]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var greetingLabel: UILabel!
    
    let mood_dict: KeyValuePairs = ["Fantastic":0, "Good":1, "Okay":2, "Bad":3, "Awful":4]
    var finalMood:String = ""
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 4
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var pickDateLabel: UILabel!
    
    
    //MARK: On Start
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey:"userID")
        userEntity = retrieveUser(userID:email!)
        
        
        print("Hello \(userEntity!.value(forKey: "name")!)")
        
        // converts array of ints into array of string
        items = arr.map {String($0)}
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.monthName.text = "\(monthStr) - \(yearInt)"
        
        collectionView.layer.borderWidth = 3.0
        collectionView.layer.cornerRadius = 10.0//if you want corner radius.addtional
        
        let swipeRecogLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(recognizer:)))
        swipeRecogLeft.direction = .left
        self.view.addGestureRecognizer(swipeRecogLeft)
    }
    
    //for darkmode in settings
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        greetingLabel.text = "Hello \(userEntity!.value(forKey:"name")!), how are you feeling today?"
        //so the stuff is specific to each user
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        if UserDefaults.standard.bool(forKey: email + "dark mode") {
            view.backgroundColor = .darkBackground
            self.collectionView.backgroundColor = .darkBackground
            self.monthName.textColor = .lightBackground
            self.greetingLabel.textColor = .lightBackground
            self.pickDateLabel.textColor = .lightBackground
            self.collectionView.layer.borderColor = UIColor.lightBackground.cgColor
        } else {
            view.backgroundColor = .lightBackground
            self.collectionView.backgroundColor = .lightBackground
            self.monthName.textColor = .darkBackground
            self.greetingLabel.textColor = .darkBackground
            self.pickDateLabel.textColor = .darkBackground
            self.collectionView.layer.borderColor = UIColor.darkBackground.cgColor
        }
        
        if UserDefaults.standard.bool(forKey: email + "large font style") {
            monthLabel.font = monthLabel.font.withSize(35)
            self.pickDateLabel.font.withSize(22)
        } else {
            monthLabel.font = monthLabel.font.withSize(25)
            self.pickDateLabel.font.withSize(18)
        }
        
    }
    
    //MARK: Month Label
    @IBOutlet weak var monthName: UILabel!
    
    //MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //so the stuff is specific to each user
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CalendarCollectionViewCell
        
        cell.dateLabel.text = items[indexPath.row]
        
        cell.createDate(day: items[indexPath.row])
        cell.backgroundColor = cell.getMood(d: indexPath.row+1)
        if(cell.mood < 0) {
            cell.dateLabel.textColor = UserDefaults.standard.bool(forKey: email + "dark mode") ? .lightBackground : .darkBackground
        } else {
            cell.dateLabel.textColor = .darkBackground
        }
        
        //print("da mood \(cell.mood)")

        cell.layer.borderColor = UIColor.darkBackground.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: 130)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 130))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        //pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        
        let controller = UIAlertController(
            title: "How are you feeling today?",
            message: "Please select one:",
            preferredStyle: .actionSheet)
        
        controller.setValue(vc, forKey: "contentViewController")
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil )
        controller.addAction(cancelAction)
        
        
        let selectAction = UIAlertAction(
            title: "Select",
            style: .default,
            handler: {(action) in
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                let selected = Array(self.mood_dict)[selectedRow]
                self.finalMood = selected.key
                cell.setMood(selectedMood: selected.value)
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.collectionView.performBatchUpdates({
                            self.collectionView.reloadItems(at: [indexPath])
                        }, completion: nil)
                })
            } )
        controller.addAction(selectAction)
        
        let deleteAction = UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: {(action) in
                cell.deleteMood()
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.collectionView.performBatchUpdates({
                            self.collectionView.reloadItems(at: [indexPath])
                        }, completion: nil)
                })
            })
        controller.addAction(deleteAction)
        
        self.present(controller, animated: true, completion: nil)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let containerWidth = collectionView.bounds.width
        let cellSize = (containerWidth - 125) / 4
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        collectionView.collectionViewLayout = layout
        
    }
    
    //MARK: Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        mood_dict.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 20))
        label.text = Array(mood_dict)[row].key
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }
    
    //MARK: Core Data
    //retrieves user from CoreData based on email
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
    
    //retrieves mood logs from CoreData
    private func retrieveLog(date d:Int) -> Int16 {
        
        let dS = String(format: "%02d", d)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Log")
        var fetchedResults:[NSManagedObject]? = nil
        
        let predicate = NSPredicate(format: "date ENDSWITH %@",dS)
        request.predicate = predicate
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if fetchedResults!.count > 0 {
            return fetchedResults![0].value(forKey: "mood") as! Int16
        }
        else {
            return -1
        }
    }
    
    @IBAction func swipeLeft (recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .left {
            print("Left swipe")
            self.performSegue(withIdentifier: "SettingSegue", sender: nil)
         }
    }
}
