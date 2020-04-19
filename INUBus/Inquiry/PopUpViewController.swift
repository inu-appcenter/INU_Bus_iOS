//
//  PopUpViewController.swift
//  INUBus
//
//  Created by 임현규 on 24/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

// 확인 버튼을 누를시 화면을 내려가게 할 viewController
final class PopUpViewController: UIViewController {

  @IBAction func yesButtonDidTap(_ sender: Any) {
    let presentingViewController = self.presentingViewController
    dismiss(animated: true) {
      presentingViewController?.dismiss(animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
