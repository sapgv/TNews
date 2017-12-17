//
//  News.swift
//  TNews
//
//  Created by Гриша on 12.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

public struct Post {
    
    let id: Int
    let title: String
    let date: Date
    var content: String
    
    public init(id: Int, title: String, date: Date, content: String = "") {
        self.id = id
        self.title = title
        self.date = date
        self.content = content
    }
    
    public init?(post: _Post) {
        
        guard let title = post.title,
            let date = post.date as Date?,
            let content = post.content else {
                return nil
        }
        self.id = Int(post.id)
        self.title = title
        self.date = date
        self.content = content
        
    }
}

extension _Post {
    
    public func copyValues(from post: Post) {
        id = Int32(post.id)
        title = post.title
        date = post.date as NSDate
        
        if content == nil || !post.content.isEmpty {
            content = post.content
        }
    }
    
}
