//
//  CalendarViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit
import CoreData
import Firebase

class CalendarViewController: UIViewController {
    
    var email : String? = nil
    var userEntity : NSManagedObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        userEntity = retrieveUser(userID:email!)
        //print("Name: \(userEntity!.value(forKey:"name")!), Email: \(userEntity!.value(forKey:"email")!)")
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
