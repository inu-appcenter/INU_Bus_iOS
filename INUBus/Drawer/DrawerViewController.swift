//
//  DrawerViewController.swift
//  INUBus
//
//  Created by zun on 19/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

final class DrawerViewController: UIViewController {
  
  @IBOutlet weak var inquiryView: RoundUIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tapRecognizer = UITapGestureRecognizer(target: self,
                                         action: #selector(presentView(gestureRecognizer:)))
    self.inquiryView.addGestureRecognizer(tapRecognizer)
  }
  
  @objc func presentView(gestureRecognizer: UITapGestureRecognizer) {
    let viewController = UIViewController
      .instantiate(storyboard: StringConstants.inquiry.rawValue,
                   identifier: StringConstants.inquiryNaviVC.rawValue)
    present(viewController, animated: true)
  }
}
