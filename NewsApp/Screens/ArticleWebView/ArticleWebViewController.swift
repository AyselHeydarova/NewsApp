//
//  ArticleWebViewController.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 13.08.21.
//

import UIKit
import WebKit

class ArticleWebViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    var urlString: String

     init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }}
