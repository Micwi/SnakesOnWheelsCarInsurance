//
//  SubmitProofOfLiability.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/8/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

var liabilityJustSubmitted = false

class SubmitProofOfLiability: UIViewController {
    
    @IBOutlet weak var submitButton: RoundedButton!
    private let database = Firestore.firestore()
    private var storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMainCustomerData()
        getCustomerVehiclesData()
        getCustomerAddressData()
    }
    
    @IBAction func viewProofOfLiabilityButton(_ sender: Any) {
        submitButton.isHidden = false
        documentBeingGenerated = "Liability"
        performSegue(withIdentifier: "ShowDocument", sender: self)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        // Submit the tempRegisterDocuments.liability to the DMV database (use their license_id)
        let userData = UserDefaults().dictionary(forKey: "userData")!
        let nextAvailableNumber = getNextAvailableNumber(licenseID: userData["license_id"] as! String)
        uploadToStorage(licenseID: userData["license_id"] as! String, nextAvailableNumber: nextAvailableNumber)
        createLiabilityDocument(licenseID: userData["license_id"] as! String, nextAvailableNumber: nextAvailableNumber)
    }
    
    static var nextAvailableNumber = 1
    func getNextAvailableNumber(licenseID: String) -> String {
        database.collection("driver").document("driver_\(licenseID)").collection("proof_of_liability_submission").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
                SubmitProofOfLiability.nextAvailableNumber = querySnapshot!.documents.count + 1
            } else {
                SubmitProofOfLiability.nextAvailableNumber = querySnapshot!.documents.count + 1
            }
        }
        print("The next available number is: ", SubmitProofOfLiability.nextAvailableNumber)
        return "\(SubmitProofOfLiability.nextAvailableNumber)"
    }
    
    func uploadToStorage(licenseID: String, nextAvailableNumber: String) {
        let storageRef = storage.reference(forURL: "gs://snakes-on-wheels-car-insurance.appspot.com/")
        let riversRef = storageRef.child("driver_\(licenseID)/liability_submissions/liability_submission_\(nextAvailableNumber).pdf")
        riversRef.putData(tempRegisterDocuments.liability, metadata: nil)
    }
    
    func createLiabilityDocument(licenseID: String, nextAvailableNumber: String) {
        let storageDirectory = "driver_\(licenseID)/liability_submissions/liability_submission_\(nextAvailableNumber).pdf"
        self.database.collection("driver").document("driver_\(licenseID)").collection("proof_of_liability_submission").document("liability_submission_\(nextAvailableNumber)").setData([
            "submission_date": getCurrentDate(),
            "submission_directory": storageDirectory
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                liabilityJustSubmitted = true
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
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
