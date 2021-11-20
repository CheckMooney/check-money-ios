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
}
