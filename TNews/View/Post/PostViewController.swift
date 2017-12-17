//
//  PostViewController.swift
//  TNews
//
//  Created by Гриша on 18.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation
import UIKit

public class PostViewController: UIViewController {
    @IBOutlet private weak var webView: UIWebView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var webViewHeightConstraint: NSLayoutConstraint!
    
    public var viewModel: PostViewModel! = PostViewModel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = ""
        dateLabel.text = ""
        setupBindings()
        setupWebView()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideStatusHud()
    }
    
    private func setupBindings() {
        viewModel.stateChanged = { [weak self] state in
            guard let strongSelf = self else { return }
            switch state {
            case .normal:
                strongSelf.hideStatusHud()
            case .successful:
                strongSelf.hideStatusHud()
            case .loading:
                strongSelf.showStatusHud()
            case .error(let error):
                strongSelf.hideStatusHud()
                strongSelf.showAlert(with: error)
            }
        }
        
        viewModel.titleChanged = { [weak self] title in
            self?.titleLabel.text = title
        }
        
        viewModel.dateChanged = { [weak self] date in
            self?.dateLabel.text = date
        }
        
        viewModel.contentChanged = { [weak self] content in
            guard let content = content else { return }
            self?.webView.loadHTMLString(content, baseURL: nil)
        }
    }
    
    private func setupWebView() {
        webView.backgroundColor = UIColor.white
        webView.scrollView.contentInset = UIEdgeInsets.zero
        webView.scrollView.isScrollEnabled = false
        webView.delegate = self
    }
}

extension PostViewController: UIWebViewDelegate {
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.async { [weak self] in
            self?.webViewHeightConstraint.constant = webView.scrollView.contentSize.height
        }
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType != .linkClicked {
            return true
        }
        if let url = request.url {
            UIApplication.shared.openURL(url)
        }
        return false
    }
}
