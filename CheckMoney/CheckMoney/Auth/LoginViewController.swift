//
//  ViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/21.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var loadingView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("loginViewController load")
        googleLoginButton.style = .wide
    }
    
    @IBAction func emailLoginClicked(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        guard !email.isEmpty, !password.isEmpty else {
            let alert = UIAlertController(title: "로그인 실패", message: "로그인 정보를 입력해주세요.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let emailLoginRequest = EmailLoginRequest(email: email, password: password)
        NetworkHandler.request(method: .POST, endpoint: "auth/login/email", request: emailLoginRequest) { (isSuccess, response: LoginResponse?) in
            guard isSuccess else {
                if response == nil {
                    return
                }
                print("login fail: \(response!.code), \(response!.message)")
                return
            }
            DispatchQueue.main.async {
                self.moveToMainView(response: response!, email: self.emailTextField.text!)
            }
        }
    }
    
    @IBAction func googleLoginClicked(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(with: appDelegate.googleSignInConfig!, presenting: self, callback: { user, error in
            guard error == nil else {
                print (error.debugDescription)
                return
            }
            self.setLoadingIndicator(show: true)
            
            let idToken = user?.authentication.idToken
            print("google Login Result: \(user?.profile?.name ?? " "), token: \(idToken ?? " ")")
            
            NetworkHandler.request(method: .POST, endpoint: "auth/login/google", request: GoogleLoginRequest(id_token: idToken ?? "")) { (isSuccess, response: LoginResponse?) in
                DispatchQueue.main.async {
                    guard isSuccess == true else {
                        self.setLoadingIndicator(show: false)
                        return
                    }
                    print("로그인 성공쓰")
                    self.moveToMainView(response: response!, email: user?.profile?.email ?? "")
                }
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
    
    func moveToMainView(response: LoginResponse, email: String) {
        UserData.accessToken = response.access_token
        UserData.refreshToken = response.refresh_token
        UserData.email = email
        UserData.name = response.name
        
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC")
            let naviController = UINavigationController(rootViewController: vc)
            naviController.isNavigationBarHidden = true
            UIApplication.shared.windows.first!.rootViewController = naviController
        }
    }
}

