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
                MainHandler.accounts.deleteAllAccounts()
                if let count = response?.count, count == 0 {
                    // 지갑이 하나도 없는 경우 디폴트 지갑을 생성함.
                    let request = AccountRequest(title: "Default", description: "")
                    NetworkHandler.request(method: .POST, endpoint: "/accounts", request: request) { (success, response: AddAccountResponse?) in
                        guard success else {
                            print("fail to add Account")
                            return
                        }
                        let account = Account(id: response!.id, title: request.title, description: request.description, createdAt: DateFormatter().string(from: Date()))
                        MainHandler.accounts.addAccount(account)
                    }
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
                if (!res.email.isEmpty) {
                    UserData.email = res.email
                }
                UserData.profileImageUrl = res.img_url
                UserData.idp = res.provider
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
    
    static func refreshAccessToken() {
        NetworkHandler.request(method: .POST, endpoint: "/auth/refresh", request: LoginRefreshRequest(refresh_token: UserData.refreshToken)) { (success, response: LoginResponse?) in
            if success, let accessToken = response?.access_token {
                UserData.accessToken = accessToken
                print("access token 갱신 완료")
            }
        }
    }
}
