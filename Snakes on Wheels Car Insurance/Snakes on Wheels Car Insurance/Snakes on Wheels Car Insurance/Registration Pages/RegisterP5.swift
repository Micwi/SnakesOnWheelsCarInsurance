//
//  RegisterP5.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/4/21.
//

import UIKit

class RegisterP5: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var priorVehicleModelYearTF: UITextField!
    @IBOutlet weak var priorVehicleMakeTF: UITextField!
    @IBOutlet weak var priorVehicleModelTF: UITextField!
    @IBOutlet weak var priorVehicleVIN_NumTF: UITextField!
    @IBOutlet weak var priorVehicleOwnerNamesTF: UITextField!
    @IBOutlet weak var priorVehicleOwnerMailAddressTF: UITextField!
    @IBOutlet weak var priorVehicleOdometerTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        priorVehicleModelYearTF.delegate = self
        priorVehicleOdometerTF.delegate = self
    }
    @IBAction func continueButtonTapped(_ sender: Any) {
        var priorVehicle = PriorVehicleInfo()
        var validFieldCount = 0
        if(!(priorVehicleModelYearTF.text!.count == 0)){
            if(priorVehicleModelYearTF.text!.count == 4){
                priorVehicle.modelYear = priorVehicleModelYearTF.text!
                validFieldCount+=1
            }else{ self.modelYearInvalidAlert()}
        }
        if(!(priorVehicleMakeTF.text!.count == 0)){
            priorVehicle.make = priorVehicleMakeTF.text!
            validFieldCount+=1
        }
        if(!(priorVehicleModelTF.text!.count == 0)){
            priorVehicle.model = priorVehicleModelTF.text!
            validFieldCount+=1
        }
        if(!(priorVehicleVIN_NumTF.text!.count == 0)){
            if(priorVehicleVIN_NumTF.text!.count == 17){
                priorVehicle.vinNumb = priorVehicleVIN_NumTF.text!
                validFieldCount+=1
            }else{ self.vinNumberInvalidAlert()}
        }
        if(!(priorVehicleOwnerNamesTF.text!.count == 0)){
            priorVehicle.OwnersNames = priorVehicleOwnerNamesTF.text!
            validFieldCount+=1
        }
        if(!(priorVehicleOwnerMailAddressTF.text!.count == 0)){
            priorVehicle.ownersMailingAddress = priorVehicleOwnerMailAddressTF.text!
            validFieldCount+=1
        }
        if(!(priorVehicleOdometerTF.text!.count == 0)){
            priorVehicle.odometer = priorVehicleOdometerTF.text!
            validFieldCount+=1
        }
        if(validFieldCount == 7){
            tempPriorCustomerVehicles.append(priorVehicle)
            performSegue(withIdentifier: "continue", sender: self)
            validFieldCount == 0
        } else{self.textFieldsAreBlank()}
    }
    func textFieldsAreBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("Fields are blank",comment:""), message: NSLocalizedString("Please fill in all fields.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func modelYearInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Model year is invalid",comment:""), message: NSLocalizedString("Please input the correct model year of your vehicle following the format: (YYYY)", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func vinNumberInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("VIN number is invalid",comment:""), message: NSLocalizedString("Please input your VIN number for your vehicle following the format: 17 characters (XXXXXXXXXXXXXXXXX)", comment: ""), preferredStyle: .alert)
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
