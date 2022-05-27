//
//  PolicyCoverageStatements.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/5/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import WebKit

class PolicyCoverageStatements: UITableViewController {
    
    private let database = Firestore.firestore()
    private var storage = Storage.storage()
    
    var insurancePolicyCoverageStatements = [InsurancePolicyCoverageStatement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populate()
    }
    
    func populate() {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        let customerID = userData["customer_id"]!
        database.collection("customer").document("customer_\(customerID)").collection("insurance_policy_coverage_statements").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //querySnapshot!.documents.count <- use this when you want to get the number of pdfs in a database document. When you save a document, be sure to start at 1, not 0!
                for document in querySnapshot!.documents { // This loop goes through every document
                    self.getInsurancePolicyCoverageStatementData(document: document, data: document.data() as NSDictionary)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getInsurancePolicyCoverageStatementData(document: QueryDocumentSnapshot, data: NSDictionary) {
        var insurancePolicyCoverageStatement = InsurancePolicyCoverageStatement()
        insurancePolicyCoverageStatement.dateCreated = data["date_created"] as! String
        insurancePolicyCoverageStatement.fileDirectory = data["file_directory"] as! String
        //insurancePolicyCoverageStatements.append(insurancePolicyCoverageStatement)
        insurancePolicyCoverageStatements.insert(insurancePolicyCoverageStatement, at: 0)
    }
    
    // Set number of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(insurancePolicyCoverageStatements.count)
    }
    
    // Set values in rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Populating: \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InsurancePolicyCoverageStatementCell
        cell.policyAndCoverageLabel.text = "Policy and Coverage"
        cell.createdOnLabel.text = "Created on " + insurancePolicyCoverageStatements[indexPath.row].dateCreated
        
        return(cell)
    }
    
    // Ran when you tap a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row Tapped: \(indexPath.row)")
        temporaryURL = insurancePolicyCoverageStatements[indexPath.row].fileDirectory
        performSegue(withIdentifier: "openPDF", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Set height for the cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return(75)
    }
    
}

struct InsurancePolicyCoverageStatement {
    
    var dateCreated = String()
    var fileDirectory = String()
    
    init() { }
    
    init(dateCreated: String, fileDirectory: String) {
        self.dateCreated = dateCreated
        self.fileDirectory = fileDirectory
    }
    
}

class InsurancePolicyCoverageStatementCell: UITableViewCell {
    
    @IBOutlet weak var policyAndCoverageLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    
}
