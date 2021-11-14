//
//  CategoryPickerSetting.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation
import UIKit

class CategoryPickerSetting: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let pickerList = MainHandler.category
    var pickerField: UITextField? = nil
    
    init(picker: inout UITextField) {
        self.pickerField = picker
        print("!!!!!!! \(pickerList)")
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
        pickerField?.text = pickerList[row]
    }
}
