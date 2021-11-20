//
//  AccountPickerSetting.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation
import UIKit

class AccountPickerSetting: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    var textview: UITextField? = nil
    let walletList = MainHandler.accounts.getTitleList()
    
    init(picker: inout UITextField) {
        self.textview = picker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MainHandler.accounts.getCount()
    }
    
    // 피커뷰에 보여줄 값 전달
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return walletList[row]
    }
    
    // 피커뷰에서 선택시 호출
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textview?.text = walletList[row]
    }
}
