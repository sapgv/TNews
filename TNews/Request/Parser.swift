//
//  PostParser.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

public protocol ParserProtocol {
    func parse(newsData: Data) throws -> [Post]
    func parse(articleData: Data) throws -> Post
}

public class Parser: ParserProtocol {
    
    public func parse(newsData: Data) throws -> [Post] {
        guard let json = try JSONSerialization.jsonObject(with: newsData) as? [String: Any],
            let payload = json[NetworkKeys.payload] as? [[String: Any]] else {
                throw NSError.invalidResponse
        }
        
        let articles = try payload.map { try parse(articleTitleJSON: $0) }
        return articles
    }
    
    public func parse(articleTitleJSON: [String: Any]) throws -> Post {
        guard let idString = articleTitleJSON[NetworkKeys.Post.Title.id] as? String,
            let id = Int(idString),
            let title = articleTitleJSON[NetworkKeys.Post.Title.title] as? String,
            let dateJSON = articleTitleJSON[NetworkKeys.Post.Title.publicationDate] as? [String: Any],
            let dateTimestamp = dateJSON[NetworkKeys.Post.Title.PublicationDate.milliseconds] as? Double else {
                throw NSError.invalidResponse
        }
        let date = Date(timeIntervalSince1970: dateTimestamp / 1000)
        let post = Post(id: id, title: title, date: date)
        return post
    }
    
    public func parse(articleData: Data) throws -> Post {
        guard let json = try JSONSerialization.jsonObject(with: articleData) as? [String: Any],
            let payload = json[NetworkKeys.payload] as? [String: Any],
            let titlePayload = payload[NetworkKeys.Post.titlePayload] as? [String: Any],
            let content = payload[NetworkKeys.Post.content] as? String else {
                throw NSError.invalidResponse
        }
        
        var post = try parse(articleTitleJSON: titlePayload)
        post.content = content
        
        return post
    }
}
