//
//  WebSiteViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 9/5/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//

import UIKit

class WebSiteViewController: UIViewController {

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "https://pickupandplayapp.com") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
