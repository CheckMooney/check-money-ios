//
//  Transaction.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation

class Transaction: Codable {
    var is_consumption: Bool
    var price: Int
    var detail: String
    var category: Int
    var date: String
    
    init(isConsumption: Bool, price: Int, detail: String, category: Int, date: String) {
        self.is_consumption = isConsumption
        self.price = price
        self.detail = detail
        self.category = category
        self.date = date
    }
}
