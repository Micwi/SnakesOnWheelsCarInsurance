//
//  RegisterP1.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/4/21.
//

import UIKit

class RegisterP1: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var dateOfBirthTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var maritalStatusTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var emailAddressTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberTF.delegate = self
        dateOfBirthTF.delegate = self
    }
    
    @IBAction func continueButton(_ sender: Any) {
        var validFieldCount = 0
        if(!(fullNameTF.text!.count == 0)) {
            tempCustomerInfo.fullName = fullNameTF.text!
            validFieldCount+=1
        }
        if(!(dateOfBirthTF.text!.count == 0)){
            if(dateOfBirthTF.text!.count == 10){
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "MM/DD/YYYY"
                let date = dateFormatter.date(from: (dateOfBirthTF.text!))
                if(validateDateOfBirth(dateOfBirth: dateOfBirthTF.text!)){
                    if((validate_DateOfBirth(dateOfBirth: date!) >= 18) && (validate_DateOfBirth(dateOfBirth: date!) <= 100)){
                        print("DOB Valid!")
                        tempCustomerInfo.dateOfBirth = dateOfBirthTF.text!
                        validFieldCount+=1
                    }else{self.ageInvalidAlert()}
                }else{
                    print("HERE")
                    self.dateOfBirthTFInvalidAlert()
                }
            }else{
                self.dateOfBirthTFInvalidAlert()
            }
            
        }
        if(!(genderTF.text!.count == 0)){
            tempCustomerInfo.gender = genderTF.text!
            validFieldCount+=1
        }
        if(!(maritalStatusTF.text!.count == 0)){
            tempCustomerInfo.maritalStatus = maritalStatusTF.text!
            validFieldCount+=1
        }
        if(!(phoneNumberTF.text!.count == 0)){
            if(phoneNumberTF.text!.count == 12){
                if(validatePhoneNumber(phoneNumber: phoneNumberTF.text!)){
                    tempCustomerInfo.phoneNumber = phoneNumberTF.text!
                    validFieldCount+=1
                }else{ self.phoneNumberInvalidAlert()}
            
            }else{ self.phoneNumberInvalidAlert()}
        }
        if(!(emailAddressTF.text!.count == 0)) {
            if(validateEmailAddress(emailAddress: emailAddressTF.text!)){
                tempCustomerInfo.emailAddress = emailAddressTF.text!
                validFieldCount+=1
            }else{
                self.emailAddressInvalidAlert()
            }
        }
        if(validFieldCount == 6){
            print("All fields filled!")
            performSegue(withIdentifier: "continue", sender: self)
        }else{
            self.textFieldsAreBlank()
        }
    }
    func validate(userEntry: String, regEx: String) -> Bool {
        let regEx = regEx
        let trimmedString = userEntry.trimmingCharacters(in: .whitespaces)
        let validateEntry = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = validateEntry.evaluate(with: trimmedString)
        return isValid
    }
    func validatePhoneNumber(phoneNumber: String) -> Bool {
        return validate(userEntry: phoneNumber, regEx: "^?\\d{3}[ -]?\\d{3}[ -]?\\d{4}$")
    }
    //checks year inputted and returns the age of registering user. Then in if statement above, it checks if user's age is within the appropriate range
    func validate_DateOfBirth(dateOfBirth: Date) -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: currentDate)
        let currentAge = ageComponents.year!
        print("Current Age: ", currentAge)
        return currentAge
    }
    //Checks if inputted month and date are valid
    func validateDateOfBirth(dateOfBirth: String) -> Bool {
        return validate(userEntry: dateOfBirth, regEx: "^(0[1-9]|1[012])[-/.](0[1-9]|[12][0-9]|3[01])[-/.](19|20)\\d\\d$")
    }
    func validateEmailAddress(emailAddress: String) -> Bool { return validate(userEntry: emailAddress, regEx: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") }
    func emailAddressInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Email Address doesn't meet requirements.",comment:""), message: NSLocalizedString("Please provide a correctly formatted email address.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func ageInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Date of birth is invalid",comment:""), message: NSLocalizedString("The inputted year is not valid for this app.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func phoneNumberInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Phone number is invalid",comment:""), message: NSLocalizedString("The inputted phone number does not follow the pattern xxx-xxx-xxxx.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func dateOfBirthTFInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Date of birth is invalid",comment:""), message: NSLocalizedString("Please fill the field with a correctly formatted date of birth (MM/DD/YYYY).", comment: ""), preferredStyle: .alert)
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var value = (string.rangeOfCharacter(from: NSCharacterSet.letters)) {
            return false
        } else {
            return true
        }
    }
    
}
