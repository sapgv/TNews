//
//  PostViewModel.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation


//MARK: Enums
public enum PostViewModelState {
    case normal, loading, error(NSError), successful
}

public class PostViewModel {
    private let service: ServiceProtocol
    private var disposeBag = DisposeBag()
    
    private var post: Post? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.titleChanged?(self?.post?.title.withoutHTML)
                self?.dateChanged?(self?.post?.date.formattedDateString)
                self?.contentChanged?(self?.post?.content)
            }
        }
    }
    
    private var state: PostViewModelState = .normal {
        didSet {
            stateChanged?(state)
        }
    }
    
    //MARK: Bindings
    public var stateChanged: ((PostViewModelState) -> Void)? {
        didSet {
            stateChanged?(state)
        }
    }
    
    public var titleChanged: ((String?) -> Void)?
    public var dateChanged: ((String?) -> Void)?
    public var contentChanged: ((String?) -> Void)?
    
    //MARK: Init
    public init() {
        
        let parser = Parser()
        let requestFactory = NetworkRequestFactory(baseURL: NetworkKeys.APIBaseURL)
        let requestPreparer = RequestPreparer(networkRequestFactory: requestFactory)
        
        let service = Service(requestPreparer: requestPreparer, parser: parser)
        self.service = service
    }
    
    public func set(postID: Int) {
        loadPost(id: postID)
    }
    
    private func loadPost(id: Int) {
        state = .loading
        service.getPost(id: id)
            .onCache { [weak self] post in
                self?.post = post
            }
            .onSuccess { [weak self] post in
                self?.post = post
                self?.state = .successful
            }
            .onError { [weak self] error in
                self?.state = .error(error as NSError)
            }
            .add(to: disposeBag)
    }
}
