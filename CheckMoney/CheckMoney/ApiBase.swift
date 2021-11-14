//
//  ApiBase.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/30.
//

import Foundation

protocol BaseRequest : Codable {
    
}

protocol BaseResponse : Codable {
    var result: Bool {get}
    var code: Int {get}
    var message: String {get}
}

struct AuthEmailRequest: BaseRequest {
    var email: String
}

struct AuthEmailResponse: BaseResponse {
    var code: Int
    var message: String
    var result: Bool
}

struct AuthConfirmCodeRequest: BaseRequest {
    var email: String
    var auth_num: String
}

struct AuthConfirmCodeResponse: BaseResponse {
    var code: Int
    var message: String
    var result: Bool
}

struct AuthJoinRequest: BaseRequest {
    var email: String
    var password: String
    var name: String
}

struct AuthJoinResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
}

struct GoogleLoginRequest: BaseRequest {
    var id_token: String
}

struct EmailLoginRequest: BaseRequest {
    var email: String
    var password: String
}

struct LoginResponse: BaseResponse {
    var code: Int
    var message: String
    var result: Bool
    var access_token: String = ""
    var refresh_token: String = ""
}

struct LoginRefreshRequest: BaseRequest {
    var refresh_token: String
}

struct LoginRefreshResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
    var access_token: String = ""
    var refresh_token: String = ""
}

struct CategoryResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
    var category: [String]
}

struct AccountListResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
    var rows: [Account]
    var count: Int
}

struct AddAccountRequest: BaseRequest {
    var title: String
    var description: String
}

struct AddAccountResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
    var id: Int
}
