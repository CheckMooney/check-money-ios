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
    static var day = Calendar.current.component(.day, from: Date())
    
    init() {
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        
        group.enter()
        queue.async {
            NetworkHandler.request(method: .GET, endpoint: "/category", request: EmptyRequest()) { (success, response: CategoryResponse?) in
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
            NetworkHandler.request(method: .GET, endpoint: "/accounts", request: EmptyRequest()) { (success, response: AccountListResponse?) in
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
        
        group.enter()
        queue.async {
            NetworkHandler.request(method: .GET, endpoint: "/users/my-info", request: EmptyRequest()) { (success, response: UserInfoResponse?) in
                guard success, let res = response else {
                    group.leave()
                    return
                }
                UserData.name = res.name
                UserData.email = res.email
                UserData.profileImageUrl = res.img_url
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
    
    func getTransactionData(account_id: Int, year: Int = 0, month: Int = 0, day: Int = 0) {
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
                let rootVC = UIApplication.shared.windows.first!.rootViewController as? UINavigationController
                (rootVC?.viewControllers.first as? MainViewController)?.currentAccountTransaction = transactions
            }
        }
    }
    
    static func refreshAccessToken() {
        NetworkHandler.request(method: .POST, endpoint: "/auth/refresh", request: LoginRefreshRequest(refresh_token: UserData.refreshToken)) { (success, response: LoginResponse?) in
            if success, let accessToken = response?.access_token {
                UserData.accessToken = accessToken
                print("access token 갱신 완료")
            }
        }
    }
}
