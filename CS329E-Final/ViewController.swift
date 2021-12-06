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
        
        let defaults = UserDefaults.standard
        if (defaults.string(forKey:"userID") != nil && defaults.string(forKey:"userID")!.count > 0) {
            performSegue(withIdentifier: "userExistsCalendarSegue", sender: nil)
        }
        
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
        
        //when we load up the app, it is initially hidden
        confirmPasswordField.isHidden = true
        confirmPassLabel.isHidden = true
        
        //for swipe with login 
        let swipeRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(recogRightSwipe(recognizer:)))
        swipeRecognizerRight.direction = .right
        self.segCtrl.addGestureRecognizer(swipeRecognizerRight)
        let swipeRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(recogLeftSwipe(recognizer:)))
        swipeRecognizerLeft.direction = .left
        self.segCtrl.addGestureRecognizer(swipeRecognizerLeft)
        
        self.view.addGestureRecognizer(swipeRecognizerLeft)
        self.view.addGestureRecognizer(swipeRecognizerRight)
        
        //TODO: check if user has done questionaire or not. if so, go to main screen
        
        segCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkText], for: UIControl.State.normal)
        
        segCtrl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AmericanTypewriter", size: 16)! ], for: UIControl.State.normal)
        
        buttonLabel.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: 16)!
    }
    
    //depending on the page (login or sign up) what elements will we see vs hide
    private func setupView(pageType: PageType) {
        //if pageType is == to .login, then confirmPass is hidden
//        confirmPasswordField.isHidden = pageType == .login
//        confirmPassLabel.isHidden = pageType == .login
        
        if pageType == .login {
            buttonLabel.setTitle("Sign In", for: .normal)
        } else {
            buttonLabel.setTitle("Sign Up", for: .normal)
        }
    }

    //retrieves user from CoreData
    private func userExists(userID e:String) -> Bool {
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
        
        return fetchedResults!.count > 0
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        // print(sender.selectedSegmentIndex) //test case to see if works
        
        //if current page type is 0, its login, otherwise its sign up
        currentPageType = sender.selectedSegmentIndex == 0 ? .login : .signup
        
        if segCtrl.selectedSegmentIndex == 0 {
            currentPageType = .login
            UIView.animate(
                            withDuration: 0.25,
                            delay: 0.0,
                            options: .curveEaseOut,
                            animations: {
                                self.buttonLabel.alpha = 0.0
                                self.confirmPassLabel.alpha = 0.0
                                self.confirmPasswordField.alpha = 0.0
                            },
                            completion: {_ in
                                UIView.animate(
                                    withDuration: 0.25,
                                    delay: 0.0,
                                    options: .curveEaseIn,
                                    animations: {
                                        self.buttonLabel.alpha = 1.0
                                        self.confirmPassLabel.isHidden = true
                                        self.confirmPasswordField.isHidden = true
                                    },
                                    completion: nil
                                )
                            }
                        )

        } else {
            currentPageType = .signup
            UIView.animate(
                            withDuration: 0.25,
                            delay: 0.0,
                            options: .curveEaseOut,
                            animations: {
                                self.buttonLabel.alpha = 0.0
                            },
                            completion: {_ in
                                UIView.animate(
                                    withDuration: 0.25,
                                    delay: 0.0,
                                    options: .curveEaseIn,
                                    animations: {
                                        self.buttonLabel.alpha = 1.0
                                        self.confirmPassLabel.isHidden = false
                                        self.confirmPasswordField.isHidden = false
                                        self.confirmPassLabel.alpha = 1.0
                                        self.confirmPasswordField.alpha = 1.0
                                    },
                                    completion: nil
                                )
                            }
                        )
        }
    }
    
    @IBAction func didTouch(_ sender: Any) {
        
        let user = Auth.auth().currentUser
        let leEmail = user?.email ?? "none"
        
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
                    let defaults = UserDefaults.standard
                    defaults.setValue(self.userIDField.text!, forKey:"userID")
                    if self.userExists(userID:self.userIDField.text!) {
                        self.userIDField.text = ""
                        self.passwordField.text = ""
                        self.statusLabel.text = ""
                        self.performSegue(withIdentifier: "userExistsCalendarSegue", sender: nil)
                    }
                    else{
                        self.userIDField.text = ""
                        self.passwordField.text = ""
                        self.statusLabel.text = ""
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
                        let defaults = UserDefaults.standard
                        defaults.setValue(self.userIDField.text!, forKey:"userID")
                        self.userIDField.text = ""
                        self.passwordField.text = ""
                        self.confirmPasswordField.text = ""
                        self.statusLabel.text = ""
                        self.performSegue(withIdentifier: "QuestionSegue", sender: nil)
                    } else {
                        self.statusLabel.text = "Sign Up Failed"
                        return
                    }
                }
            }
            
            if password != confirmPass {
                statusLabel.text = "Passwords dont match"
            } 
        }
        
        //set user defaults == nil 
        UserDefaults.standard.set(false, forKey: leEmail + "dark mode")
        UserDefaults.standard.set(false, forKey: leEmail + "large font style")
        UserDefaults.standard.set(false, forKey: leEmail + "vibration")
    }
    
    //unwind segue for calendar view controller when logging out
    @IBAction func logoutUnwind( _ seg: UIStoryboardSegue) {
    }
    
    //hides keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func recogRightSwipe(recognizer: UISwipeGestureRecognizer) {
        segCtrl.selectedSegmentIndex = 0
        UIView.animate(
            withDuration: 0.25,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.buttonLabel.alpha = 0.0
                self.confirmPassLabel.alpha = 0.0
                self.confirmPasswordField.alpha = 0.0
            },
            completion: {_ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0.0,
                    options: .curveEaseIn,
                    animations: {
                        self.buttonLabel.alpha = 1.0
                        self.confirmPassLabel.isHidden = true
                        self.confirmPasswordField.isHidden = true
                    },
                    completion: nil
                )
            }
        )
    }

    @IBAction func recogLeftSwipe(recognizer: UISwipeGestureRecognizer) {
        segCtrl.selectedSegmentIndex = 1
        UIView.animate(
            withDuration: 0.25,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.buttonLabel.alpha = 0.0
            },
            completion: {_ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0.0,
                    options: .curveEaseIn,
                    animations: {
                        self.buttonLabel.alpha = 1.0
                        self.confirmPassLabel.alpha = 1.0
                        self.confirmPasswordField.alpha = 1.0
                        self.confirmPassLabel.isHidden = false
                        self.confirmPasswordField.isHidden = false
                    },
                    completion: nil
                )
            }
        )
    }
}

