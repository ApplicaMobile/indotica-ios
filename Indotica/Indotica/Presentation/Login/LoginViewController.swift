//
//  LoginViewController.swift
//  Indotica
//
//  Created by Nicolas Llanos on 01/03/2024.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let scanViewController = storyboard.instantiateViewController(withIdentifier: "ScanViewController") as? ScanViewController {
            navigationController?.pushViewController(scanViewController, animated: true)
        }
    }
    
}
