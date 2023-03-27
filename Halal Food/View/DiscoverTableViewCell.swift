//
//  DiscoverTableViewCell.swift
//  Halal Food
//
//  Created by Sorfian on 21/03/23.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.adjustsFontForContentSizeCategory = true
            nameLabel.numberOfLines = 0
        }
    }
    @IBOutlet var locationLabel: UILabel! {
        didSet {
            locationLabel.adjustsFontForContentSizeCategory = true
            locationLabel.numberOfLines = 0
        }
    }
    @IBOutlet var typeLabel: UILabel! {
        didSet {
            typeLabel.adjustsFontForContentSizeCategory = true
            typeLabel.numberOfLines = 0
        }
    }
    @IBOutlet var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.adjustsFontForContentSizeCategory = true
            descriptionLabel.numberOfLines = 0
        }
    }
    @IBOutlet var thumbnailImageView: UIImageView! {
        didSet {
            thumbnailImageView.layer.cornerRadius = 30.0
            thumbnailImageView.clipsToBounds = true
            thumbnailImageView.contentMode = .scaleAspectFill
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
