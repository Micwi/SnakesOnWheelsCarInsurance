//
//  RegisterP8.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/4/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class RegisterP8: UIViewController {
    
    private let database = Firestore.firestore()
    private var storage = Storage.storage()
    
    @IBOutlet weak var cardNumberTF: UITextField!
    @IBOutlet weak var nameOnCardTF: UITextField!
    @IBOutlet weak var expirationTF: UITextField!
    @IBOutlet weak var securityCodeTF: UITextField!
    @IBOutlet weak var autoRenewalSwitch: UISwitch!
    @IBOutlet weak var payNowButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func payNowButtonTapped(_ sender: Any) {
        // Run code here to register the user's account. **Don't forget to also add their vehicles and card info!
        registerCustomerAccount()
    }
    
    @IBAction func viewPremiumButtonTapped(_ sender: Any) {
        documentBeingGenerated = "Premium"
        payNowButton.isHidden = false
        performSegue(withIdentifier: "ViewPremium", sender: self)
    }
    
    func registerCustomerAccount() {
        // Create user account (in accounts/users section)
        FirebaseAuth.Auth.auth().createUser(withEmail: tempCustomerInfo.emailAddress, password: tempCustomerInfo.password, completion: { result, error in
            guard error == nil else {
                print("An error occured while attempting to register this account...")
                self.alreadyRegisteredWarning()
                return
            }
            // Creates user data in database
            let signedInCustomerID = result!.user.uid // Gets the UID of the customer account that was just created
            self.createUserDataInDB(customerID: signedInCustomerID) // Adds main user data to the database
            self.createUserAddressDataInDB(customerID: signedInCustomerID) // Adds customer's address info to the database
            self.createUserPaymentDataInDB(customerID: signedInCustomerID) // Adds payment (credit/debit) card info to database
            for i in 0..<tempCustomerVehicles.count {
                self.createUserVehicleDataInDB(customerID: signedInCustomerID, vehicleNumber: i)
            }
            for j in 0..<tempPriorCustomerVehicles.count {self.createUserPriorVehicleDataInDB(customerID: signedInCustomerID, vehicleNumber: j)}
            self.uploadPremium(customerID: signedInCustomerID); self.createPremiumStatement(customerID: signedInCustomerID)
            self.performSegue(withIdentifier: "finish", sender: self)
        })
    }
    
    func uploadPremium(customerID: String) {
        let storageRef = storage.reference(forURL: "gs://snakes-on-wheels-car-insurance.appspot.com/")
        let riversRef = storageRef.child("customer_\(customerID)/premium_statements/premium_statement_1.pdf")
        riversRef.putData(tempRegisterDocuments.premium, metadata: nil)
    }
    
    func createUserDataInDB(customerID: String) {
        self.database.collection("customer").document("customer_\(customerID)").setData([
            "customer_id": customerID,
            "email_address": tempCustomerInfo.emailAddress, // Grab the email address they entered at registration
            "phone_number": tempCustomerInfo.phoneNumber,
            "password": tempCustomerInfo.password, // Grab the password they entered at registration
            "full_name": tempCustomerInfo.fullName, // Get the customer's name from the text field(s) during registration
            "date_of_birth": tempCustomerInfo.dateOfBirth, // Get the date of birth from the text field during registration
            "license_id": tempCustomerInfo.licenseID, // Get the license id from the text field during registration
            "customer_since": self.getCurrentDate(),
            "gender": tempCustomerInfo.gender,
            "marital_status": tempCustomerInfo.maritalStatus
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    func createUserAddressDataInDB(customerID: String) {
        self.database.collection("customer").document("customer_\(customerID)").collection("address_info").document("home_address").setData([
            "street_address": tempAddressInfo.streetAddress,
            "city": tempAddressInfo.city,
            "state": tempAddressInfo.state,
            "zip_code": tempAddressInfo.zipCode,
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    func createUserPaymentDataInDB(customerID: String) {
        self.database.collection("customer").document("customer_\(customerID)").collection("card_info").document("default_card").setData([
            "card_number": cardNumberTF.text!,
            "name_on_card": nameOnCardTF.text!,
            "expiration": expirationTF.text!,
            "security_code": securityCodeTF.text!,
            "auto_pay_on": "false"
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    func createUserVehicleDataInDB(customerID: String, vehicleNumber: Int) {
        self.database.collection("customer").document("customer_\(customerID)").collection("vehicles").document("vehicle_\(vehicleNumber)").setData([
            "model_year": tempCustomerVehicles[vehicleNumber].modelYear,
            "make": tempCustomerVehicles[vehicleNumber].make,
            "model": tempCustomerVehicles[vehicleNumber].model,
            "vin_numb": tempCustomerVehicles[vehicleNumber].vinNumb,
            "numb_of_doors": tempCustomerVehicles[vehicleNumber].numbOfDoors,
            "has_safety_package": tempCustomerVehicles[vehicleNumber].hasSafetyPackage,
            "usage": tempCustomerVehicles[vehicleNumber].usage
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    // UPLOAD FILE TO STORAGE, THEN CALL THIS
    func createPremiumStatement(customerID: String) {
        let storageDirectory = "customer_\(customerID)/premium_statements/premium_statement_1.pdf"
        self.database.collection("customer").document("customer_\(customerID)").collection("premium_statements").document("premium_statement_1").setData([
            "date_created": getCurrentDateF2(),
            "file_directory": storageDirectory,
            "payment_due_date": addMonths(months: 3),
            "was_paid": "true"
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    func createUserPriorVehicleDataInDB(customerID: String, vehicleNumber: Int) {
        self.database.collection("customer").document("customer_\(customerID)").collection("prior vehicles").document("vehicle_\(vehicleNumber)").setData([
            "model_year": tempPriorCustomerVehicles[vehicleNumber].modelYear,
            "make": tempPriorCustomerVehicles[vehicleNumber].make,
            "model": tempPriorCustomerVehicles[vehicleNumber].model,
            "vin_numb": tempPriorCustomerVehicles[vehicleNumber].vinNumb,
            "Owner's Name(s)": tempPriorCustomerVehicles[vehicleNumber].OwnersNames,
            "Owner's Mailing Address": tempPriorCustomerVehicles[vehicleNumber].ownersMailingAddress,
            "Odometer": tempPriorCustomerVehicles[vehicleNumber].odometer
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MMMM d, y"
        return dayFormat.string(from: Date())
    }
    
    func getCurrentDateF2() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
    }
    
    func addMonths(months: Int) -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        var dateComponent = DateComponents()
        dateComponent.month = months
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        return dayFormat.string(from: futureDate!)
    }
    
    func alreadyRegisteredWarning() {
        let alertController = UIAlertController(title: NSLocalizedString("Already Registered",comment:""), message: NSLocalizedString("Your account has already been registered. Please return to the Sign In page and try again.", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler:  { (pAlert) in
            self.goToScene(identifier: "SignInPage")
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToScene(identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.present(newViewController, animated: true, completion: nil)
    }
    
}
