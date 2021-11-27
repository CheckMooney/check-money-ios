//
//  TransactionCollection.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/21.
//

import Foundation

class TransactionHandler {
    static func filter(data: [Transaction], categorizing: CategorizingType = .all, year: Int, month: Int) -> [(Int, [Transaction])] {
        var returnValue = [(Int, [Transaction])]()
        
        for d in (1...31).reversed() {
            let aaaa = data.filter { transaction in
                let date = transaction.date.split(separator: "-")
                guard date.count == 3, Int(date[0]) == year, Int(date[1]) == month, let day = date.last, let dayToInt = Int(day) else {
                    return false
                }
                switch categorizing {
                case .all: return d == dayToInt
                case .consumption: return transaction.is_consumption == 1 && d == dayToInt
                case .income: return transaction.is_consumption == 0 && d == dayToInt
                }
            }
            
            if (aaaa.count != 0) {
                returnValue.append((d, aaaa))
            }
        }
        
        return returnValue
    }
}
