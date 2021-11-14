//
//  AccountCollection.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation

class AccountCollection {
    typealias AccountDefine = (Int, Account)
    private var accounts = Array<AccountDefine>()
    
    func addAccount(_ account: Account) {
        accounts.append((account.id, account))
    }
    
    func getCount() -> Int {
        return accounts.count
    }
    
    func getDefaultAccount() -> AccountDefine? {
        return accounts.first
    }
    
    func getAccount(index: Int) -> Account? {
        if (accounts.count <= index) {
            return nil
        }
        return accounts[index].1
    }
    
    func getTitleList() -> Array<String> {
        var list = Array<String>()
        for account in accounts {
            list.append(account.1.title)
        }
        return list
    }
}
