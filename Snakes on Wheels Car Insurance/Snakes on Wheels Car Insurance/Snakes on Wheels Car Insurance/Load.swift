//
//  Load.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 11/24/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

var tempCustomerInfo = CustomerInfo()
var tempCustomerVehicles = [VehicleInfo]()
var tempPriorCustomerVehicles = [PriorVehicleInfo]()
var tempAddressInfo = AddressInfo()
var tempRegisterDocuments = Documents()

class Load: UIViewController {
    
    private let database = Firestore.firestore()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if UserDefaults().dictionary(forKey: "userData") == nil {
            // Ran when no user was previously signed in
            self.goToScene(identifier: "SignInNav")
        } else {
            // Ran when a user has previously signed in
            autoSignIn()
        }
    }
    
    func autoSignIn() {
        let userData: Dictionary = UserDefaults().dictionary(forKey: "userData")! // Get data from previous sign in and try to sign in using the email and password from it
        // Attempts to sign the user in
        FirebaseAuth.Auth.auth().signIn(withEmail: userData["email_address"] as! String, password: userData["password"] as! String) { result, error in guard error == nil else {
                print("An error occured while attempting to sign in...")
                self.goToScene(identifier: "SignInNav")
                return
            }
            self.goToScene(identifier: "DashboardNav")
        }
    }
    
    func goToScene(identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.present(newViewController, animated: true, completion: nil)
    }
    
}

struct CustomerInfo {
    
    var emailAddress = String()
    var phoneNumber = String()
    var password = String()
    var licenseID = String()
    var fullName = String()
    var dateOfBirth = String()
    var gender = String()
    var maritalStatus = String()
    
    init() { }
    
    init(emailAddress: String, phoneNumber: String, password: String, licenseID: String, fullName: String, dateOfBirth: String, gender: String, maritalStatus: String) {
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.password = password
        self.licenseID = licenseID
        self.fullName = fullName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.maritalStatus = maritalStatus
    }
    
}

struct VehicleInfo {
    
    var modelYear = String()
    var make = String()
    var model = String()
    var vinNumb = String()
    var numbOfDoors = String()
    var hasSafetyPackage = String()
    var usage = String()
    
    init() { }
    
    init(modelYear: String, make: String, model: String, vinNumb: String, numbOfDoors: String, hasSafetyPackage: String, usage: String) {
        self.modelYear = modelYear
        self.make = make
        self.model = model
        self.vinNumb = vinNumb
        self.numbOfDoors = numbOfDoors
        self.hasSafetyPackage = hasSafetyPackage
        self.usage = usage
    }
    
}

struct PriorVehicleInfo {
    
    var modelYear = String()
    var make = String()
    var model = String()
    var vinNumb = String()
    var OwnersNames = String()
    var odometer = String()
    var ownersMailingAddress = String()
    
    init() { }
    
    init(modelYear: String, make: String, model: String, vinNumb: String, OwnersNames: String, odometer: String, ownersMailingAddress: String) {
        self.modelYear = modelYear
        self.make = make
        self.model = model
        self.vinNumb = vinNumb
        self.OwnersNames = OwnersNames
        self.odometer = odometer
        self.ownersMailingAddress = ownersMailingAddress
    }
    
}

struct AddressInfo {
    
    var streetAddress = String()
    var city = String()
    var state = String()
    var zipCode = String()
    
    init() { }
    
    init(streetAddress: String, city: String, state: String, zipCode: String) {
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zipCode = zipCode
    }
    
}

struct Documents {
    
    var premium = Data()
    var policy = Data()
    var liability = Data()
    
    init() { }
    
    init(premium: Data, policy: Data, liability: Data) {
        self.premium = premium
        self.policy = policy
        self.liability = liability
    }
    
}
