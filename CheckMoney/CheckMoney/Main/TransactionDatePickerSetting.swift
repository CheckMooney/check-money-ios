//
//  DatePickerSetting.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/21.
//

import UIKit

class TransactionDatePickerSetting: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let yearList = Array<Int>(2020...Calendar.current.component(.year, from: Date()))
    let monthList = Array<Int>(1...12)
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return yearList.count
        default:
            return monthList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(yearList[row])년"
        default:
            return "\(monthList[row])월"
        }
    }
}
