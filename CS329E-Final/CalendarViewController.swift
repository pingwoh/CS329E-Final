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

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ReloadCollectionViewDelegate {
    
    let reuseIdentifier = "MyCell"
    
    var userEntity : NSManagedObject? = nil
    
    // dynamically displays calendar days based on current month
    var arr: [Int] = Array(1...daysInMonth)
    var items: [String]!
    
    var rg:CGFloat = 0
    var gg:CGFloat = 0
    var bg:CGFloat = 0
    var ag:CGFloat = 0
    var ry:CGFloat = 0
    var gy:CGFloat = 0
    var by:CGFloat = 0
    var ay:CGFloat = 0
    var lime:UIColor? = nil
    var mood_colors:[UIColor] = [.green, .yellow, .orange, .red]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey:"userID")
        userEntity = retrieveUser(userID:email!)
        
        UIColor.green.getRed(&rg, green: &gg, blue: &bg, alpha: &ag)
        UIColor.yellow.getRed(&ry, green: &gy, blue: &by, alpha: &ay)
        lime = UIColor.init(red: (rg+ry)/2, green: (gg+gy)/2, blue: (bg+by)/2, alpha: (ag+ay)/2)
        mood_colors.insert(lime!, at: 1)
        
        // converts array of ints into array of string
        items = arr.map {String($0)}
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CalendarCollectionViewCell
        
        cell.dateLabel.text = items[indexPath.row]
        let mood = retrieveLog(date: indexPath.row+1)
        if mood >= 0 {
            cell.backgroundColor = mood_colors[Int(mood)]
            cell.dateLabel.textColor = .black
        }
        else {
            if UserDefaults.standard.bool(forKey: "dark mode") {
                cell.backgroundColor = UIColor.init(red: 0.11, green: 0.11, blue: 0.118, alpha: 1)
                cell.dateLabel.textColor = .white
            }
            else {
                cell.backgroundColor = .gray
                cell.dateLabel.textColor = .black
            }
        }
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let containerWidth = collectionView.bounds.width
        let cellSize = (containerWidth - 125) / 4
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
    }
    
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
            return fetchedResults![0].value(forKey:"mood") as! Int16
        }
        else {
            return -1
        }
    }
    
    func refreshCalendar() {
        collectionView.reloadData()
    }
    
    //for darkmode in settings
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        
        if UserDefaults.standard.bool(forKey:"dark mode") {
            view.backgroundColor = .black
            collectionView.backgroundColor = .black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController?.navigationBar.barStyle = .black
            
        }
        else {
            view.backgroundColor = .white
            collectionView.backgroundColor = .white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navigationController?.navigationBar.barStyle = .default
        }
    }
    
    //logs user out(removes userdefaults)
    @IBAction func logoutButton(_ send:UIButton) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey:"userID")
        defaults.synchronize()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddSegue" {
            let a_vc:AddEntryViewController = segue.destination as! AddEntryViewController
            a_vc.delegate = self
        }
    }

    //unwind segue for addentryviewcontroller
    @IBAction func addUnwind( _ seg: UIStoryboardSegue) {
    }
}
