//
//  Dashboard.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 11/12/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class Dashboard: UIViewController {
    
    private let database = Firestore.firestore()
    
    @IBOutlet weak var welcomeBackLabel: UILabel!
    @IBOutlet weak var paymentDueButton: RoundedButton!
    @IBOutlet weak var proofOfLiabilityDueButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("Refreshing view...")
        checkDueStatus()
        if liabilityJustSubmitted { showLiabilitySubmissionAlert() }
        if paymentJustMade { showPaymentSuccessAlert(); paymentJustMade = false }
    }
    
    func checkDueStatus() {
        if UserDefaults().dictionary(forKey: "userData") != nil {
            self.checkPremiumDueDate()
            self.checkLiabilityInsuranceDueDate()
        }
    }
    
    func getUserData() {
        let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        let docRef = database.collection("customer").document("customer_\(userID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            UserDefaults().setValue(data, forKey: "userData")
            self.getCustomerName()
            
            // Check for due dates here!
            self.checkPremiumDueDate()
            self.checkLiabilityInsuranceDueDate()
        }
    }
    
    func getCustomerName() {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        self.welcomeBackLabel.isHidden = false
        self.welcomeBackLabel.text = "Welcome Back, \(userData["full_name"]!)"
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        if let url = URL(string: "tel://+15163250057‬"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func paymentDueButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "MakePaymentPage", sender: self)
    }
    
    @IBAction func proofOfLiabilityDueButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "SubmitPOLPage", sender: self)
    }
    
    func checkPremiumDueDate() {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        var passedDueDate = false
        database.collection("customer").document("customer_\(userData["customer_id"]!)").collection("premium_statements").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
            } else {
                for document in querySnapshot!.documents {
                    let lastDueDate = dayFormat.date(from: document.data()["payment_due_date"] as! String)!
                    if Date() > lastDueDate { passedDueDate = true } else { passedDueDate = false }
                }
                if passedDueDate {
                    self.paymentDueButton.setTitle("Payment is Due!", for: .normal); self.paymentDueButton.isEnabled = true
                } else {
                    self.paymentDueButton.setTitle("No Payment Due", for: .normal); self.paymentDueButton.isEnabled = false
                }
            }
        }
    }
    
    func checkLiabilityInsuranceDueDate() {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        var passedDueDate = false
        database.collection("driver").document("driver_\(userData["license_id"]!)").collection("proof_of_liability_submission").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
                print("No records found in Database. Falling back to customer_since value")
                // Ran when there are no records of past submissions to the DMV
                let customerSinceString = userData["customer_since"] as! String
                let customerSinceDate = dayFormat.date(from: customerSinceString)!
                if Date() > self.addMonths(months: 12, startDate: customerSinceDate) {
                    print("The current date is 1 year or more past the due date.")
                    self.proofOfLiabilityDueButton.setTitle("Proof of Liability Due!", for: .normal);
                    self.proofOfLiabilityDueButton.isEnabled = true
                } else {
                    self.proofOfLiabilityDueButton.setTitle("Proof of Liability Not Due", for: .normal);
                    self.proofOfLiabilityDueButton.isEnabled = false
                }
            } else {
                for document in querySnapshot!.documents {
                    print("Submission Date: ", document.data()["submission_date"] as! String)
                    let lastSubmissionDate = dayFormat.date(from: document.data()["submission_date"] as! String)!
                    if Date() > self.addMonths(months: 12, startDate: lastSubmissionDate) {
                        passedDueDate = true
                    } else {
                        passedDueDate = false
                    }
                }
                if (querySnapshot!.documents.count == 0) {
                    let customerSinceString = userData["customer_since"] as! String
                    let customerSinceDate = dayFormat.date(from: customerSinceString)!
                    if Date() > self.addMonths(months: 12, startDate: customerSinceDate) {
                        print("The current date is 1 year or more past the due date.")
                        passedDueDate = true
                    } else {
                        passedDueDate = false
                    }
                }
                if passedDueDate {
                    self.proofOfLiabilityDueButton.setTitle("Proof of Liability Due!", for: .normal);
                    self.proofOfLiabilityDueButton.isEnabled = true
                } else {
                    self.proofOfLiabilityDueButton.setTitle("Proof of Liability Not Due", for: .normal);
                    self.proofOfLiabilityDueButton.isEnabled = false
                }
            }
        }
    }
    
    func addMonths(months: Int, startDate: Date) -> Date {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MMMM d, y"
        var dateComponent = DateComponents(); dateComponent.month = months
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: startDate)
        return futureDate!
    }
    
    func goToScene(identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func showLiabilitySubmissionAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Successfully Submitted",comment:""), message: NSLocalizedString("Your proof of liability was successfully submitted to the DMV. Please see your new policy coverage statement.", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (pAlert) in
            documentBeingGenerated = "Policy"
            self.performSegue(withIdentifier: "ShowDocument", sender: self)
        })
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showPaymentSuccessAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Payment Successful",comment:""), message: NSLocalizedString("Thank you for your payment!", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
