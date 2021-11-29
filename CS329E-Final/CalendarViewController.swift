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

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let reuseIdentifier = "MyCell"
    
    var email : String? = nil
    var userEntity : NSManagedObject? = nil
    
    // dynamically displays calendar days based on current month
    var arr: [Int] = Array(1...daysInMonth)
    var items: [String]!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        userEntity = retrieveUser(userID:email!)
        //print("Name: \(userEntity!.value(forKey:"name")!), Email: \(userEntity!.value(forKey:"email")!)")
        
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
        cell.backgroundColor = .gray
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let selectedCell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        
        //selectedCell.backgroundColor = .red
        if selectedCell.backgroundColor == .gray {
            selectedCell.backgroundColor = .red
        }
        else if selectedCell.backgroundColor == .red {
            selectedCell.backgroundColor = .green
        }
        else if selectedCell.backgroundColor == .green {
            selectedCell.backgroundColor = .gray
        }
        
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
    private func retrieveUser(userID e:String) -> NSManagedObject {
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
        
        return fetchedResults![0]
    }
    
    //for darkmode in settings
    override func viewWillAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        let leEmail:String = user?.email ?? "none"
        
        if UserDefaults.standard.bool(forKey: leEmail + "dark mode") {
            view.backgroundColor = .black
            
        } else {
            view.backgroundColor = .white
        }
    }

}
