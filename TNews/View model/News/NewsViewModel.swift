//
//  NewsViewModel.swift
//  TNews
//
//  Created by Гриша on 12.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

//MARK: Enums
public enum NewsViewModelState {
    case normal, loading, error(NSError), successful, cachedDataLoaded
}

public class NewsViewModel: PostViewModelsStorage{
    
    private let service: ServiceProtocol
    private var disposeBag = DisposeBag()

    private var posts: [Post] = []
    public var cachedViewModels: [Int: NewsCellViewModel] = [:]
    private lazy var cacheOperations: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Cache queue"
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 2
        return queue
    } ()
    
    private var state: NewsViewModelState = .normal {
        didSet {
            stateChanged?(state)
        }
    }
    
    //MARK: Bindings
    public var stateChanged: ((NewsViewModelState) -> Void)?
    
    //MARK: Init
    public init(service: ServiceProtocol) {
        self.service = service
    }
    public func getNews() {
        
        guard state != .loading else { return }

        state = .loading
        service.getNews()
            .onCache { [weak self] posts in
                guard let strongSelf = self else { return }
                if strongSelf.posts.count == 0 {
                    strongSelf.posts = posts
                    strongSelf.cacheOperations.cancelAllOperations()
                    strongSelf.prefetchViewModels()
                    strongSelf.state = .cachedDataLoaded
                }
            }
            .onSuccess { [weak self] posts in
                guard let strongSelf = self else { return }
                let sortedPosts = posts.sorted { $0.date > $1.date }
                strongSelf.cachedViewModels.removeAll()
                strongSelf.posts = sortedPosts
                strongSelf.cacheOperations.cancelAllOperations()
                strongSelf.prefetchViewModels()
                strongSelf.state = .successful
            }
            .onError { [weak self] error in
                self?.state = .error(error as NSError)
            }
            .add(to: disposeBag)
        
    }
    
    //MARK: Datasource
    public func post(at index: Int) -> NewsCellViewModel {
        let post = posts[index]
        if let viewModel = cachedViewModels[post.id] {
            return viewModel
        }
        let viewModel = NewsCellViewModel(model: post)
        cachedViewModels[post.id] = viewModel
        return viewModel
    }
    
    public func numberOfPosts() -> Int {
        return posts.count
    }
    
    public func prefetchViewModels() {
        for model in posts {
            if cachedViewModels[model.id] == nil {
                cacheOperations.addOperation(CacheOperation(model: model, storage: self))
            }
        }
    }
    
    public func configure(postViewModel: PostViewModel, at index: Int) {
        let post = posts[index]
        postViewModel.set(postID: post.id)
    }
    
}
