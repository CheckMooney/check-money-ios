//
//  CategoryPickerSetting.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation
import UIKit

class CategoryPickerSetting: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    var pickerList = [String]()
    var pickerField: UITextField? = nil
    
    init(picker: inout UITextField) {
        self.pickerField = picker
        self.pickerList.append("분류를 선택하세요.")
        pickerList.append(contentsOf: MainHandler.category)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerList.count
    }
    
    // 피커뷰에 보여줄 값 전달
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerList[row]
    }
    
    // 피커뷰에서 선택시 호출
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row == 0) {
            return
        }
        pickerField?.text = pickerList[row]
    }
}
