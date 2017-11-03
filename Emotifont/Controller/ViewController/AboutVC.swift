//
//  AboutVC.swift
//  Emotifont
//
//  Created by Buzz on 1/31/17.
//  Copyright © 2017 Emotifont. All rights reserved.
//

import UIKit

@objc class AboutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    self.navigationController?.navigationBar.tintColor = UIColor.white


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func emailButton(_ sender: Any) {
        

    }

    @IBAction func websiteButton(_ sender: Any) {
        
        let url = URL(string: "http://www.emotifont.net")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        let imageData = NSData();
        
    }
    
    @IBAction func instagramButton(_ sender: Any) {
        
        let url = URL(string: "instagram://user?username=Emotifont")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        
        let url = URL(string: "fb://profile/1709322405875729")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    @IBAction func twitterButton(_ sender: Any) {
        
        let url = URL(string: "twitter://user?screen_name=Emotifont")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    @IBAction func tumblrButton(_ sender: Any) {
        
        let url = URL(string: "http://emotifont.tumblr.com/")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    @IBAction func restorePurchases(_ sender: Any) {
        
        PurchaseController.sharedInstance().restorePurchases(self)
        
    }
    
    
    

}
