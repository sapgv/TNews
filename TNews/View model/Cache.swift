//
//  Cache.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

public protocol PostViewModelsStorage: class {
    var cachedViewModels: [Int: NewsCellViewModel] { get set }
}

public class CacheOperation: Operation {
    public let model: Post
    public weak var storage: PostViewModelsStorage?
    
    public init(model: Post, storage: PostViewModelsStorage) {
        self.model = model
        self.storage = storage
    }
    
    public override func main() {
        guard !checkIsCancelled() else { return }
        
        let viewModel = NewsCellViewModel(model: model)
        
        guard !checkIsCancelled() else { return }
        
        guard let storage = storage else { return }
        
        storage.cachedViewModels[model.id] = viewModel
    }
    
    private func checkIsCancelled() -> Bool {
        guard !isCancelled, let storage = storage, storage.cachedViewModels[model.id] == nil else {
            return true
        }
        return false
    }
}
