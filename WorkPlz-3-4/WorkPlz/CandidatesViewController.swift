//
//  CandidatesViewController.swift
//  WorkPlz
//
//  Created by UbiComp on 11/22/19.
//  Copyright © 2019 UbiComp. All rights reserved.
//

import UIKit
import WebKit
class CandidatesViewController: UIViewController , WKNavigationDelegate{

    @IBOutlet  var webView: WKWebView!
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string:"https://projects.houstonchronicle.com/2019/elections/runoffs-voters-guide/#/")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
