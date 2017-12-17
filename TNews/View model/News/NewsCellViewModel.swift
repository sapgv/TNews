//
//  NewsCellViewModel.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

public class NewsCellViewModel {
    
    let id: Int
    let title: String
    let date: String
    
    public init(model: Post) {
        id = model.id
        title = model.title.withoutHTML
        date = model.date.formattedDateString
    }
}
