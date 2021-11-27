//
//  MainHandler.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation
import UIKit

class MainHandler {
    private(set) static var category = ["식비", "쇼핑", "test1", "기타"]
    private(set) static var accounts = AccountCollection()
    
    static var year = Calendar.current.component(.year, from: Date())
    static var month = Calendar.current.component(.month, from: Date())
    
    init() {
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        
        group.enter()
        queue.async {
            NetworkHandler.request(method: .GET, endpoint: "category", request: EmptyRequest()) { (success, response: CategoryResponse?) in
                guard success else {
                    group.leave()
                    return
                }
                
                if let category = response?.category {
                    MainHandler.category.removeAll()
                    MainHandler.category = category
                }
                group.leave()
            }
        }
        
        group.enter()
        queue.async {
            NetworkHandler.request(method: .GET, endpoint: "accounts", request: EmptyRequest()) { (success, response: AccountListResponse?) in
                guard success else {
                    group.leave()
                    return
                }
                if let list = response?.rows {
                    for i in list {
                        MainHandler.accounts.addAccount(i)
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: queue) {
            print("group complete async")
            DispatchQueue.main.async {
                let rootVC = UIApplication.shared.windows.first!.rootViewController as? UINavigationController
                (rootVC?.viewControllers.first as? MainViewController)?.initViewData()
            }
        }
    }
    
    func getDefaultAccount() -> Account? {
        return MainHandler.accounts.getDefaultAccount()
    }
    
    func getTransactionData(account_id: Int) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        
        var transactions = [Transaction]()
        
        group.enter()
        queue.async {
            NetworkHandler.request(method: .GET, endpoint: "accounts/\(account_id)/transactions", request: EmptyRequest()) { (success, res: QueryTransactionResponse?) in
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
                let rootVC = UIApplication.shared.windows.first!.rootViewController as? UINavigationController
                (rootVC?.viewControllers.first as? MainViewController)?.currentAccountTransaction = transactions
            }
        }
    }
}
