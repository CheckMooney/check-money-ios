//
//  ViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/21.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        googleLoginButton.style = .wide
    }
    
    @IBAction func googleLoginClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        GIDSignIn.sharedInstance.signIn(with: appDelegate.googleSignInConfig!, presenting: self, callback: { user, error in
            guard error == nil else {
                return
            }
            
            
        })
    }
}

