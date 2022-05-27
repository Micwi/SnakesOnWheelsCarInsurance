//
//  ViewPDF.swift
//  Snakes on Wheels Car Insurance
//
//  Created by Robert Doxey on 12/6/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PDFKit

class ViewPDF: UIViewController {
    
    @IBOutlet weak var PDFView: PDFView!
    public var documentData: Data?
    
    private var storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openPDF()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        temporaryURL = ""
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let pdfData = documentData
        let vc = UIActivityViewController(activityItems: [pdfData!], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    func openPDF() {
        let storageRef = storage.reference(forURL: "gs://snakes-on-wheels-car-insurance.appspot.com/")
        let islandRef = storageRef.child(temporaryURL)
        
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
             print("The following error occurred: ", error)
          } else {
              // Take 'data' and create a PDF out of it.
              self.documentData = data
              self.PDFView.document = PDFDocument(data: data!)
              self.PDFView.autoScales = true
          }
        }
    }
    
}
