//
//  NewPasswordViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/12/25.
//

import UIKit

class NewPasswordViewController: UIViewController {
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var newPwdWarningLabel: UILabel!
    @IBOutlet weak var confirmPwdWarningLabel: UILabel!
    
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func newPasswordInputted(_ sender: Any) {
        if checkValidPassword(code: newPasswordTextField.text ?? "") {
            newPwdWarningLabel.isHidden = true
        } else {
            newPwdWarningLabel.isHidden = false
        }
    }
    
    @IBAction func confirmPasswordInputted(_ sender: Any) {
        if (confirmPasswordTextField.text == newPasswordTextField.text) {
            confirmPwdWarningLabel.isHidden = true
            if checkValidPassword(code: newPasswordTextField.text ?? "") {
                newPwdWarningLabel.isHidden = true
            } else {
                newPwdWarningLabel.isHidden = false
            }
        } else {
            confirmPwdWarningLabel.isHidden = false
        }
    }
    
    @IBAction func requestButtonClicked(_ sender: Any) {
        guard let newPassword = newPasswordTextField.text, checkValidPassword(code: newPassword) else {
            newPwdWarningLabel.isHidden = false
            return
        }
        guard confirmPasswordTextField.text == newPasswordTextField.text else {
            confirmPwdWarningLabel.isHidden = false
            return
        }
        newPwdWarningLabel.isHidden = true
        confirmPwdWarningLabel.isHidden = true
        NetworkHandler.request(method: .POST, endpoint: "/auth/find-pwd", request: FindPasswordRequest(email: self.email, newPassword: newPassword)) { (success, response: DefaultResponse?) in
            DispatchQueue.main.sync {
                guard success, response != nil else {
                    print("Fail to Join : \(response?.message ?? " ")")
                    return
                }
                let alert = UIAlertController(title: nil, message: "비밀번호 변경에 성공했습니다.", preferredStyle: UIAlertController.Style.alert)
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
}
