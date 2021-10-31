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
    var result: Bool {get set}
}

struct AuthEmailRequest: BaseRequest {
    var email: String
}

struct AuthEmailResponse: BaseResponse {
    var result: Bool
}

struct AuthConfirmCodeRequest: BaseRequest {
    var email: String
    var auth_num: String
}

struct AuthConfirmCodeResponse: BaseResponse {
    var result: Bool
}

struct GoogleLoginRequest: BaseRequest {
    var id_token: String
}

struct GoogleLoginResponse: BaseResponse {
    var result: Bool
    var token: String
}
