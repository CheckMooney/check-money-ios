//
//  AddTransactionViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import UIKit

class AddTransactionViewController: UIViewController {
    var isConsumption: Bool = false
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var transactionType: UISegmentedControl!
    
    @IBOutlet weak var walletNamePicker: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var explainText: UITextField!
    @IBOutlet weak var categoryPicker: UITextField!
    
    var categoryPickerDelegate: UIPickerViewDelegate? = nil
    var walletPickerDelegate: UIPickerViewDelegate? = nil
    
    override func viewDidLoad() {
        let list = ["수입", "지출"]
        transactionType.removeAllSegments()
        for li in list {
            transactionType.insertSegment(withTitle: li, at: transactionType.numberOfSegments, animated: true)
        }
        transactionType.selectedSegmentIndex = isConsumption ? 1 : 0
        categoryView.isHidden = !isConsumption
        setPickerView()
        
    }
    
    @IBAction func transactionTypeChanged(_ sender: Any) {
        categoryView.isHidden = transactionType.selectedSegmentIndex == 0
    }
    
    func setPickerView() {
        let pickerView = UIPickerView()
        pickerView.tintColor = .clear
        categoryPickerDelegate = CategoryPickerSetting(picker: &categoryPicker)
        pickerView.delegate = categoryPickerDelegate
        categoryPicker.inputView = pickerView
        
        let pickerView2 = UIPickerView()
        pickerView2.tintColor = .clear
        walletPickerDelegate = WalletPickerSetting(picker: &walletNamePicker)
        pickerView2.delegate = walletPickerDelegate
        walletNamePicker.inputView = pickerView2
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onPickDone))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        categoryPicker.inputAccessoryView = toolBar
        walletNamePicker.inputAccessoryView = toolBar
    }
    
    @objc func onPickDone() {
        categoryPicker.resignFirstResponder()
        
    }
}
