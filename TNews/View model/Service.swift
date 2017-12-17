//
//  Service.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

public protocol ServiceProtocol {
    func getNews() -> Request<[Post]>
    func getPost(id: Int) -> Request<Post>
}

public class Service: ServiceProtocol {
    private let requestPreparer: RequestPreparerProtocol
    private let parser: Parser
    
    init(requestPreparer: RequestPreparerProtocol,
         parser: Parser) {
        self.requestPreparer = requestPreparer
        self.parser = parser
    }
    
    //MARK: Network requests
    public func getNews() -> Request<[Post]> {
        return Request(urlRequest: requestPreparer.getNews(),
                       handler: parser.parse(newsData:),
                       cacheTask: getCachedPosts)
            .onSuccess(save(posts:))
    }
    
    public func getPost(id: Int) -> Request<Post> {
        return Request(urlRequest: requestPreparer.getPost(id: id),
                       handler: parser.parse(articleData:),
                       cacheTask: { [weak self] in return self?.getCachedPost(id: id) })
            .onSuccess(save(post:))
    }
    
    //MARK: Cache
    public func getCachedPosts() -> [Post] {
        let _posts = Storage.shared.postsSortedByDate()
        let posts = _posts.flatMap { Post(post: $0) }
        return posts
    }
    
    public func getCachedPost(id: Int) -> Post? {
        if let _post = Storage.shared.post(id: id) {
            let post = Post(post: _post)
            return post
        }
        return nil
    }
    
    public func save(posts: [Post]) {
        DispatchQueue.main.async {
            let cachedPosts = Storage.shared.postsSortedByDate()
            for post in posts {
                if let _post = cachedPosts.first(where: { $0.id == Int32(post.id) }) {
                    _post.copyValues(from: post)
                } else {
                    let _post = Storage.shared.createPost(id: post.id)
                    _post.copyValues(from: post)
                }
            }
            Storage.shared.saveContext()
        }
    }
    
    public func save(post: Post) {
        DispatchQueue.main.async {
            let _post = Storage.shared.findOrCreatePost(id: post.id)
            _post.copyValues(from: post)
            Storage.shared.saveContext()
        }
    }
}
