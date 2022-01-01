//
//  NetworkHandler.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/30.
//

import Foundation
import UIKit

class NetworkHandler {
    typealias responseClosure<V: BaseResponse> = ((Bool, V?) -> Void)
    static let session = URLSession(configuration: URLSessionConfiguration.default)
    static let baseUrl = "https://checkmoneyproject.azurewebsites.net/api"
    
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
        print("Send \(method.rawValue) Request: \(String(describing: urlRequest.url))")
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
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        sendRequest(&urlRequest, callback: callback)
    }
    
    static func uploadFormData<V>(image: UIImage, endpoint: String, callback: @escaping responseClosure<V>) where V: BaseResponse {
        let boundary = "Boundary-\(NSUUID().uuidString)"
        let imageData = image.jpegData(compressionQuality: 0.4)!
        var urlRequest = URLRequest(url: URL(string: baseUrl + endpoint)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = createDataBody(boundary: boundary, binaryData: imageData, mimeType: "image/jpg")
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        sendRequest(&urlRequest, callback: callback)
    }
    
    static private func sendRequest<V>(_ urlRequest: inout URLRequest, callback: @escaping responseClosure<V>) where V: BaseResponse {
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
    
    static private func createDataBody(boundary: String, binaryData: Data, mimeType: String) -> Data {
        // https://gist.github.com/nnsnodnb/efd4635a6be2be41fdb67135d2dd9257
        
        var postContent = "--\(boundary)\r\n"
        let fileName = "\(UUID().uuidString).jpeg"
        postContent += "Content-Disposition: form-data; name=\"img\"; filename=\"\(fileName)\"\r\n"
        postContent += "Content-Type: \(mimeType)\r\n\r\n"

        var data = Data()
        guard let postData = postContent.data(using: .utf8) else { return data }
        data.append(postData)
        data.append(binaryData)

        guard let endData = "\r\n--\(boundary)--\r\n".data(using: .utf8) else { return data }
        data.append(endData)
        return data
    }
}
