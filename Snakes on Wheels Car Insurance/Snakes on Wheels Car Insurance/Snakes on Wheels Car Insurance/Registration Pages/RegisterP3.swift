//
//  RegisterP3.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/4/21.
//

import UIKit

class RegisterP3: UIViewController {
    
    @IBOutlet weak var SSN_TF: UITextField!
    @IBOutlet weak var licenseIDTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        var validFieldCount = 0
        if(!(licenseIDTF.text!.count == 0)){
            if(licenseIDTF.text!.count == 9){
                    tempCustomerInfo.licenseID = licenseIDTF.text!
                    validFieldCount+=1
            }else{ self.licenseID_InvalidAlert()}
        }
        if(!(SSN_TF.text!.count == 0)){
            if(SSN_TF.text!.count == 9){
                    validFieldCount+=1
            } else{ self.SSN_InvalidAlert()}
        }
        if(validFieldCount == 2){
            print("All fields filled!")
            performSegue(withIdentifier: "continue", sender: self)
            validFieldCount == 0
        }
        else {
            self.textFieldsAreBlank()
        }
    }
    
    func SSN_InvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("SSN is invalid",comment:""), message: NSLocalizedString("Please make sure inputted value for SSN is correct with the correct format (xxx-xx-xxxx)", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func licenseID_InvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("License ID is invalid",comment:""), message: NSLocalizedString("Please make sure inputted value for the license ID is correct with the correct format (xxx-xxx-xxx)", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var value = (string.rangeOfCharacter(from: NSCharacterSet.letters)) {
            return false
        } else {
            return true
        }
    }
    func textFieldsAreBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("Fields are blank",comment:""), message: NSLocalizedString("Please fill in all fields.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func SSN_EyeButtonTouched(_ sender: Any) {
        SSN_TF.isSecureTextEntry = false
    }
    
    @IBAction func SSN_EyeButtonLetGo(_ sender: Any) {
        SSN_TF.isSecureTextEntry = true
    }
    
    @IBAction func licenseID_EyeButtonTouched(_ sender: Any) {
        licenseIDTF.isSecureTextEntry = false
    }
    
    @IBAction func licenseID_EyeButtonLetGo(_ sender: Any) {
        licenseIDTF.isSecureTextEntry = true
    }
    
}
