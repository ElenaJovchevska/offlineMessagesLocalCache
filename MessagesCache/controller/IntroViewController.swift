//
//  IntroViewController.swift
//  MessagesCache
//
//  Created by Elena Jovcevska on 4/28/19.
//  Copyright © 2019 Elena Jovcevska. All rights reserved.
//

import Foundation
import UIKit

class IntroViewController: AbstractViewController {
    @IBOutlet weak var infoTextfield: UITextField!
    let storageAccess = StorageAccess()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextfield.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatIdentifier" {
            let destinationVC = segue.destination as! ChatViewController
            // Since we don't have a backend for the purpose of this tutorial, the ID is handled like this.
            destinationVC.userID = infoTextfield.text ?? ""
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let validCredentials = storageAccess.getCredentials()
        if let text = infoTextfield.text {
            if validCredentials?.contains(text) == true{
                return true
            }
        }
        handleTechnicalError("Wrong username or password")
        return false
    }
}
