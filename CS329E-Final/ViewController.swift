//cs329e
//katherine was here

import UIKit
import CoreData
import Firebase
import FirebaseAuth //so we can do the Auth.auth().....

class LoginViewController: UIViewController {

    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var userIDField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var confirmPassLabel: UILabel!
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    //private so cant access anywhere else in app but main page
    private enum PageType {
        case login
        case signup
    }
    
    //currentPage is of pagetype, set at default - login
    private var currentPageType: PageType = .login {
        //didSet everytime currentPage changes, everything in block called
        didSet {
            setupView(pageType: currentPageType)
            //print(currentPageType) //testcase to print actual page type
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //FirebaseApp.configure()
        
        //when view first appear, should be type login
        setupView(pageType: .login)
        
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            
            if user != nil {
                print("joe not shmo")
                self.userIDField.text = nil
                self.passwordField.text = nil
                self.confirmPasswordField.text = nil
            }
        }
        
        //TODO: check if user has done questionaire or not. if so, go to main screen
    }
    
    //depending on the page (login or sign up) what elements will we see vs hide
    private func setupView(pageType: PageType) {
        //if pageType is == to .login, then confirmPass is hidden
        confirmPasswordField.isHidden = pageType == .login
        confirmPassLabel.isHidden = pageType == .login
        
        if pageType == .login {
            buttonLabel.setTitle("Sign In", for: .normal)
        } else {
            buttonLabel.setTitle("Sign Up", for: .normal)
        }
    }

    //checks if user is already in CoreData
    private func userExists() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"User")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return (fetchedResults!.count > 0)
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        // print(sender.selectedSegmentIndex) //test case to see if works
        
        //if current page type is 0, its login, otherwise its sign up
        currentPageType = sender.selectedSegmentIndex == 0 ? .login : .signup
    }
    
    @IBAction func didTouch(_ sender: Any) {
        //sign in
        if confirmPassLabel.isHidden {
            guard let email = userIDField.text,
                  let password = passwordField.text,
                  email.count > 0,
                  password.count > 0
            else {
                statusLabel.text = "Missing information"
                return
            }
            
            print("Signing In")
            Auth.auth().signIn(withEmail: email, password: password) {
                user, error in
                if let error = error, user == nil {
                    self.statusLabel.text = "Sign In Failed"
                } else {
                    self.statusLabel.text = "Sign In Successful"
                    if self.userExists() {
                        self.performSegue(withIdentifier: "userExistsCalendarSegue", sender: nil)
                    }
                    else{
                        self.performSegue(withIdentifier: "QuestionSegue", sender: nil)
                    }
                }
            }
        } else {
            //sign up
            
            guard let email = userIDField.text,
                  let password = passwordField.text,
                  let confirmPass = confirmPasswordField.text,
                  email.count > 0,
                  password.count > 0,
                  confirmPass.count > 0
            else {
                return
            }
            if password == confirmPass {
                Auth.auth().createUser(withEmail: email, password: password) {
                    user, error in
                    if error == nil {
                        Auth.auth().signIn(withEmail: email, password: password)
                        self.statusLabel.text = "Sign Up Successful"
                        
                        self.performSegue(withIdentifier: "QuestionSegue", sender: nil)
                    } else {
                        self.statusLabel.text = "Sign Up Failed"
                        return
                    }
                }
            } else {
                statusLabel.text = "Passwords dont match"
            }
        }
    }
    
    //passes email to questionnaire form for storing in user core data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QuestionSegue" {
            let qvc:QuestionaireViewController = segue.destination as! QuestionaireViewController
            qvc.email = userIDField.text!
        }
        else if segue.identifier == "userExistsCalendarSegue" {
            let cvc:CalendarViewController = segue.destination as! CalendarViewController
            cvc.email = userIDField.text!
        }
    }
}

