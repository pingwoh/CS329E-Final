//
//  CalendarCollectionViewCell.swift
//  CS329E-Final
//
//  Created by Leif Thomas on 11/28/21.
//

import UIKit
import CoreData
import AudioToolbox
import Firebase

class CalendarCollectionViewCell: UICollectionViewCell {
    
    //MARK: Variables
    @IBOutlet weak var dateLabel: UILabel!
    
    let moods : [String] = ["Fantastic", "Good", "Okay", "Bad", "Awful"]
    var date : Date!
    var mood : Int!
    
    //var mood_colors:[UIColor] = [.green, .cyan, .yellow, .orange, .red]
    var mood_colors: [UIColor] = [UIColor(named: "Fantastic")!, UIColor(named: "Good")!, UIColor(named: "Okay")!, UIColor(named: "Bad")!, UIColor(named:"Awful")!]
    
    //MARK: Methods
    func createDate(day: String)
    {
        var newDay = day
        var dateComponents = DateComponents()
        let now = Date()
        
        if(newDay.count < 2)
        {
            newDay = "0" + newDay
        }
        
        dateComponents.day = Int(newDay)
        dateComponents.month = cal.component(.month, from: now)
        dateComponents.year = cal.component(.year, from: now)
        
        date = cal.date(from: dateComponents)  
        
    }
    
    func retrieveMood(d: Int) -> Int16
    {
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
            return fetchedResults![0].value(forKey: "mood") as! Int16 //associate mood w specific email
        }
        else {
            return -1
        }
    }
    
    //MARK: Getters & Setters
    func getDate() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date)
    }
    
    func getMood(d: Int) -> UIColor
    {
        //so the stuff is specific to each user
        let user = Auth.auth().currentUser
        let email = user?.email ?? "none"
        
        let m = retrieveMood(d: d)
        mood = Int(m)
        
        if m >= 0 {
            //print("The mood on \(getDate()) is \(moods[mood])")
            return mood_colors[Int(m)]
        }
        else {
            if UserDefaults.standard.bool(forKey: email + "dark mode") {
                return UIColor.darkCellBackground
            }
            else {
                return .cellBackground
            }
        }
        
    }
    
    func setMood(selectedMood : Int)
    {
        //save locally (so we dont have to access coreData every time we want this value)
        mood = selectedMood
        
        //save in coreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Log", into: context)
        
        deleteMood()
        //setting mood to w specific email
        entity.setValue(selectedMood, forKey: "mood")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        entity.setValue(dateFormatter.string(from: date), forKey: "date")
        
        do{
            try context.save()
        } catch{
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        print("You felt \(moods[mood]) on \(dateFormatter.string(from: date))")
    }
    
    func deleteMood()
    {
        let dS = getDate()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Log")
        fetchRequest.predicate = NSPredicate(format: "date == %@",dS)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest:fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
}
