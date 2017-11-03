//
//  PrivacyVC.swift
//  Emotifont
//
//  Created by Boris Esanu on 1/18/17.
//  Copyright © 2017 Emotifont. All rights reserved.
//  *** Placeholder

import UIKit

class PrivacyVC: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        let url = Bundle.main.url(forResource: "tou", withExtension: "html")
        webView.loadRequest(URLRequest(url: url!))
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}
