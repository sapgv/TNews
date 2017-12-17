//
//  NetworkKeys.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

enum NetworkKeys {
    static let APIBaseURL = "https://api.tinkoff.ru/v1/"
    
    enum Requests {
        static let news = "news"
        static let postContent = "news_content"
    }
    
    enum Post {
        static let content = "content"
        
        static let titlePayload = "title"
        
        enum Title {
            static let id = "id"
            static let title = "text"
            static let publicationDate = "publicationDate"
            
            enum PublicationDate {
                static let milliseconds = "milliseconds"
            }
        }
    }
    
    static let payload = "payload"
}
