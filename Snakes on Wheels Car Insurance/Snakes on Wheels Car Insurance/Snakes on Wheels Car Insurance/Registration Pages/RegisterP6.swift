//
//  RegisterP6.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 11/12/21.
//

import UIKit

class RegisterP6: UIViewController {
    
    @IBOutlet weak var acceptButton: RoundedButton!
    @IBOutlet weak var declineButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func viewQuoteButtonTapped(_ sender: Any) {
        acceptButton.isHidden = false; declineButton.isHidden = false
        documentBeingGenerated = "Premium"
        performSegue(withIdentifier: "ViewQuote", sender: self)
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "continue", sender: self)
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        showDeclineAlert()
    }
    
    func showDeclineAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Are you Sure?",comment:""), message: NSLocalizedString("Are you sure that you want to decline our custom offer? Would you like to contact an agent to discuss any details or concerns pertaining to this policy quote?", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Call Agent", comment: ""), style: .default, handler: { (pAlert) in
            if let url = URL(string: "tel://+‭15163250057‬"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        let defaultAction2 = UIAlertAction(title: NSLocalizedString("Decline Offer", comment: ""), style: .default, handler: { (pAlert) in
            self.notRegisteringAlert()
        })
        let defaultAction3 = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (pAlert) in
        })
        alertController.addAction(defaultAction)
        alertController.addAction(defaultAction2)
        alertController.addAction(defaultAction3)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func notRegisteringAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Please Read",comment:""), message: NSLocalizedString("Being that you declined our offer, your account will not be registered. You will have to go through the registration process again if you wish to get another quote in the future. Thank you for considering Snakes on Wheels Car Insurance.", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: { (pAlert) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SignInNav")
            self.present(newViewController, animated: true, completion: nil)
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
