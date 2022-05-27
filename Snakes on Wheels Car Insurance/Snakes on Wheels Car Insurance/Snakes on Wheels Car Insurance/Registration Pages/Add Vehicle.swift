//
//  Add Vehicle.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/5/21.
//

import UIKit

class AddVehicle: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var modelYearTF: UITextField!
    @IBOutlet weak var makeTF: UITextField!
    @IBOutlet weak var modelTF: UITextField!
    @IBOutlet weak var vinNumberTF: UITextField!
    @IBOutlet weak var numberOfDoorsTF: UITextField!
    @IBOutlet weak var safetyPackageSC: UISegmentedControl!
    @IBOutlet weak var usageSC: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelYearTF.delegate = self
    }
    
    @IBAction func addVehicleButtonTapped(_ sender: Any) {
        var vehicle = VehicleInfo()
        var validFieldCount = 0
        if(!(modelYearTF.text!.count == 0)){
            if(modelYearTF.text!.count == 4){
                vehicle.modelYear = modelYearTF.text!
                validFieldCount+=1
            }else{ self.modelYearInvalidAlert()}
        }
        if(!(makeTF.text!.count == 0)){
            vehicle.make = makeTF.text!
            validFieldCount+=1
        }
        if(!(modelTF.text!.count == 0)){
            vehicle.model = modelTF.text!
            validFieldCount+=1
        }
        if(!(vinNumberTF.text!.count == 0)){
            if(vinNumberTF.text!.count == 17){
                vehicle.vinNumb = vinNumberTF.text!
                validFieldCount+=1
            }else{ self.vinNumberInvalidAlert()}
        }
        if(!(numberOfDoorsTF.text!.count == 0)){
            vehicle.numbOfDoors = numberOfDoorsTF.text!
            validFieldCount+=1
        }
        vehicle.hasSafetyPackage = "\(safetyPackageSC.titleForSegment(at: safetyPackageSC.selectedSegmentIndex)!)"
        vehicle.usage = "\(usageSC.titleForSegment(at: usageSC.selectedSegmentIndex)!)"
        if(validFieldCount == 5){
            tempCustomerVehicles.append(vehicle)
            navigationController?.popViewController(animated: true)
            
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
