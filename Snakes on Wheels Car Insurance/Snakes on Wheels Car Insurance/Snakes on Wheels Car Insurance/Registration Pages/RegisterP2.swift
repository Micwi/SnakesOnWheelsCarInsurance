//
//  RegisterP2.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/4/21.
//

import UIKit

class RegisterP2: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var streetAddressTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var zipCodeTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zipCodeTF.delegate = self
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        var validFieldCount = 0
        if(!(streetAddressTF.text!.count == 0)){
            tempAddressInfo.streetAddress = streetAddressTF.text!
            validFieldCount+=1
        }
        if(!(cityTF.text!.count == 0)){
            tempAddressInfo.city = cityTF.text!
            validFieldCount+=1
        }
        if(!(stateTF.text!.count == 0)){
            tempAddressInfo.state = stateTF.text!
            validFieldCount+=1
        }
        if(!(zipCodeTF.text!.count == 0)){
            if(zipCodeTF.text!.count == 5){
                tempAddressInfo.zipCode = zipCodeTF.text!
                validFieldCount+=1
            }else{ self.zipCodeInvalidAlert()}
        }
        if(validFieldCount == 4){
            print("All fields filled!")
            performSegue(withIdentifier: "continue", sender: self)
            validFieldCount == 0
        }
        else{self.textFieldsAreBlank()}
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var value = (string.rangeOfCharacter(from: NSCharacterSet.letters)) {
            return false
        } else {
            return true
        }
    }
    func zipCodeInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Zip Code is invalid",comment:""), message: NSLocalizedString("Please correct inputted zip code.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func textFieldsAreBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("Fields are blank",comment:""), message: NSLocalizedString("Please fill in all fields.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
