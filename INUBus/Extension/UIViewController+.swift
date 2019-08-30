//
//  UIViewController+.swift
//  INUBus
//
//  Created by zun on 31/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

extension UIViewController {
  static func instantiate(storyboard: String, identifier: String) -> UIViewController {
    let storyboard = UIStoryboard(name: storyboard, bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: identifier)
    return controller
  }
  
  func push(at viewController: UIViewController?, animated: Bool = true) {
    if let navigationController = viewController?.navigationController {
      DispatchQueue.main.async {
        navigationController.pushViewController(self, animated: animated)
      }
    } else {
      fatalError("Navigation 스택에 있지 않습니다.")
    }
  }
}
