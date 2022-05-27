//
//  ChangeCardInfo.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/6/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChangeCardInfo: UIViewController {
    
    private let database = Firestore.firestore()
    
    @IBOutlet weak var cardNumberTF: UITextField!
    @IBOutlet weak var nameOnCardTF: UITextField!
    @IBOutlet weak var expirationTF: UITextField!
    @IBOutlet weak var securityCodeTF: UITextField!
    @IBOutlet weak var autoRenewalSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // Run query here to save data (make it idiot proof too though. They have to enter something valid into each text field)
        let userData = UserDefaults().dictionary(forKey: "userData")!
        saveUserPaymentDataInDB(customerID: userData["customer_id"] as! String)
    }
    
    func saveUserPaymentDataInDB(customerID: String) {
        self.database.collection("customer").document("customer_\(customerID)").collection("card_info").document("default_card").setData([
            "card_number": cardNumberTF.text!,
            "name_on_card": nameOnCardTF.text!,
            "expiration": expirationTF.text!,
            "security_code": securityCodeTF.text!,
            "auto_pay_on": "\(autoRenewalSwitch.isOn)"
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!"); self.navigationController?.popViewController(animated: true) }
        }
    }
    
}
