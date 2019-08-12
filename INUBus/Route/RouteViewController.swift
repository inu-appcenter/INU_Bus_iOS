//
//  RouteViewController.swift
//  INUBus
//
//  Created by zun on 12/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    self.navigationController?.navigationBar.barTintColor = .white
    changeStatusBarColor(barStyle: .default)
    self.navigationController?.popViewController(animated: true)
  }
  
}

extension RouteViewController {
  func setUp() {
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255,
                                                                    green: 97/255,
                                                                    blue: 244/255,
                                                                    alpha: 1)
    changeStatusBarColor(barStyle: .lightContent)
  }
}
