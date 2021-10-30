//
//  NetworkHandler.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/30.
//

import Foundation

class NetworkHandler {
    static let session = URLSession(configuration: URLSessionConfiguration.default)
    static let baseUrl = "http://ec2-3-38-105-161.ap-northeast-2.compute.amazonaws.com:3001/api/"

    static func sendPost(endpoint: String, request: BaseRequest, callback: (isSuccess: Bool, response: BaseResponse)){
        guard let url = URL(string: baseUrl + endpoint) else {
            print("url is nil")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        var jsonData = try? JSONSerialization.data(withJSONObject: urlRequest)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
        }

    }
}
