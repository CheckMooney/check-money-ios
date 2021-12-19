//
//  SignUpViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/29.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var warningText: UILabel!
    @IBOutlet weak var verifyingCodeView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var wrongNumText: UILabel!
    
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInButtonClicked(_ sender: Any) {
        if !checkValidEmail(address: emailTextField.text ?? "") {
            warningText.isHidden = false
        }
        else {
            warningText.isHidden = true
            loadingView.isHidden = false
            
            let requestData = AuthEmailRequest(email: emailTextField.text!)
            NetworkHandler.request(method: .POST, endpoint: "/auth/request/email", request: requestData) { (success, response: AuthEmailResponse?) in
                DispatchQueue.main.sync {
                    print("Callback:: \(success), \(String(describing: response))")
                    self.loadingView.isHidden = true
                    if let result = response?.result, result == true {
                        print("성공")
                        self.email = self.emailTextField.text!
                        
                        let alert = UIAlertController(title: nil, message: "인증번호가 전송되었습니다.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.verifyingCodeView.isHidden = false
                    }
                    else {
                        print("실패")
                        let respStr = ResponseCode(rawValue: response?.code ?? 0)?.toString()
                        let alert = UIAlertController(title: nil, message: "인증번호 전송에 실패하였습니다.(\(respStr!))", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        if let code = codeTextField.text, checkValidCode(code) {
            wrongNumText.isHidden = true
            let requestData = AuthConfirmCodeRequest(email: email, auth_num: code)
            
            NetworkHandler.request(method: .POST, endpoint: "/auth/confirm", request: requestData, callback: {(success, response: AuthConfirmCodeResponse?) in
                DispatchQueue.main.sync {
                    self.loadingView.isHidden = true
                    
                    if let result = response?.result, result == true {
                        let secondVC = self.storyboard?.instantiateViewController(identifier: "signinDataVC") as? InputSignInDataViewController
                        secondVC?.email = self.email
                        self.navigationController?.pushViewController(secondVC!, animated: true)
                    }
                    else {
                        self.wrongNumText.text = ResponseCode(rawValue: response?.code ?? 0)?.toString()
                        self.wrongNumText.isHidden = false
                    }
                }
            })
        }
        else {
            wrongNumText.isHidden = false
        }
    }
    
    func checkValidEmail(address: String) -> Bool {
        let regex = "^([\\w\\.\\_\\-])*[a-zA-Z0-9]+([\\w\\.\\_\\-])*([a-zA-Z0-9])+([\\w\\.\\_\\-])+@([a-zA-Z0-9]+\\.)+[a-zA-Z0-9]{2,8}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: address)
    }
    
    func checkValidCode(_ code: String) -> Bool {
        let regex = "^[0-9]{6}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: code)
    }
}
