//
//  ShowHistory.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/5/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

var temporaryURL = ""

class PremiumStatements: UITableViewController {
    
    private let database = Firestore.firestore()
    
    var premiumStatements = [PremiumStatement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populate()
    }
    
    func populate() {
        let userData = UserDefaults().dictionary(forKey: "userData")!
        let customerID = userData["customer_id"]!
        database.collection("customer").document("customer_\(customerID)").collection("premium_statements").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { // This loop goes through every document
                    self.getPremiumStatementData(document: document, data: document.data() as NSDictionary)
                }
                print("Premium Statement Count: \(self.premiumStatements.count)")
                self.tableView.reloadData()
            }
        }
    }
    
    func getPremiumStatementData(document: QueryDocumentSnapshot, data: NSDictionary) {
        var premiumStatement = PremiumStatement()
        premiumStatement.dateCreated = data["date_created"] as! String
        premiumStatement.fileDirectory = data["file_directory"] as! String
        premiumStatement.paymentDueDate = data["payment_due_date"] as! String
        premiumStatement.wasPaid = data["was_paid"] as! String
        premiumStatements.insert(premiumStatement, at: 0)
    }
    
    // Set number of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(premiumStatements.count)
    }
    
    // Set values in rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Populating: \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PremiumStatementCell
        cell.createdDateLabel.text = "Created on " + premiumStatements[indexPath.row].dateCreated
        cell.paymentStatusLabel.text = premiumStatements[indexPath.row].wasPaid
        cell.dueDateLabel.text = "Due on " + premiumStatements[indexPath.row].paymentDueDate
        
        if premiumStatements[indexPath.row].wasPaid == "true" {
            cell.paymentStatusLabel.text = "Paid"
            cell.paymentStatusLabel.textColor = UIColor.green
        }
        else if premiumStatements[indexPath.row].wasPaid == "false" {
            cell.paymentStatusLabel.text = "Not Paid"
            cell.paymentStatusLabel.textColor = UIColor.red
        }
        
        return(cell)
    }
    
    // Ran when you tap a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row Tapped: \(indexPath.row)")
        temporaryURL = premiumStatements[indexPath.row].fileDirectory
        performSegue(withIdentifier: "openPDF", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Set height for the cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return(75)
    }
    
}

struct PremiumStatement {
    
    var dateCreated = String()
    var fileDirectory = String()
    var paymentDueDate = String()
    var wasPaid = String()
    
    init() { }
    
    init(dateCreated: String, fileDirectory: String, paymentDueDate: String, wasPaid: String) {
        self.dateCreated = dateCreated
        self.fileDirectory = fileDirectory
        self.paymentDueDate = paymentDueDate
        self.wasPaid = wasPaid
    }
    
}

class PremiumStatementCell: UITableViewCell {
    
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var paymentStatusLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
}
