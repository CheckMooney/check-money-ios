//
//  Account.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation

struct Account: Codable, Hashable {
    var id: Int
    var title: String
    var description: String
    var createdAt: String
}
