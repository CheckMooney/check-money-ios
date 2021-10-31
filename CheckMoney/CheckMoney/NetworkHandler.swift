//
//  NetworkHandler.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/30.
//

import Foundation

class NetworkHandler {
    typealias responseClosure<V: BaseResponse> = ((Bool, V?) -> Void)
    static let session = URLSession(configuration: URLSessionConfiguration.default)
    static let baseUrl = "http://ec2-3-38-105-161.ap-northeast-2.compute.amazonaws.com:3001/api/"
    
    static func sendPost<T, V>(endpoint: String, request: T, callback: @escaping responseClosure<V>) where T:BaseRequest, V:BaseResponse {
        guard let url = URL(string: baseUrl + endpoint) else {
            print("url is nil")
            callback(false, nil)
            return
        }
        
        let encoder = JSONEncoder()
        let encodedData = try? encoder.encode(request)
        
        guard encodedData != nil else {
            print("fail to encode")
            callback(false, nil)
            return
        }
        if let jsonData = encodedData, let jsonString = String(data: jsonData, encoding: .utf8) {
            print("requestBody: \(jsonString)")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = encodedData
        
        let task = URLSession(configuration: .default).dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                print("Error in sendPost: \(String(describing: error))")
                callback(false, nil)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("sendPost statusCode is \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                callback(false, nil)
                return
            }
            
            let decoder = JSONDecoder()
            let decodedData = try? decoder.decode(V.self, from: data)
            callback(true, decodedData!)
        }
        
        task.resume()
    }
}