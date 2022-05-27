//
//  ViewController.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 11/11/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignInPage: UIViewController {
    
    private let database = Firestore.firestore()
    
    @IBOutlet weak var emailAddressTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UserDefaults().removeObject(forKey: "userData")
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if(emailAddressTF.text!.count == 0 || passwordTF.text!.count == 0){
            self.textFieldsAreBlank()
        } else { signIn() }
    }
    
    func signIn() {
        FirebaseAuth.Auth.auth().signIn(withEmail: emailAddressTF.text!, password: passwordTF.text!) { result, error in guard error == nil else {
                print("An error occured while attempting to sign in...")
                self.incorrectSignInInfoWarning()
                return
            }
            self.goToScene(identifier: "DashboardNav") // Go to the Dashboard
        }
    }
    
    func incorrectSignInInfoWarning() {
        let alertController = UIAlertController(title: NSLocalizedString("Incorrect Credentials",comment:""), message: NSLocalizedString("Email and/or password is incorrect. Please enter a valid email and password that was previously registered with Snakes on Wheels Car Insurance and try again.", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textFieldsAreBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("Fields are blank",comment:""), message: NSLocalizedString("The email and password fields are blank. Please fill in the fields.", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToScene(identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.present(newViewController, animated: true, completion: nil)
    }
    
}
