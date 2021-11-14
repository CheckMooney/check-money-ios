//
//  UserData.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/14.
//

import Foundation

class UserData {
    static var refreshToken: String {
        get {
            return UserDefaults.standard.string(forKey: "refresh_token") ?? ""
        }
        set {
            if newValue.isEmpty {
                UserDefaults.standard.removeObject(forKey: "refresh_token")
            } else {
                UserDefaults.standard.set(newValue, forKey: "refresh_token")
            }
        }
    }
    
    static var accessToken: String {
        get {
            return UserDefaults.standard.string(forKey: "access_token") ?? ""
        }
        set {
            if newValue.isEmpty {
                UserDefaults.standard.removeObject(forKey: "access_token")
            } else {
                UserDefaults.standard.set(newValue, forKey: "access_token")
            }
        }
    }
    
    static var email: String {
        get {
            return UserDefaults.standard.string(forKey: "email") ?? ""
        }
        set {
            if newValue.isEmpty {
                UserDefaults.standard.removeObject(forKey: "email")
            } else {
                UserDefaults.standard.set(newValue, forKey: "email")
            }
        }
    }
    static var name: String {
        get {
            return UserDefaults.standard.string(forKey: "name") ?? ""
        }
        set {
            if newValue.isEmpty {
                UserDefaults.standard.removeObject(forKey: "name")
            } else {
                UserDefaults.standard.set(newValue, forKey: "name")
            }
        }
    }
    
    static func reset() {
        refreshToken = ""
        accessToken = ""
        email = ""
        name = ""
    }
}
