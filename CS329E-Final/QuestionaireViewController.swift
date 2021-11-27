//
//  QuestionaireViewController.swift
//  CS329E-Final
//
//  Created by Edgar Byers on 11/27/21.
//

import UIKit

class QuestionaireViewController: UIViewController {
    //TODO: check if user has already done questionaire, if so, go to calendar
    
    @IBOutlet weak var questionNumber: UILabel!
    @IBOutlet weak var questionText: UILabel!
    
    override func viewDidLoad() {
        
    }
    
    //TODO: save answers, and when finished segue to calendar
    //can potentially add another button to cycle through questions easier
    
    @IBAction func onSubmitPressed(_ sender: Any) {
        performSegue(withIdentifier: "CalendarSegue", sender: nil)
    }
}
