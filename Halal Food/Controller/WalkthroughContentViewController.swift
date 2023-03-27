//
//  WalkthroughContentViewController.swift
//  Halal Food
//
//  Created by Sorfian on 06/03/23.
//

import UIKit

class WalkthroughContentViewController: UIViewController {
    
    @IBOutlet var headingLabel: UILabel! {
        didSet {
            headingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var subheadingLabel: UILabel! {
        didSet {
            subheadingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var contentImageView: UIImageView!
    
    var index: Int = 0
    var heading: String = ""
    var subheading: String = ""
    var imageFile: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text = heading
        subheadingLabel.text = subheading
        contentImageView.image = UIImage(named: imageFile)
    }
    

    

}
