//
//  AccountCollection.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation

class AccountCollection {
    private var allAccounts = Dictionary<Int, Account>()
    
    func addAccount(_ account: Account) {
        allAccounts[account.id] = account
    }
    
    func deleteAccount(id: Int) {
        allAccounts.removeValue(forKey: id)
    }
    
    func getCount() -> Int {
        return allAccounts.count
    }
    
    func getDefaultAccount() -> Account? {
        return getAllAccounts().first
    }
    
    func getAccount(id: Int) -> Account? {
        return allAccounts[id]
    }
    
    func getAccount(title: String) -> Account? {
        return allAccounts.first { (key: Int, value: Account) in
            value.title == title
        }?.value
    }
    
    func getAllAccounts() -> Array<Account> {
        return allAccounts.map {(val1: Int, val2: Account) -> Account in return val2}.sorted { $0.id < $1.id }
    }
    
    func changeAccountData(id: Int, title: String, description: String) -> Account? {
        allAccounts[id]?.title = title
        allAccounts[id]?.description = description
        
        return allAccounts[id]
    }
    
    func getTitleList() -> Array<String> {
        return getAllAccounts().map { account in return account.title }
    }
}
