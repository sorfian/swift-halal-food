//
//  RestaurantDetailHeaderView.swift
//  Halal Food
//
//  Created by Sorfian on 26/02/23.
//

import UIKit

class RestaurantDetailHeaderView: UIView {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.numberOfLines = 0
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 40) {
                nameLabel.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: customFont)
            }
        }
    }
    @IBOutlet var typeLabel: UILabel! {
        didSet {
            if let customFont = UIFont(name: "Nunito-Bold", size: 20) {
                typeLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
            }
        }
    }
    @IBOutlet var ratingImageView: UIImageView!

}
