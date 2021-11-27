//
//  AddTransactionViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import UIKit

class AddTransactionViewController: UIViewController {
    var isConsumption: Bool = false
    var accountName: String = ""
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var transactionType: UISegmentedControl!
    
    @IBOutlet weak var accountPicker: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var explainText: UITextField!
    @IBOutlet weak var categoryPicker: UITextField!
    
    @IBOutlet weak var warningText: UILabel!
    
    var categoryPickerDelegate: UIPickerViewDelegate? = nil
    var accountPickerDelegate: UIPickerViewDelegate? = nil
    var categoryPickerView = UIPickerView()
    var accountPickerView = UIPickerView()
    
    override func viewDidLoad() {
        let list = ["수입", "지출"]
        transactionType.removeAllSegments()
        for li in list {
            transactionType.insertSegment(withTitle: li, at: transactionType.numberOfSegments, animated: true)
        }
        transactionType.selectedSegmentIndex = isConsumption ? 1 : 0
        categoryView.isHidden = !isConsumption
        setPickerView()
        accountPicker.text = accountName
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.explainText.resignFirstResponder()
        self.categoryPicker.resignFirstResponder()
        self.accountPicker.resignFirstResponder()
    }
    
    @IBAction func transactionTypeChanged(_ sender: Any) {
        categoryView.isHidden = transactionType.selectedSegmentIndex == 0
    }
    
    func setPickerView() {
        categoryPickerView.tintColor = .clear
        categoryPickerDelegate = CategoryPickerSetting(picker: &categoryPicker)
        categoryPickerView.delegate = categoryPickerDelegate
        categoryPicker.inputView = categoryPickerView
        
        accountPickerView.tintColor = .clear
        accountPickerDelegate = AccountPickerSetting(picker: &accountPicker)
        accountPickerView.delegate = accountPickerDelegate
        accountPicker.inputView = accountPickerView
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onPickDone))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        categoryPicker.inputAccessoryView = toolBar
        accountPicker.inputAccessoryView = toolBar
    }
    
    @objc func onPickDone() {
        categoryPicker.resignFirstResponder()
        accountPicker.resignFirstResponder()
    }
    
    @IBAction func addButton(_ sender: Any) {
        guard let price = Int(priceText.text!) else {
            warningText.isHidden = false
            warningText.text = "가격을 올바르게 입력해주세요."
            return
        }
        guard let explain = explainText.text, !explain.isEmpty else {
            warningText.isHidden = false
            warningText.text = "설명을 입력해주세요."
            return
        }
        let type = transactionType.selectedSegmentIndex
        let category = MainHandler.category.firstIndex(of:categoryPicker.text!) ?? 0
        if type == 1 && (categoryPicker.text!.isEmpty || category == 0) {
            warningText.isHidden = false
            warningText.text = "분류를 선택해주세요."
            return
        }
        guard let accountId = MainHandler.accounts.getAccount(title: accountPicker.text!)?.id else {
            warningText.isHidden = false
            warningText.text = "계좌 아이디를 가져오는데 문제가 생겼습니다."
            return
        }

        warningText.isHidden = true
        let dateFommatter = DateFormatter()
        dateFommatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFommatter.string(from: datePicker.date)
        let transaction = AddTransactionRequest(is_consumption: type, price: price, detail: explain, category: category, date: dateStr, account_id: accountId)
        
        NetworkHandler.request(method: .POST, endpoint: "transactions", request: transaction) { (success, res: AddTransactionResponse?) in
            guard success else {
                return
            }
            let alert = UIAlertController(title: nil, message: "거래 내역 생성이 완료되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: {_ in
                self.presentingViewController?.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        let rootVC = UIApplication.shared.windows.first!.rootViewController as? UINavigationController
                        (rootVC?.viewControllers.first as? MainViewController)?.initViewData()
                    }
                })
            }))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
