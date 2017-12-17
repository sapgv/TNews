//
//  NewsPostCell.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    public static let estimatedHeight: CGFloat = 60
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func reset() {
        titleLabel.text = ""
        dateLabel.text = ""
    }
    
    public func set(viewModel: NewsCellViewModel) {
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.date
    }

}
