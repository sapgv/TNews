//
//  RequestPrepearer.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation


public protocol RequestPreparerProtocol {
    func getNews() -> URLRequest
    func getPost(id: Int) -> URLRequest
}

public class RequestPreparer: RequestPreparerProtocol {
    private let networkRequestFactory: NetworkRequestFactoryProtocol
    
    init(networkRequestFactory: NetworkRequestFactoryProtocol) {
        self.networkRequestFactory = networkRequestFactory
    }
    
    public func getNews() -> URLRequest {
        return networkRequestFactory.prepareRequest(request: NetworkKeys.Requests.news,
                                                    method: .get)
    }
    
    public func getPost(id: Int) -> URLRequest {
        let params: [String: Any] = [NetworkKeys.Post.Title.id : id]
        return networkRequestFactory.prepareRequest(request: NetworkKeys.Requests.postContent,
                                                    method: .get,
                                                    params: params)
    }
}
