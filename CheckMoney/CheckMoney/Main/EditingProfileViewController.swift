//
//  EditingProfileViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/12/18.
//

import UIKit

class EditingProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordSwitch: UISwitch!
    var switchIsOn = false
    @IBOutlet weak var passwardStackView: UIStackView!
    @IBOutlet weak var currentPwdTextField: UITextField!
    @IBOutlet weak var newPwdTextField: UITextField!
    @IBOutlet weak var newPwdSecondTextField: UITextField!
    
    @IBOutlet weak var saveBarItem: UIBarButtonItem!
    @IBOutlet weak var warningTextLabel: UILabel!
    
    var newImage: UIImage? = nil // update 할 이미지
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = UserData.name
        if !UserData.profileImageUrl.isEmpty {
            profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
            profileImageView.layer.borderWidth = 1
            profileImageView.clipsToBounds = true
            profileImageView.kf.setImage(with: URL(string: UserData.profileImageUrl))
        }
    }

    @IBAction func nameTextFieldChanged(_ sender: Any) {
        checkSaveBarItemShouldEnabled()
    }
    
    @IBAction func cancelBarItemClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func checkSaveBarItemShouldEnabled() {
        saveBarItem.isEnabled = newImage != nil || nameTextField.text != UserData.name || passwordSwitch.isOn
    }
    
    @IBAction func saveBarItemClicked(_ sender: Any) {
        guard let _ = nameTextField.text else {
            warningTextLabel.isHidden = false
            warningTextLabel.text = "이름을 입력해주세요."
            return
        }
        if passwordSwitch.isOn {
            guard let _ = currentPwdTextField.text else {
                warningTextLabel.isHidden = false
                warningTextLabel.text = "기존 비밀번호를 입력해주세요."
                return
            }
            if let newPassword = newPwdTextField.text, newPassword.isEmpty {
                warningTextLabel.isHidden = false
                warningTextLabel.text = "새로운 비밀번호를 입력해주세요."
                return
            }
            if newPwdTextField.text != newPwdSecondTextField.text {
                warningTextLabel.isHidden = false
                warningTextLabel.text = "입력한 새로운 비밀번호가 일치하지 않습니다."
                return
            }
        }
        warningTextLabel.isHidden = true
        
        if let _ = newImage {
            uploadImage()
        } else {
            updateProfile()
        }
    }
    
    @IBAction func editProfileImageButtonClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func passwordSwitchClicked(_ sender: Any) {
        passwardStackView.isHidden = !passwordSwitch.isOn
        checkSaveBarItemShouldEnabled()
        switchIsOn = passwordSwitch.isOn
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 원본 이미지가 있을 경우
        }
        
        self.profileImageView.image = newImage // 받아온 이미지를 update
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
        
        checkSaveBarItemShouldEnabled()
    }
    
    func uploadImage() {
        NetworkHandler.uploadFormData(image: newImage!, endpoint: "/users/img") { (success, response: UploadImgResponse?) in
            guard success, let res = response else {
                return
            }
            self.updateProfile(imgUrl: res.url)
            
        }
    }
    
    func updateProfile(imgUrl: String? = nil) {
        let request = PutMyInfoRequest(img_url: imgUrl, name: nameTextField.text, password: switchIsOn ? currentPwdTextField.text : nil, new_password: switchIsOn ? newPwdTextField.text : nil)
        NetworkHandler.request(method: .PUT, endpoint: "/users/my-info", request: request) { (success, response: DefaultResponse?) in
            guard success, let _ = response else {
                return
            }
            if let newName = request.name {
                UserData.name = newName
            }
            if let newImgUrl = imgUrl {
                UserData.profileImageUrl = newImgUrl
            }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
