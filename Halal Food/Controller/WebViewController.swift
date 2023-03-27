//
//  WebViewController.swift
//  Halal Food
//
//  Created by Sorfian on 08/03/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    
    var targetURL: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: targetURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

}
