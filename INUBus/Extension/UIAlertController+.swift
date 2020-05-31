//
//  UIAlertController+.swift
//  INUBus
//
//  Created by zun on 12/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

// UIAlertController를 편리한 사용의 도움을 줄 메소드
extension UIAlertController {
  
  static func alert(title: String?,
                    message: String?,
                    style: UIAlertController.Style = .alert) -> UIAlertController {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: style)
    alert.view.tintColor = UIColor(red: 0/255, green: 97/255, blue: 244/255, alpha: 1)
    return alert
  }
  
  func action(title: String?,
              style: UIAlertAction.Style = .default,
              completion: ((UIAlertAction, [UITextField]?) -> Void)? = nil) -> UIAlertController {
    guard let textFields = textFields else {
      let action = UIAlertAction(title: title, style: style) { completion?($0, nil) }
      addAction(action)
      return self
    }
    
    let action = UIAlertAction(title: title, style: style) {
      (completion?($0, textFields))
    }
    addAction(action)
    return self
  }
  
  func present(to viewController: UIViewController?,
               animated: Bool = true,
               completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
      if !(viewController?.presentedViewController is UIAlertController) {
        viewController?.present(self, animated: animated, completion: completion)
      }
    }
  }
  
  func setMessage(start: Int, end: Int, font: UIFont?, color: UIColor?) -> UIAlertController {
    guard let message = self.message else { return self }
    
    let attributedString = NSMutableAttributedString(string: message)
    
    if let messageFont = font {
      attributedString.addAttributes(
        [NSAttributedString.Key.font: messageFont],
        range: NSRange(location: start, length: end))
    }
    
    if let messageColor = color {
      attributedString.addAttributes(
        [NSAttributedString.Key.foregroundColor: messageColor],
        range: NSRange(location: start, length: end))
    }
    
    self.setValue(attributedString, forKey: "attributedMessage")
    return self
  }
}
