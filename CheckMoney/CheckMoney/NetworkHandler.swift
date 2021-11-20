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
    
    enum MethodList: String {
        case POST, GET, PUT, DELETE
    }
    
    static func request<T, V>(method: MethodList, endpoint: String, request: T, callback: @escaping responseClosure<V>) where T:BaseRequest, V:BaseResponse {
        guard let url = URL(string: baseUrl + endpoint) else {
            print("url is nil")
            callback(false, nil)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        print("Send \(method.rawValue) Request: \(endpoint)")
        
        switch method {
        case .GET: break
        default:
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
            urlRequest.httpBody = encodedData
        }
        sendRequest(&urlRequest, callback: callback)
    }
//
//    static func post<T, V>(endpoint: String, request: T, callback: @escaping responseClosure<V>) where T:BaseRequest, V:BaseResponse {
//        guard let url = URL(string: baseUrl + endpoint) else {
//            print("url is nil")
//            callback(false, nil)
//            return
//        }
//
//        let encoder = JSONEncoder()
//        let encodedData = try? encoder.encode(request)
//
//        guard encodedData != nil else {
//            print("fail to encode")
//            callback(false, nil)
//            return
//        }
//        if let jsonData = encodedData, let jsonString = String(data: jsonData, encoding: .utf8) {
//            print("requestBody: \(jsonString)")
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        print("Send POST Request: \(endpoint)")
//        urlRequest.httpBody = encodedData
//
//        sendRequest(&urlRequest, callback: callback)
//    }
//
//    static func get<T>(endpoint: String, callback: @escaping responseClosure<T>) where T: BaseResponse {
//        guard let url = URL(string: baseUrl + endpoint) else {
//            print("url is nil")
//            callback(false, nil)
//            return
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        print("Send GET Request: \(endpoint)")
//        sendRequest(&urlRequest, callback: callback)
//    }
//
//    static func put<T, V>(endpoint: String, request: T, callback: @escaping responseClosure<V>) where T: BaseRequest, V: BaseResponse {
//        guard let url = URL(string: baseUrl + endpoint) else {
//            print("url is nil")
//            callback(false, nil)
//            return
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "PUT"
//        print("Send PUT Request: \(endpoint)")
//        sendRequest(&urlRequest, callback: callback)
//    }
    
    static func sendRequest<V>(_ urlRequest: inout URLRequest, callback: @escaping responseClosure<V>) where V: BaseResponse {
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(UserData.accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession(configuration: .default).dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                print("Error in sendPost: \(String(describing: error))")
                callback(false, nil)
                return
            }
            guard let data = data else {
                callback(false, nil)
                return
            }
            print("\(response!.url!) statusCode is \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            
            let decoder = JSONDecoder()
            let decodedData = try? decoder.decode(V.self, from: data)
            print("responseBody: \(decodedData)")
            callback((response as? HTTPURLResponse)?.statusCode == 200, decodedData ?? nil)
        }
        
        task.resume()
    }
}
