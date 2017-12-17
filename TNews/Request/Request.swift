//
//  Request.swift
//  TNews
//
//  Created by Гриша on 12.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

open class Request<T> {
    public typealias SuccessActions = (T) -> Void
    public typealias ErrorActions = (Error) -> Void
    
    open var dataTask: URLSessionDataTask?
    private var successActions: [SuccessActions]
    private var cacheActions: [SuccessActions]
    private var errorActions: [ErrorActions]
    
    private var cachedData: T?
    
    init(urlRequest: URLRequest, handler: @escaping  ((Data) throws -> T), cacheTask: ((Void) -> T?)? = nil) {
        successActions = []
        errorActions = []
        cacheActions = []
        
        if let cacheTask = cacheTask {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                if let cachedData = cacheTask() {
                    self?.cachedData = cachedData
                    for cacheAction in self?.cacheActions ?? [] {
                        cacheAction(cachedData)
                    }
                }
            }
        }
        
        dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.global(qos: .utility).async {
                guard let sSelf = self else { return }
                var error: Error? = error
                
                defer {
                    if let error = error {
                        for errorAction in sSelf.errorActions {
                            errorAction(error)
                        }
                    }
                }
                
                if let _ = error { return }
                
                guard let data = data else { return }
                
                do {
                    let object = try handler(data)
                    for successAction in sSelf.successActions {
                        successAction(object)
                    }
                } catch let parseError {
                    error = parseError
                }
            }
        }
        dataTask?.resume()
    }
    
    //MARK: - States
    
    open func onCache(_ cacheActions: @escaping SuccessActions) -> Self {
        self.cacheActions.append(cacheActions)
        if let cachedData = cachedData {
            cacheActions(cachedData)
        }
        return self
    }
    
    open func onSuccess(_ successActions: @escaping SuccessActions) -> Self {
        self.successActions.append(successActions)
        return self
    }
    
    open func onError(_ errorActions: @escaping ErrorActions) -> Self {
        self.errorActions.append(errorActions)
        return self
    }
}


