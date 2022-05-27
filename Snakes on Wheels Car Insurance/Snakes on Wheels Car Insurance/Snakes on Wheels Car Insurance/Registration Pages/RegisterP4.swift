//
//  RegisterP4.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/4/21.
//

import UIKit

class RegisterP4: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAddVehiclesAlert()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    @IBAction func addVehicleButton(_ sender: Any) {
        performSegue(withIdentifier: "vehicleDetails", sender: self)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if(tempCustomerVehicles.count == 0){
            self.noVehiclesAdded()
        } else {
            performSegue(withIdentifier: "continue", sender: self)
        }
    }
    
    func showAddVehiclesAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Add Your Vehicles",comment:""), message: NSLocalizedString("Please add your vehicles here. You can add a vehicle by tapping the '+' button that can be found on the upper right region of your device's screen.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showModifyAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Delete Vehicle",comment:""), message: NSLocalizedString("If you wish to modify this vehicle's details, please delete it and re-add it. You can delete a vehicle by swiping from the right ride of it's cell and then tapping the red 'Delete' button that appears.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func noVehiclesAdded(){
        let alertController = UIAlertController(title: NSLocalizedString("No Vehicles Added",comment:""), message: NSLocalizedString("Please add at least 1 vehicle before proceeding with the rest of the registration", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Set number of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(tempCustomerVehicles.count)
    }
    
    // Set values in rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Populating: \(indexPath.row)")
        var cell = UITableViewCell()
        cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let modelYear = tempCustomerVehicles[indexPath.row].modelYear
        let make = tempCustomerVehicles[indexPath.row].make
        let model = tempCustomerVehicles[indexPath.row].model
        cell.textLabel?.text = "\(modelYear) \(make) \(model)"
        return(cell)
    }
    
    // Ran when you tap a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row Tapped: \(indexPath.row)")
        showModifyAlert()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Set height for the cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return(75)
    }
    
    // Handles Deleting Logs
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        tempCustomerVehicles.remove(at: indexPath.row) // Removes selectd vehicle from the array of vehicles
        tableView.deleteRows(at: [indexPath], with: .automatic) // Delete row in table view for selected vehicle
    }
    
}
