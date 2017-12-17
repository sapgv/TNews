//
//  RequestBuilder.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

public enum RequestMethod: String {
    case create = "CREATE"
    case get = "GET"
    case post = "POST"
    case update = "UPDATE"
    case delete = "DELETE"
    case patch = "PATCH"
}

public protocol NetworkRequestFactoryProtocol {
    func prepareRequest(request: String, method: RequestMethod, params: [String: Any]?, externalServerUrl: String?) -> URLRequest
}

public extension NetworkRequestFactoryProtocol {
    func prepareRequest(request requestString: String, method: RequestMethod, params: [String: Any]?) -> URLRequest {
        return prepareRequest(request: requestString, method: method, params: params, externalServerUrl: nil)
    }
    func prepareRequest(request requestString: String, method: RequestMethod) -> URLRequest {
        return prepareRequest(request: requestString, method: method, params: nil, externalServerUrl: nil)
    }
}

class NetworkRequestFactory: NetworkRequestFactoryProtocol {
    private var baseURL: String
    
    //MARK: Init
    init (baseURL: String) {
        self.baseURL = baseURL
    }
    
    //MARK: -
    func prepareRequest(request requestString: String, method: RequestMethod, params: [String: Any]? = nil, externalServerUrl: String?) -> URLRequest {
        var urlString = externalServerUrl ?? baseURL
        urlString += requestString
        
        var request = URLRequest(url: urlString.url!)
        
        if let params = params {
            prepareParams(params: params, requestString: &urlString, request: &request, method: method)
        }
        
        let url = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!.url!
        request.url = url
        request.httpMethod = method.rawValue
        
        
        return request
    }
    
    func prepareParams(params: [String: Any], requestString: inout String, request: inout URLRequest, method: RequestMethod) {
        
        if method == .get {
            let parameterArray = params.map { (key, value) -> String in
                return "\(key)=\(String(describing: value))"
            }
            requestString = requestString + "?" + parameterArray.joined(separator: "&")
        } else {
            request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue:0))
        }
    }
}
