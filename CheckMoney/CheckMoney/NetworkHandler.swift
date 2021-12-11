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
    
    static func request<T, V>(method: MethodList, endpoint: String, request: T, parameters: [String: String]? = nil, callback: @escaping responseClosure<V>) where T:BaseRequest, V:BaseResponse {
        guard var component = URLComponents(string: baseUrl + endpoint) else {
            print("url is nil")
            callback(false, nil)
            return
        }
        
        if parameters != nil {
            var queryItems = [URLQueryItem]()
            for (name, value) in parameters! {
                if name.isEmpty { continue }
                queryItems.append(URLQueryItem(name: name, value: value))
            }
            component.queryItems = queryItems
        }
        
        var urlRequest = URLRequest(url: component.url ?? URL(string: baseUrl + endpoint)!)
        urlRequest.httpMethod = method.rawValue
        print("Send \(method.rawValue) Request: \(urlRequest.url)")
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
            
            if (response as? HTTPURLResponse)?.statusCode == 403 {
                MainHandler.refreshAccessToken()
            }
            
            let decoder = JSONDecoder()
            let decodedData = try? decoder.decode(V.self, from: data)
            print("responseBody: \(decodedData)")
            callback((response as? HTTPURLResponse)?.statusCode == 200, decodedData ?? nil)
        }
        
        task.resume()
    }
}
