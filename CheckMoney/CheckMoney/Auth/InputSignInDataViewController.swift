//
//  InputSignInDataViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/31.
//

import UIKit

class InputSignInDataViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var warningText: UILabel!
    @IBOutlet weak var nameNotInputtedText: UILabel!
    @IBOutlet weak var notMatchPasswordText: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    
    var email: String = ""
    
    override func viewDidLoad() {
        print(email)
    }
    
    @IBAction func nameInputted(_ sender: Any) {
        if let name = nameTextField.text, !name.isEmpty {
            nameNotInputtedText.isHidden = true
        }
        else {
            nameNotInputtedText.isHidden = false
        }
    }
    
    @IBAction func passwordEdited(_ sender: Any) {
        if (checkValidPassword(code: passwordTextField.text ?? "")) {
            warningText.isHidden = true
        }
        else {
            warningText.isHidden = false
        }
    }
    
    @IBAction func passwordConfirmInputted(_ sender: Any) {
        if (passwordTextField.text == passwordConfirmTextField.text) {
            notMatchPasswordText.isHidden = true
        }
        else {
            notMatchPasswordText.isHidden = false
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        let name = nameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        if (name.isEmpty) {
            nameNotInputtedText.isHidden = false
            return
        }
        guard (checkValidPassword(code: password) && password == passwordConfirmTextField.text) else {
            return
        }
        
        setLoadingIndicator(show: true)
        let requestData = AuthJoinRequest(email: email, password: password, name: name)
        NetworkHandler.request(method: .POST, endpoint: "auth/join", request: requestData) { (success, response: AuthJoinResponse?) in
            DispatchQueue.main.sync {
                self.setLoadingIndicator(show: false)
                
                guard success, response != nil else {
                    print("Fail to Join : \(response?.message ?? " ")")
                    return
                }
                let alert = UIAlertController(title: nil, message: "회원가입에 성공했습니다. 로그인을 진행해주세요.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) {(_) in
                    self.navigationController?.popToRootViewController(animated: true)
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func checkValidPassword(code: String) -> Bool {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&.])[A-Za-z\\d@$!%*#?&.]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: code)
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
