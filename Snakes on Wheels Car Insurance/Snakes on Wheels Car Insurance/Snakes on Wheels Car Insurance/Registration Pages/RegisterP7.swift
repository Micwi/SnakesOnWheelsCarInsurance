//
//  RegisterP7.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/4/21.
//

import UIKit

class RegisterP7: UIViewController {
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        // If both fields have a matching string, the password is saved to the temp array.
        if(validatePassword(password: passwordTF.text!)){
            if (passwordTF.text == confirmPasswordTF.text) {
                tempCustomerInfo.password = passwordTF.text!
                performSegue(withIdentifier: "continue", sender: self)
            }else{
                self.passwordsDontMatchAlert()
            }
        }
        else {
            self.passwordsInvalidAlert()
        }
    }
    
    @IBAction func passwordPeekButtonTouched(_ sender: Any) {
        passwordTF.isSecureTextEntry = false
    }
    
    @IBAction func passwordPeekButtonLetGo(_ sender: Any) {
        passwordTF.isSecureTextEntry = true
    }
    
    @IBAction func confirmPasswordPeekButtonTouched(_ sender: Any) {
        confirmPasswordTF.isSecureTextEntry = false
    }
    
    @IBAction func confirmPasswordPeekButtonLetGo(_ sender: Any) {
        confirmPasswordTF.isSecureTextEntry = true
    }
    
    func passwordsDontMatchAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Passwords don't match.",comment:""), message: NSLocalizedString("Please make sure the passwords match in both fields.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func passwordsInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Password doesn't meet requirements",comment:""), message: NSLocalizedString("Please create a password with a minimum length of 8 characters and it must include at least one letter and one number", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func validate(userEntry: String, regEx: String) -> Bool {
        let regEx = regEx
        let trimmedString = userEntry.trimmingCharacters(in: .whitespaces)
        let validateEntry = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = validateEntry.evaluate(with: trimmedString)
        return isValid
    }
    // Minimum of eight characters including at least 1 letter and 1 number
    func validatePassword(password: String) -> Bool { return validate(userEntry: password, regEx: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$") }
    
}
