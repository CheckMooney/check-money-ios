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
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        googleLoginButton.style = .wide
    }
    
    @IBAction func googleLoginClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        GIDSignIn.sharedInstance.signIn(with: appDelegate.googleSignInConfig!, presenting: self, callback: { user, error in
            guard error == nil else {
                print (error.debugDescription)
                return
            }
            self.setLoadingIndicator(show: true)
            
            let idToken = user?.authentication.idToken
            print("google Login Result: \(user?.profile?.name ?? " "), token: \(idToken ?? " ")")
            
            NetworkHandler.sendPost(endpoint: "auth/login/google", request: GoogleLoginRequest(id_token: idToken ?? "")) { (isSuccess, response: GoogleLoginResponse?) in
                guard isSuccess == true else {
                    DispatchQueue.main.sync {
                        self.setLoadingIndicator(show: false)
                    }
                    return
                }
                print("로그인 성공쓰")
                // TODO: Response 내 토큰 값 저장하고 메인 화면으로 이동시켜야 함
            }
        })
    }
    
    func setLoadingIndicator(show: Bool) {
        if show {
            self.loadingView.isHidden = false
            self.view.bringSubviewToFront(loadingView)
        }
        else {
            self.loadingView.isHidden = true
        }
    }
}

