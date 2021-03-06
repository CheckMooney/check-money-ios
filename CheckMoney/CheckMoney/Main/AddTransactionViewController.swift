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
    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var transactionType: UISegmentedControl!
    
    @IBOutlet weak var accountPicker: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var explainText: UITextField!
    @IBOutlet weak var categoryPicker: UITextField!
    @IBOutlet weak var subscriptionSwitch: UISwitch!
    
    @IBOutlet weak var warningText: UILabel!
    
    var categoryPickerDelegate: UIPickerViewDelegate? = nil
    var accountPickerDelegate: UIPickerViewDelegate? = nil
    var categoryPickerView = UIPickerView()
    var accountPickerView = UIPickerView()
    
    override func viewDidLoad() {
        let list = ["μμ", "μ§μΆ"]
        transactionType.removeAllSegments()
        for li in list {
            transactionType.insertSegment(withTitle: li, at: transactionType.numberOfSegments, animated: true)
        }
        transactionType.selectedSegmentIndex = isConsumption ? 1 : 0
        categoryView.isHidden = !isConsumption
        subscriptionView.isHidden = !isConsumption
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
        subscriptionView.isHidden = transactionType.selectedSegmentIndex == 0
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
        let button = UIBarButtonItem(title: "λ«κΈ°", style: .plain, target: self, action: #selector(onPickDone))
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
            warningText.text = "κ°κ²©μ μ¬λ°λ₯΄κ² μλ ₯ν΄μ£ΌμΈμ."
            return
        }
        guard let explain = explainText.text, !explain.isEmpty else {
            warningText.isHidden = false
            warningText.text = "μ€λͺμ μλ ₯ν΄μ£ΌμΈμ."
            return
        }
        let type = transactionType.selectedSegmentIndex
        let category = MainHandler.category.firstIndex(of:categoryPicker.text!) ?? -1
        if type == 1 && (categoryPicker.text!.isEmpty || category == -1) {
            warningText.isHidden = false
            warningText.text = "λΆλ₯λ₯Ό μ νν΄μ£ΌμΈμ."
            return
        }
        guard let selectedAccount = MainHandler.accounts.getAccount(title: accountPicker.text!) else {
            warningText.isHidden = false
            warningText.text = "κ³μ’ μμ΄λλ₯Ό κ°μ Έμ€λλ° λ¬Έμ κ° μκ²Όμ΅λλ€."
            return
        }
        
        warningText.isHidden = true
        let dateFommatter = DateFormatter()
        dateFommatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFommatter.string(from: datePicker.date)
        
        if type == 1 && subscriptionSwitch.isOn {
            NetworkHandler.request(method: .POST, endpoint: "/accounts/\(selectedAccount.id)/subscriptions", request: AddSubscriptionRequest(is_consumption: type, price: price, detail: explain, category: category, date: dateStr), callback: handleResponseForAddingTransaction(success:res:))
        } else {
            let transaction = AddTransactionRequest(is_consumption: type, price: price, detail: explain, category: category, date: dateStr, account_id: selectedAccount.id)
            NetworkHandler.request(method: .POST, endpoint: "/transactions", request: transaction, callback: handleResponseForAddingTransaction(success:res:))
        }
    }
    
    private func handleResponseForAddingTransaction(success: Bool, res: AddTransactionResponse?) {
        guard success else {
            return
        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "κ±°λ λ΄μ­ μμ±μ΄ μλ£λμμ΅λλ€.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "νμΈ", style: .default, handler: {_ in
                self.presentingViewController?.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        let rootVC = UIApplication.shared.windows.first!.rootViewController as? UINavigationController
                        (rootVC?.viewControllers.first as? MainViewController)?.updateTransactionData()
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
