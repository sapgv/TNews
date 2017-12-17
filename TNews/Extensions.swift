//
//  Extensions.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import UIKit

extension UIView {
    class var describing: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: describing, bundle: nil)
    }
    
    class func instantiateFromNib() -> Self {
        return _instantiateFromNib()
    }
    
    private class func _instantiateFromNib<T>() -> T {
        return nib.instantiate(withOwner: nil, options: nil)[0] as! T
    }
}

extension String {
    func caseInsensitiveContains(_ otherString: String) -> Bool {
        return self.lowercased().contains(otherString.lowercased())
    }
    
    var url: URL? {
        return URL(string: self)
    }
    
    var trimWhitespaces: String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var length: Int {
        return characters.count
    }
    
    var withoutHTML: String {
        do {
            guard let htmlStringData = self.data(using: String.Encoding.utf8) else { return self }
            
            let options: [String: Any] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue)]
            
            let attributedHTMLString = try NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
            
            return attributedHTMLString.string
        } catch _ {
            return self
        }
    }
}

extension Date {
    var formattedDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .long
        
        return dateFormatter.string(from: self)
    }
}

extension Request: Disposable {
    open func dispose() {
        dataTask?.cancel()
        dataTask = nil
    }
}

extension NewsViewModelState: Equatable { }

public func == (lhs: NewsViewModelState, rhs: NewsViewModelState) -> Bool {
    switch (lhs, rhs) {
    case (.normal, .normal):
        return true
    case (.successful, .successful):
        return true
    case (.cachedDataLoaded, .cachedDataLoaded):
        return true
    case (.loading, .loading):
        return true
    default:
        return false
    }
}

public let eInvalidResponseErrorText = NSLocalizedString("invalidServerResponseErrorText", comment: "")

extension Error {
    static var invalidResponse: NSError {
        return NSError(domain: eInvalidResponseErrorText, code: 0, userInfo: nil)
    }
}

extension UIViewController {
    func showAlert(with error: NSError, additionalAction: ((Void) -> Void)? = nil) {
        var message = error.localizedDescription
        if message.isEmpty {
            message = error.domain
        }
        showOkAlert(title: NSLocalizedString("errorAlertTitle", comment: ""), message: NSLocalizedString(message, comment: ""), additionalAction: additionalAction)
    }
    
    func showOkAlert(title: String, message: String? = "", additionalAction: ((Void) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("alertOkTitle", comment: ""), style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
            if let action = additionalAction {
                action()
            }
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showStatusHud() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func hideStatusHud() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
