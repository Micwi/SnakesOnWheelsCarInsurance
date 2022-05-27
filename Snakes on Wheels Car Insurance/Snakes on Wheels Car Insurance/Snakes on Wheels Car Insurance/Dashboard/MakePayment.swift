//
//  MakePayment.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/8/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

var paymentJustMade = false

class MakePayment: UIViewController {
    
    private let database = Firestore.firestore()
    private var storage = Storage.storage()
    
    @IBOutlet weak var payButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMainCustomerData()
        getCustomerVehiclesData()
        getCustomerAddressData()
    }
    
    @IBAction func viewPremiumButtonTapped(_ sender: Any) {
        payButton.isHidden = false
        documentBeingGenerated = "Premium"
        performSegue(withIdentifier: "ViewPremium", sender: self)
    }
    
    @IBAction func payUsingCard(_ sender: Any) {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        getNextAvailableNumber(customerID: userData["customer_id"] as! String)
        uploadPremium(customerID: userData["customer_id"] as! String)
        createPremiumStatement(customerID: userData["customer_id"] as! String)
        paymentJustMade = true
        navigationController?.popViewController(animated: true)
    }
    
    static var nextAvailableNumber = 1
    func getNextAvailableNumber(customerID: String) {
        database.collection("customer").document("customer_\(customerID)").collection("premium_statements").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
                MakePayment.nextAvailableNumber = querySnapshot!.documents.count
            } else {
                MakePayment.nextAvailableNumber = querySnapshot!.documents.count
            }
        }
        MakePayment.nextAvailableNumber += 1
        print("The next available number is: ", MakePayment.nextAvailableNumber)
    }
    
    func uploadPremium(customerID: String) {
        let storageRef = storage.reference(forURL: "gs://snakes-on-wheels-car-insurance.appspot.com/")
        let riversRef = storageRef.child("customer_\(customerID)/premium_statements/premium_statement_\(MakePayment.nextAvailableNumber).pdf")
        riversRef.putData(tempRegisterDocuments.premium, metadata: nil)
    }
    
    func createPremiumStatement(customerID: String) {
        let storageDirectory = "customer_\(customerID)/premium_statements/premium_statement_\(MakePayment.nextAvailableNumber).pdf"
        self.database.collection("customer").document("customer_\(customerID)").collection("premium_statements").document("premium_statement_\(MakePayment.nextAvailableNumber)").setData([
            "date_created": getCurrentDate(),
            "file_directory": storageDirectory,
            "payment_due_date": addMonths(months: 3),
            "was_paid": "true"
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    func getCurrentDate() -> String {
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
    
    func getMainCustomerData() {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        tempCustomerInfo.fullName = userData["full_name"] as! String
        tempCustomerInfo.phoneNumber = userData["phone_number"] as! String
        tempCustomerInfo.emailAddress = userData["email_address"] as! String
        tempCustomerInfo.dateOfBirth = userData["date_of_birth"] as! String
    }
    
    func getCustomerVehiclesData() {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        database.collection("customer").document("customer_\(userData["customer_id"]!)").collection("vehicles").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
            } else {
                for document in querySnapshot!.documents {
                    // Get each vehicle here using document.data() and setting each vehicles attribute and then adding it to the array!
                    var tempVehicle = VehicleInfo()
                    tempVehicle.make = document.data()["make"] as! String
                    tempVehicle.model = document.data()["model"] as! String
                    tempVehicle.modelYear = document.data()["model_year"] as! String
                    tempVehicle.vinNumb = document.data()["vin_numb"] as! String
                    tempVehicle.numbOfDoors = document.data()["numb_of_doors"] as! String
                    tempVehicle.hasSafetyPackage = document.data()["has_safety_package"] as! String
                    tempVehicle.usage = document.data()["usage"] as! String
                    tempCustomerVehicles.append(tempVehicle)
                }
            }
        }
    }
    
    func getCustomerAddressData() {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        let docRef = database.collection("customer").document("customer_\(userData["customer_id"]!)").collection("address_info").document("home_address")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            tempAddressInfo.streetAddress = data["street_address"] as! String
            tempAddressInfo.city = data["city"] as! String
            tempAddressInfo.state = data["state"] as! String
            tempAddressInfo.zipCode = data["zip_code"] as! String
        }
    }
    
}
