//
//  TransactionCollection.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/21.
//

import Foundation

class TransactionHandler {
    static var activeAccount: Account? = nil
    
    static func getTransactionData(account_id: Int, year: Int = 0, month: Int = 0, day: Int = 0, callback: @escaping ([Transaction]) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        
        var transactions = [Transaction]()
        
        group.enter()
        queue.async {
            var queryParams = ["page":"1", "limit":"10000"]
            var dateFormat = ""
            if year != 0 {
                dateFormat += String(year)
                if month != 0 {
                    dateFormat += "-\((month / 10 == 1) ? "" : "0")\(month)"
                    if day != 0 {
                        dateFormat += "-\(day / 10)\(day % 10)"
                    }
                }
            }
            if !dateFormat.isEmpty {
                print(dateFormat)
                queryParams["date"] = dateFormat
            }
            NetworkHandler.request(method: .GET, endpoint: "/accounts/\(account_id)/transactions", request: EmptyRequest(), parameters: queryParams) { (success, res: QueryTransactionResponse?) in
                guard success else {
                    print("fail to get transaction data")
                    group.leave()
                    return
                }
                
                if let rows = res?.rows {
                    transactions = rows
                }
                group.leave()
            }
        }
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                callback(transactions)
            }
        }
    }
    
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
