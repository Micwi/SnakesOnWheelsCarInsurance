//
//  documentPDFViews.swift
//  firebaseTest
//
//  Created by Louie Patrizi Jr. on 12/4/21.
//

import Foundation
import UIKit
import PDFKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

var documentBeingGenerated = ""

class documentPDFViews: UIViewController {
   
    private let database = Firestore.firestore()
    private var storage = Storage.storage()
    
    public var documentData: Data?
    let companyName = "Snakes on Wheels"; let image = UIImage(named: "Snakes on Wheels Logo.png")!
    
    var premiumCost = 0
    
    @IBOutlet weak var pdfView: PDFView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculateScore()
        
        documentData = createFile()
        
        if let data = documentData {
            pdfView.document = PDFDocument(data: data)
            pdfView.autoScales = true
            saveData(data: data)
        }
        
        if liabilityJustSubmitted {
            liabilityJustSubmitted = false
            let userData = UserDefaults().dictionary(forKey: "userData")!
            getNextAvailableNumber(customerID: userData["customer_id"] as! String)
            uploadPolicy(customerID: userData["customer_id"] as! String)
            createPolicyStatement(customerID: userData["customer_id"] as! String)
        }
        
    }
    
    static var nextAvailableNumber = 1
    func getNextAvailableNumber(customerID: String) {
        database.collection("customer").document("customer_\(customerID)").collection("insurance_policy_coverage_statements").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
                documentPDFViews.nextAvailableNumber = querySnapshot!.documents.count + 1
            } else {
                documentPDFViews.nextAvailableNumber = querySnapshot!.documents.count + 1
            }
        }
        MakePayment.nextAvailableNumber += 1
        print("The next available number is: ", documentPDFViews.nextAvailableNumber)
    }
    
    func uploadPolicy(customerID: String) {
        let storageRef = storage.reference(forURL: "gs://snakes-on-wheels-car-insurance.appspot.com/")
        let riversRef = storageRef.child("customer_\(customerID)/insurance_policy_coverage_statements/insurance_policy_coverage_statement_\(documentPDFViews.nextAvailableNumber).pdf")
        riversRef.putData(tempRegisterDocuments.policy, metadata: nil)
    }
    
    func createPolicyStatement(customerID: String) {
        let storageDirectory = "customer_\(customerID)/insurance_policy_coverage_statements/insurance_policy_coverage_statement_\(documentPDFViews.nextAvailableNumber).pdf"
        self.database.collection("customer").document("customer_\(customerID)").collection("insurance_policy_coverage_statements").document("insurance_policy_coverage_statement_\(documentPDFViews.nextAvailableNumber)").setData([
            "date_created": getCurrentDate(),
            "file_directory": storageDirectory
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!") }
        }
    }
    
    func calculateScore() {
        let completeScore = getCustomerAgeScore() + getCustomerVehiclesScore() + documentPDFViews.violationScore
        if completeScore >= 0 && completeScore <= 29 {
            premiumCost = 150
        } else if completeScore >= 30 && completeScore <= 59 {
            premiumCost = 250
        } else if completeScore >= 60 && completeScore <= 89 {
            premiumCost = 375
        } else if completeScore >= 90 {
            premiumCost = 500
        }
    }
    
    func getCustomerAgeScore() -> Int {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        let now = Date()
        let birthday: Date = dayFormat.date(from: tempCustomerInfo.dateOfBirth)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthday, to: now)
        let age = components.year! // The customer's age
        var ageScore = 0
        
        if age >= 18 && age <= 25 {
            ageScore = 25
        } else if age >= 26 && age <= 59 {
            ageScore = 10
        } else if age >= 60 {
            ageScore = 15
        }
                
        return ageScore
    }
    
    func getCustomerVehiclesScore() -> Int {
        var vehiclesScore = 0
        for i in 0..<tempCustomerVehicles.count {
            if tempCustomerVehicles[i].numbOfDoors == "2" { vehiclesScore += 10 }
            if tempCustomerVehicles[i].hasSafetyPackage == "No" { vehiclesScore += 10 }
            if tempCustomerVehicles[i].usage == "Pleasure" { vehiclesScore += 5 }
        }
        return vehiclesScore
    }
    
    static var violationScore = 0
    func getDMVReportsScore() {
        database.collection("driver").document("driver_\(tempCustomerInfo.licenseID)").collection("police_report_and_traffic_record").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    documentPDFViews.violationScore += self.getViolationScore(violation: document.data()["violation"] as! String)
                }
            }
        }
    }
    
    func getViolationScore(violation: String) -> Int {
        switch (violation) {
        case "Speeding Ticket":
            print("Driver got a speeding ticket")
            return 5
        case "Running Red Light":
            print("Driver ran a red light")
            return 10
        case "Reckless Driving":
            print("Driver drove recklessly")
            return 15
        case "DWI":
            print("Driver did DWI")
            return 25
        case "Car Accident":
            print ("Car Accident Previously Occurred")
            return 12
        default:
            print("Driver has no violations")
            return 0
        }
    }
  
    @IBAction func shareButtonTapped(_ sender: Any) {
        let pdfData = documentData
        let vc = UIActivityViewController(activityItems: [pdfData!], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    func createFile() -> Data {
        let pdfMetaData = [kCGPDFContextCreator: "RSL Software", kCGPDFContextAuthor: "Snakes on Wheels Car Insurance", kCGPDFContextTitle: title]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0; let pageHeight = 11 * 72.0 // SPECIFY PAGE WIDTH AND HEIGHT
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight) // APPLY PAGE SIZE & POSITION ON SCREEN
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            selectCorrectDocument(pageRect: pageRect)
            
            // ADDS LOGO TO THE PAGE (needs modification)
            //MARK: ADD Image method call
            addImage(pageRect: pageRect, imageTop: 10, xCoord: 60)
        }
        
        return data
    }
    
    func saveData(data: Data) {
        switch (documentBeingGenerated) {
        case "Premium":
            tempRegisterDocuments.premium = data
            break;
        case "Policy":
            tempRegisterDocuments.policy = data
            break;
        case "Liability":
            tempRegisterDocuments.liability = data
            break;
        default:
            break;
        }
    }
    
    func selectCorrectDocument(pageRect: CGRect) {
        let customerAddress = tempAddressInfo.streetAddress + ", " + tempAddressInfo.city + ", " + tempAddressInfo.state + " " + tempAddressInfo.zipCode
        switch (documentBeingGenerated) {
        case "Premium":
            premiumStatementPDFGeneration(pageRect: pageRect, y: 0, insuranceCompanyName: companyName, policy_num: 1, customerFNs: tempCustomerInfo.fullName, customerAddress: customerAddress, billDate: getCurrentDate(), billDueDate: addMonths(months: 3), totalPremiumPrice: Double(premiumCost), totalAmountAlreadyPaid: 0, installmentFee: 0, otherFees: 0)
            break;
        case "Policy":
            autoInsurancePolicyPDFGeneration(pageRect: pageRect, y: 0, insuranceCompanyName: companyName, policy_num: 1, customerFNs: tempCustomerInfo.fullName, customerAddress: customerAddress, dateEffective: getCurrentDate(), dateExpiration: addMonths(months: 12), totalPrice: "$\(premiumCost)")
            break;
        case "Liability":
            liabilityInsuranceStatementPDFGeneration(pageRect: pageRect, y: 0, insuranceCompanyName: companyName, customerFNs: tempCustomerInfo.fullName, customerAddress: customerAddress, statementDate: getCurrentDate(), customerCellNum: tempCustomerInfo.phoneNumber, customerEmail: tempCustomerInfo.emailAddress, policyNum: 1, policyEffectiveDate: getCurrentDate(), policyExpirationDate: addMonths(months: 12))
            break;
        default:
            break;
        }
    }
    
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
    }
    
    func addMonths(months: Int) -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        var dateComponent = DateComponents(); dateComponent.month = months
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        return dayFormat.string(from: futureDate!)
    }
    
    func addVehicleInfoSection(pageRect: CGRect) {
        //MARK: Vehicle info section - only run when premium statement or policy/coverage (not liability statement)
        var vehicleListYPos = CGFloat(365)
        var numOfVehiclesIterator = 1
        for i in 0..<tempCustomerVehicles.count {
            addBodyText(body: "\(numOfVehiclesIterator) ", pageRect: pageRect, y: vehicleListYPos, x: 30, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
            addBodyText(body:"\(tempCustomerVehicles[i].modelYear) " + "\(tempCustomerVehicles[i].make) " + "\(tempCustomerVehicles[i].model) " + "\(tempCustomerVehicles[i].vinNumb) ", pageRect: pageRect, y: vehicleListYPos, x: 120, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
            vehicleListYPos+=20
            numOfVehiclesIterator+=1
        }
    }
    
    func premiumStatementPDFGeneration(pageRect: CGRect, y: CGFloat, insuranceCompanyName: String, policy_num: Int, customerFNs: String, customerAddress: String, billDate: String, billDueDate: String, totalPremiumPrice: Double, totalAmountAlreadyPaid: Double, installmentFee: Double, otherFees: Double){
        
        addVehicleInfoSection(pageRect: pageRect)
        
        //title and company name on top of page
        let titleBottom = addTitle(title: "Premium Statement", pageRect: pageRect, y: 36, isMainTitle: true, customXCoord: 0, stringFont: UIFont.systemFont(ofSize: 18.0, weight: .bold))
        let companyNameMark = addTitle(title: insuranceCompanyName, pageRect: pageRect, y: 65, isMainTitle: true, customXCoord: 0, stringFont: UIFont.italicSystemFont(ofSize: 18))
        //meant for company logo. Shows where to position it
        //addBodyText(body: "INSERT LOGO", pageRect: pageRect, y: 36, x: titleBottom - 30, stringFont: UIFont.systemFont(ofSize: 16), stringAlignment: .natural)
        
        addBodyText(body: "Snakes On Wheels Insurance", pageRect: pageRect, y: 120, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body: "4 Maple Ave ", pageRect: pageRect, y: 140, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body: "New York, NY 12341", pageRect: pageRect, y: 160, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        //bill date
        addBodyText(body: "Bill Date", pageRect: pageRect, y: 120, x: 500, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .natural)
        addBodyText(body: "\(billDate)", pageRect: pageRect, y: 140, x: 500, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        //bill due date
        addBodyText(body: "Due Date", pageRect: pageRect, y: 160, x: 500, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .natural)
        addBodyText(body: "\(billDueDate)", pageRect: pageRect, y: 180, x: 500, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        //policy num
        addBodyText(body: "Policy Number:", pageRect: pageRect, y: 200, x: 30, stringFont: UIFont.systemFont(ofSize: 16), stringAlignment: .natural)
        addBodyText(body: "\(policy_num)", pageRect: pageRect, y: 200, x: 150, stringFont: UIFont.boldSystemFont(ofSize: 17), stringAlignment: .natural)
        //cust. name
        addBodyText(body: "Customer Full Name: ", pageRect: pageRect, y: 220, x: 30, stringFont: UIFont.systemFont(ofSize: 16), stringAlignment: .natural)
        addBodyText(body: "\(customerFNs)", pageRect: pageRect, y: 220, x: 190, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .natural)
        //cust address
        addBodyText(body: "Customer Address", pageRect: pageRect, y: 240, x: 30, stringFont: UIFont.systemFont(ofSize: 16), stringAlignment: .natural)
        addBodyText(body: "\(customerAddress)", pageRect: pageRect, y: 240, x: 190, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .natural)
        let custAddressYPos = CGFloat(240)
        // vehicle info is at line where this method is called
        addBodyText(body: "Vehicle Information", pageRect: pageRect, y: custAddressYPos+50, x: titleBottom - 30, stringFont: UIFont.boldSystemFont(ofSize: 18), stringAlignment: .natural)
        let vehicleInfoLabelYPos = CGFloat(custAddressYPos+50)
        addBodyText(body: "Year/Make/Model/VIN", pageRect: pageRect, y: vehicleInfoLabelYPos + 40, x: 120, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body: "Veh. #", pageRect: pageRect, y: vehicleInfoLabelYPos + 40, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        
        //cost stuff
        addBodyText(body: "Total Policy Premium: ", pageRect: pageRect, y: 440, x: 325, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .right)
        //total price is = $800. Possibly change
        addBodyText(body: "$\(totalPremiumPrice)0", pageRect: pageRect, y: 440, x: 520, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .right)
        //total payment applied
        addBodyText(body: "Total Payment Applied: ", pageRect: pageRect, y: 460, x: 325, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .right)
        addBodyText(body: "$\(totalAmountAlreadyPaid)0", pageRect: pageRect, y: 460, x: 520, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .right)
        //installment fees
        addBodyText(body: "Installment Fees:", pageRect: pageRect, y: 480, x: 325, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .right)
        addBodyText(body: "$\(installmentFee)0", pageRect: pageRect, y: 480, x: 520, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .right)
        //other fees
        addBodyText(body: "Other Fees:", pageRect: pageRect, y: 500, x: 325, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .right)
        addBodyText(body: "$\(otherFees)0", pageRect: pageRect, y: 500, x: 520, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .right)
        //total balance left
        
        let totalBalanceLeft = totalPremiumPrice - totalAmountAlreadyPaid
        
        addBodyText(body: "Total Remaining Balance:", pageRect: pageRect, y: 520, x: 325, stringFont: UIFont.boldSystemFont(ofSize: 16), stringAlignment: .right)
        addBodyText(body: "$\(totalBalanceLeft)0", pageRect: pageRect, y: 520, x: 520, stringFont: UIFont.boldSystemFont(ofSize: 20), stringAlignment: .right )
            
    }
  
    //MARK: Method for auto insurance policy PDF Generation
    func autoInsurancePolicyPDFGeneration(pageRect: CGRect, y: CGFloat, insuranceCompanyName: String, policy_num: Int, customerFNs: String, customerAddress: String, dateEffective: String, dateExpiration: String, totalPrice: String){
        
        addVehicleInfoSection(pageRect: pageRect)
        
        //MARK: Page title, company name, Price
        
        let titleBottom = addTitle(title: "Auto Insurance Policy", pageRect: pageRect, y: 36, isMainTitle: true, customXCoord: 0, stringFont: UIFont.systemFont(ofSize: 18.0, weight: .bold))
        let companyNameMark = addTitle(title: insuranceCompanyName, pageRect: pageRect, y: 65, isMainTitle: true, customXCoord: 0, stringFont: UIFont.italicSystemFont(ofSize: 18))
        let totalPriceMark = addTitle(title: totalPrice + ".00", pageRect: pageRect, y: 150, isMainTitle: false, customXCoord:
                                        400, stringFont: UIFont.boldSystemFont(ofSize: 30))
        
        addBodyText(body: "Total Policy Premium + Fees", pageRect: pageRect, y: 190, x: 360, stringFont: UIFont.italicSystemFont(ofSize: 18), stringAlignment: .natural)
        //addBodyText(body: "INSERT LOGO", pageRect: pageRect, y: 36, x: titleBottom - 30, stringFont: UIFont.systemFont(ofSize: 16), stringAlignment: .natural)
        
        //MARK: Policy Information
        //the y positions are grabbed for some addbodytext method calls so the pdf can generate the data with the appropriate spacing
        addBodyText(body: "Policy Information", pageRect: pageRect, y: 130, x: titleBottom - 30, stringFont: UIFont.boldSystemFont(ofSize: 18), stringAlignment: .natural)
        
        //Spacing in body field is 2 tabs, y coord increments by 20, x coord is the same for labels, values x coord = 200
        //policy number
        addBodyText(body: "Policy Number:", pageRect: pageRect, y: 170, x: titleBottom - 30, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body: "\(policy_num)", pageRect: pageRect, y: 170, x: 200, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        //date effective
        addBodyText(body: "Date Effective:", pageRect: pageRect, y: 190, x: titleBottom - 30, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body: "\(dateEffective)", pageRect: pageRect, y: 190, x: 200, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        //date expiration
        addBodyText(body: "Date Expiration:", pageRect: pageRect, y: 210, x: titleBottom - 30, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body: "\(dateExpiration)", pageRect: pageRect, y: 210, x: 200, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        
        var yPosforMultipleNames = CGFloat(230)
        addBodyText(body: "Customer Name(s):", pageRect: pageRect, y: 230, x: titleBottom - 30, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        //the y positions are grabbed for some addbodytext method calls so the pdf can generate the data with the appropriate spacing
        addBodyText(body: customerFNs, pageRect: pageRect, y: 230, x: 200, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
            
        addBodyText(body: "Customer Address:", pageRect: pageRect, y: 250, x: titleBottom - 30, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body: "\(customerAddress)", pageRect: pageRect, y: 250, x: 200, stringFont: UIFont.systemFont(ofSize: 15), stringAlignment: .natural)
        let custAddressYPos = CGFloat(250)
        
        //MARK: Vehicle Section
        // vehicle info is at line where this method is called
        addBodyText(body: "Vehicle Information", pageRect: pageRect, y: custAddressYPos+50, x: titleBottom - 30, stringFont: UIFont.boldSystemFont(ofSize: 18), stringAlignment: .natural)
        let vehicleInfoLabelYPos = CGFloat(custAddressYPos+50)
        addBodyText(body: "Year/Make/Model/VIN", pageRect: pageRect, y: vehicleInfoLabelYPos + 40, x: 120, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body: "Veh. #", pageRect: pageRect, y: vehicleInfoLabelYPos + 40, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        
        //MARK: Coverage info section
        addBodyText(body: "Coverage Information", pageRect: pageRect, y: 450, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 18), stringAlignment: .natural)
        
        addBodyText(body: "Coverage", pageRect: pageRect, y: 480, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        var coverageLabelYPos = CGFloat(480)
        let coverageTypes = [String] (arrayLiteral: "Bodily Injury", "Property Damage", "Permissive User Limit of Liability", "Medical Coverage", "Uninsured Motorist Bodily Injury")
        
        for x in 0..<coverageTypes.count{
            addBodyText(body: coverageTypes[x], pageRect: pageRect, y: coverageLabelYPos+20, x: 30, stringFont: UIFont.systemFont(ofSize: 11), stringAlignment: .natural)
            coverageLabelYPos+=20
        }
        
        addBodyText(body: "Limits", pageRect: pageRect, y: 480, x: 220, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        var limitsLabelYPos = CGFloat(480)
        let coverageLimits = [String](arrayLiteral: "$200k per person/$500k per incident", "$100k per incident", "Full", "$4,000 per person", "$250k per person/$500k per incident")
        
        for i in 0 ..< coverageLimits.count{
            addBodyText(body: coverageLimits[i], pageRect: pageRect, y: limitsLabelYPos+20, x: 220, stringFont: UIFont.systemFont(ofSize: 11), stringAlignment: .natural)
            limitsLabelYPos+=20
        }
    }
    
    //MARK: method for liability insurance pdf generation
    func liabilityInsuranceStatementPDFGeneration(pageRect: CGRect, y: CGFloat, insuranceCompanyName: String, customerFNs: String, customerAddress: String, statementDate: String, customerCellNum: String, customerEmail: String, policyNum: Int, policyEffectiveDate: String, policyExpirationDate:String){
        
        //title and company name on top of page
        let titleBottom = addTitle(title: "Certificate of Liability Insurance", pageRect: pageRect, y: 36, isMainTitle: true, customXCoord: 0, stringFont: UIFont.systemFont(ofSize: 18.0, weight: .bold))
        //let companyNameMark = addTitle(title: insuranceCompanyName, pageRect: pageRect, y: 65, isMainTitle: true, customXCoord: 0, stringFont: UIFont.italicSystemFont(ofSize: 18))
        
        //meant for company logo. Shows where to position it
        //addBodyText(body: "INSERT LOGO", pageRect: pageRect, y: 36, x: titleBottom - 30, stringFont: UIFont.systemFont(ofSize: 16), stringAlignment: .natural)
        
        addBodyText(body: "Producer ", pageRect: pageRect, y: 100, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        //insurance broker
        addBodyText(body: "Alan Turing", pageRect: pageRect, y: 130, x: 30, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
        //insurance company information
        addBodyText(body: "Snakes On Wheels Insurance", pageRect: pageRect, y: 150, x: 30, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
        addBodyText(body: "4 Maple Ave ", pageRect: pageRect, y: 165, x: 30, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
        addBodyText(body: "Mountain, FL 12341", pageRect: pageRect, y: 180, x: 30, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
        //statement date
        addBodyText(body: "Date", pageRect: pageRect, y: 100, x: 500, stringFont: UIFont.boldSystemFont(ofSize: 13), stringAlignment: .natural)
        addBodyText(body: "\(statementDate)", pageRect: pageRect, y: 125, x: 490, stringFont: UIFont.systemFont(ofSize: 13), stringAlignment: .natural)
        
        //customer information
        addBodyText(body: "Customer ", pageRect: pageRect, y: 200, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        
        addBodyText(body: "\(customerFNs)", pageRect: pageRect, y: 230, x: 30, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
        addBodyText(body: "\(customerAddress)", pageRect: pageRect, y: 250, x: 30, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
        addBodyText(body: "\(customerCellNum)", pageRect: pageRect, y: 265, x: 30, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
        addBodyText(body: "\(customerEmail)", pageRect: pageRect, y: 280, x: 30, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
        //insurer mark
        addBodyText(body: "Insurer:", pageRect: pageRect, y: 180, x: 380, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body:"\(insuranceCompanyName)", pageRect: pageRect, y: 180, x: 450, stringFont: UIFont.systemFont(ofSize: 14), stringAlignment: .natural)
        
        //MARK: Coverage portion within liability etc
        
        addBodyText(body: "Coverage ", pageRect: pageRect, y: 320, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        
        addBodyText(body: "Automobile Liability", pageRect: pageRect, y: 360, x: 30, stringFont: UIFont.boldSystemFont(ofSize: 13), stringAlignment: .natural)
        
        let autoMobileLiabilityTypes = [String](arrayLiteral: "Any Auto", "All Owned Autos", "Hired Autos", "Scheduled Autos", "Non-Owned Autos", "Umbrella Liability")
        let autoMobileLiabilityTypes_Values = [String] (arrayLiteral: "--", "YES", "--", "--", "--", "YES")
        var autoLiaLabelYPos = CGFloat(360)
        for i in 0..<autoMobileLiabilityTypes.count {
            addBodyText(body: "- \(autoMobileLiabilityTypes[i])", pageRect: pageRect, y: autoLiaLabelYPos+20, x: 35, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
            addBodyText(body: autoMobileLiabilityTypes_Values[i], pageRect: pageRect, y: autoLiaLabelYPos+20, x: 170, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
            autoLiaLabelYPos+=20
        }
        
        //policy mark
        addBodyText(body: "Policy #:", pageRect: pageRect, y: 220, x: 380, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body:"\(policyNum)", pageRect: pageRect, y: 220, x: 450, stringFont: UIFont.systemFont(ofSize: 14), stringAlignment: .natural)
        
        //policy effective and exp date
    
        addBodyText(body: "Policy EFF Date:", pageRect: pageRect, y: 240, x: 380, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body:"\(policyEffectiveDate)", pageRect: pageRect, y: 240, x: 500, stringFont: UIFont.systemFont(ofSize: 14), stringAlignment: .natural)
        addBodyText(body: "Policy EXP Date:", pageRect: pageRect, y: 260, x: 380, stringFont: UIFont.boldSystemFont(ofSize: 15), stringAlignment: .natural)
        addBodyText(body:"\(policyExpirationDate)", pageRect: pageRect, y: 260, x: 500, stringFont: UIFont.systemFont(ofSize: 14), stringAlignment: .natural)
        
        //Limits section
        
        addBodyText(body: "Limits", pageRect: pageRect, y: 360, x: 230, stringFont: UIFont.boldSystemFont(ofSize: 13), stringAlignment: .natural)
        addBodyText(body: "Cost", pageRect: pageRect, y: 360, x: 520, stringFont: UIFont.boldSystemFont(ofSize: 13), stringAlignment: .natural)
        let autoLiabilityLimits = [String](arrayLiteral: "Combined Single Limit (per accident)", "Bodily Injury (per person)", "Bodily Injury (per accident)", "Property Damage (per accident)")
        let autoLiabilityLimitsCosts = [String](arrayLiteral: "$1,000,000", "$250,000", "$500,000", "$150,000")
        
        var autoLiaLimitYPos = CGFloat(360)
        for x in 0..<autoLiabilityLimits.count {
            addBodyText(body: autoLiabilityLimits[x], pageRect: pageRect, y: autoLiaLimitYPos+20, x: 230, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
            addBodyText(body: autoLiabilityLimitsCosts[x], pageRect: pageRect, y: autoLiaLimitYPos+20, x: 510, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
            autoLiaLimitYPos+=20
        }
        
        addBodyText(body: "Authorized Representative Signature", pageRect: pageRect, y: 480, x: 300, stringFont: UIFont.boldSystemFont(ofSize: 14), stringAlignment: .natural)
        
        addBodyText(body: tempCustomerInfo.fullName, pageRect: pageRect, y: 500, x: 300, stringFont: UIFont.systemFont(ofSize: 12), stringAlignment: .natural)
    }
  
    func addTitle(title: String, pageRect: CGRect, y: CGFloat, isMainTitle: Bool, customXCoord: CGFloat, stringFont: UIFont) -> CGFloat {
    let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: stringFont]
    let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
    let titleStringSize = attributedTitle.size()
        var titleStringRect = CGRect()
        //******** Default "y" value in below statement is 36 *****
        if(isMainTitle){
            titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0, y: y, width: titleStringSize.width,
                                         height: titleStringSize.height)
        } else{
            titleStringRect = CGRect(x: customXCoord, y: y, width: titleStringSize.width,
                                         height: titleStringSize.height)
        }
    
    attributedTitle.draw(in: titleStringRect)
    return titleStringRect.origin.y + titleStringRect.size.height
  }

    func addBodyText(body: String, pageRect: CGRect, y: CGFloat, x: CGFloat, stringFont: UIFont, stringAlignment: NSTextAlignment) {
    let textFont = stringFont
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .natural
    paragraphStyle.lineBreakMode = .byWordWrapping
    let textAttributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: textFont]
    let attributedText = NSAttributedString(string: body, attributes: textAttributes)
    let textRect = CGRect(x: x, y: y, width: pageRect.width - 20, height: pageRect.height - y - pageRect.height / 5.0)
    attributedText.draw(in: textRect)
  }
  
  
  
    func addImage(pageRect: CGRect, imageTop: CGFloat, xCoord: CGFloat) {
        let maxHeight = pageRect.height * 0.4
        let maxWidth = pageRect.width * 0.8
        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let imageX = xCoord
        let imageRect = CGRect(x: imageX, y: imageTop + 10, width: 80, height: 80)
        image.draw(in: imageRect)
    }
  
}
