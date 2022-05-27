//
//  CustomerInfo.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/6/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class CustomerInfoPage: UIViewController {
    
    private let database = Firestore.firestore()
    
    @IBOutlet weak var customerSinceLabel: UILabel!
    @IBOutlet weak var customerNameTF: UITextField!
    @IBOutlet weak var customerDOBTF: UITextField!
    @IBOutlet weak var customerGenderTF: UITextField!
    @IBOutlet weak var customerMaritalStatusTF: UITextField!
    @IBOutlet weak var customerStreetAddressTF: UITextField!
    @IBOutlet weak var customerCityTF: UITextField!
    @IBOutlet weak var customerStateTF: UITextField!
    @IBOutlet weak var customerZipCodeTF: UITextField!
    @IBOutlet weak var cardEndsInTF: UITextField!
    @IBOutlet weak var cardExpiresOnTF: UITextField!
    @IBOutlet weak var nameOnCardTF: UITextField!
    @IBOutlet weak var autoRenewalSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGeneralUserData()
        getUserAddressData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getUserCardData()
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            print("Sign out was successful!")
            UserDefaults().removeObject(forKey: "userData")
            goToScene(identifier: "SignInNav")
        } catch { }
    }
    
    func goToScene(identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func getGeneralUserData() {
        // Don't forget about the "customer since" label!
        let userData = UserDefaults().dictionary(forKey: "userData")!
        let customerSinceDate = userData["customer_since"] as? String
        customerSinceLabel.text = "Customer Since:\n" + customerSinceDate!
        customerNameTF.text = userData["full_name"] as? String
        customerDOBTF.text = userData["date_of_birth"] as? String
        customerGenderTF.text = userData["gender"] as? String
        customerMaritalStatusTF.text = userData["marital_status"] as? String
    }
    
    func getUserAddressData() {
        let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        let docRef = database.collection("customer").document("customer_\(userID)").collection("address_info").document("home_address")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            self.customerStreetAddressTF.text = data["street_address"] as? String
            self.customerCityTF.text = data["city"] as? String
            self.customerStateTF.text = data["state"] as? String
            self.customerZipCodeTF.text = data["zip_code"] as? String
        }
    }
    
    func getUserCardData() {
        let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        let docRef = database.collection("customer").document("customer_\(userID)").collection("card_info").document("default_card")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            let cardNumber = data["card_number"] as? String
            let lastFourDigits: String = String(cardNumber!.suffix(4))
            self.cardEndsInTF.text = "Ends in " + lastFourDigits
            self.cardExpiresOnTF.text = "Expires on " +  (data["expiration"] as? String)!
            self.nameOnCardTF.text = "Name on card: " + (data["name_on_card"] as? String)!
            if (data["auto_pay_on"] as? String)! == "true" {
                self.autoRenewalSwitch.isOn = true
            } else if (data["auto_pay_on"] as? String)! == "false" {
                self.autoRenewalSwitch.isOn = false
            }
        }
    }
    
    @IBAction func autoRenewalSwitch(_ sender: Any) {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        let customerID = userData["customer_id"]!
        var valueToSet = "true"
        
        if autoRenewalSwitch.isOn { valueToSet = "true" } else if !autoRenewalSwitch.isOn { valueToSet = "false" }
        
        self.database.collection("customer").document("customer_\(customerID)").collection("card_info").document("default_card").setData([
            "auto_pay_on": valueToSet,
        ], merge: true) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
}
