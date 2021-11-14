//
//  SideMenuController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/13.
//

import Foundation
import UIKit
import SideMenu

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var walletListView: UITableView!
    @IBOutlet weak var emailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = UserData.email
        walletListView.delegate = self
        walletListView.dataSource = self
    }
    
    @IBAction func addWalletButtonClicked(_ sender: Any) {
        let alert = UIAlertController.init(title: "지갑 추가하기", message: "지갑의 이름과 설명을 입력해주세요.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "이름"
        }
        alert.addTextField { textField in
            textField.placeholder = "설명"
        }
        
        alert.addAction(UIAlertAction(title: "생성", style: .default, handler: {_ in
            guard let title = alert.textFields?[0].text else {
                self.present(UIAlertController.init(title: nil, message: "지갑 이름을 추가해주세요.", preferredStyle: .alert), animated: true, completion: nil)
                return
            }
            let request = AddAccountRequest(title: title, description: alert.textFields?[1].text ?? "")
            NetworkHandler.post(endpoint: "accounts", request: request) { (success, response: AddAccountResponse?) in
                guard success else {
                    print("fail to add Account")
                    return
                }
                DispatchQueue.main.async {
                    let account = Account(id: response!.id, title: title, description: alert.textFields?[1].text ?? "", createdAt: DateFormatter().string(from: Date()))
                    MainHandler.accounts.addAccount(account)
                    
                    self.walletListView.reloadData()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "로그아웃", message: "정말로 로그아웃 하시겠어요?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            UIApplication.shared.windows.first!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
            UserData.reset()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainHandler.accounts.getCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = walletListView.dequeueReusableCell(withIdentifier: "tableview_cell") else {
            fatalError("not exist cell")
        }
        cell.textLabel?.text = MainHandler.accounts.getAccount(index: indexPath.row)?.title ?? "empty name"
        return cell
    }
}