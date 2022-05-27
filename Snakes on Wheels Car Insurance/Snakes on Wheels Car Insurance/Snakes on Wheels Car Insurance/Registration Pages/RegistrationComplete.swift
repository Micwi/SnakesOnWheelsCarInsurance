//
//  RegistrationComplete.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/4/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class RegistrationComplete: UIViewController {
    
    private let database = Firestore.firestore()
    private var storage = Storage.storage()
    
    @IBOutlet weak var viewPolicyButton: RoundedButton!
    @IBOutlet weak var signInButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func viewPolicyButtonTapped(_ sender: Any) {
        signInButton.isHidden = false
        documentBeingGenerated = "Policy"
        performSegue(withIdentifier: "ViewPolicy", sender: self)
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        signUserIn()
        performSegue(withIdentifier: "signIn", sender: self)
    }
    
    // Sign into the newly created user account
    func signUserIn() {
        FirebaseAuth.Auth.auth().signIn(withEmail: tempCustomerInfo.emailAddress, password: tempCustomerInfo.password) { result, error in guard error == nil else {
                print("An error occured while attempting to sign into the newly registered account...")
                return
            }
            let userData = UserDefaults().dictionary(forKey: "userData")!
            self.uploadPolicy(customerID: userData["customer_id"] as! String)
            self.createPolicyStatement(customerID: userData["customer_id"] as! String)
            
            // Resets all temp data
            tempCustomerInfo = CustomerInfo()
            tempCustomerVehicles = [VehicleInfo]()
            tempAddressInfo = AddressInfo()
            tempRegisterDocuments = Documents()
        }
    }
    
    func uploadPolicy(customerID: String) {
        let storageRef = storage.reference(forURL: "gs://snakes-on-wheels-car-insurance.appspot.com/")
        let riversRef = storageRef.child("customer_\(customerID)/insurance_policy_coverage_statements/insurance_policy_coverage_statement_1.pdf")
        riversRef.putData(tempRegisterDocuments.policy, metadata: nil)
    }
    
    func createPolicyStatement(customerID: String) {
        let storageDirectory = "customer_\(customerID)/insurance_policy_coverage_statements/insurance_policy_coverage_statement_1.pdf"
        self.database.collection("customer").document("customer_\(customerID)").collection("insurance_policy_coverage_statements").document("insurance_policy_coverage_statement_1").setData([
            "date_created": getCurrentDate(),
            "file_directory": storageDirectory
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
    }
    
}
