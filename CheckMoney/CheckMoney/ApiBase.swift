//
//  ApiBase.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/30.
//

import Foundation
import BetterCodable

protocol BaseRequest : Codable {
    
}

protocol BaseResponse : Codable {
    var result: Bool {get}
    var code: Int {get}
    var message: String {get}
}

struct EmptyRequest: BaseRequest {}

struct DefaultResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
}

struct DefaultEmptyStringStrategy: DefaultCodableStrategy {
    static var defaultValue: String { return "" }
}
typealias DefaultEmptyString = DefaultCodable<DefaultEmptyStringStrategy>

struct DefaultIntStrategy: DefaultCodableStrategy {
    static var defaultValue: Int { return 0 }
}
typealias DefaultInt = DefaultCodable<DefaultIntStrategy>

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

struct LoginRefreshRequest: BaseRequest {
    var refresh_token: String
}

struct LoginResponse: BaseResponse {
    var code: Int
    var message: String
    var result: Bool
    @DefaultEmptyString var access_token: String = ""
    @DefaultEmptyString var refresh_token: String = ""
    @DefaultInt var user_id: Int
    @DefaultEmptyString var name: String = ""
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

struct AccountRequest: BaseRequest {
    var title: String
    var description: String
}

struct AddAccountResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
    var id: Int
}

struct AddTransactionRequest: BaseRequest {
    var is_consumption: Int
    var price: Int
    var detail: String
    var category: Int
    var date: String
    var account_id: Int
}

struct AddTransactionResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
    var id: Int
}

struct QueryTransactionResponse: BaseResponse {
    var result: Bool
    var code: Int
    var message: String
    var rows: [Transaction]
    var count: Int
}
