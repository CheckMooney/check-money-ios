//
//  ResponseCode.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/07.
//

import Foundation

enum ResponseCode: Int {
    case unknown = 0
    case ok = 20000
    case vaildationError = 40000
    case withdrawn = 40001
    case alreadyExist = 40002
    case incorrectAuthNum = 40003
    case expired = 40004
    case emailAuthNeeded = 40005
    case oauthFail = 40009
    case error = 50000
}

extension ResponseCode {
    func toString() -> String {
        switch(self) {
        case .unknown:
            return "Unknown"
        case .ok:
            return "성공"
        case .vaildationError:
            return "property 부족"
        case .withdrawn:
            return "탈퇴한 계정입니다."
        case .alreadyExist:
            return "이미 존재하는 계정입니다."
        case .incorrectAuthNum:
            return "잘못된 인증 번호 입니다."
        case .expired:
            return "인증 시간이 만료되었습니다."
        case .emailAuthNeeded:
            return "이메일을 먼저 전송해야 합니다."
        case .oauthFail:
            return "oauth fail"
        case .error:
            return "서버 에러. 고객센터에 문의하세요."
        }
    }
}
