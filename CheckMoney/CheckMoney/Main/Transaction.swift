//
//  Transaction.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation

struct Transaction: Codable {
    var id: Int
    var is_consumption: Int
    var price: Int
    var detail: String
    var category: Int
    var date: String
    var account_id: Int
}
