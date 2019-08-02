//
//  EngineeringViewController.swift
//  INUBus
//
//  Created by zun on 19/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit
import KYDrawerController

class EngineeringViewController: UIViewController {
  
  let message = "INU BUS 는\n하교 시, 버스 시간을 정확히 알 수 없는 인천대학교 학생들을 위한\n버스 앱입니다.\n즐거운 하교길 되세요 :)"
  
  @IBAction func touch() {
    if let drawerController = navigationController?.parent?.parent as?
      KYDrawerController {
      drawerController.setDrawerState(.opened, animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIAlertController
      .alert(title: nil, message: message)
      .setMessage(start: 0,
                  end: message.count,
                  font: UIFont(name: "NotoSans-Medium", size: 13),
                  color: .black)
      .setMessage(start: 0,
                  end: 7,
                  font: UIFont(name: "Jalnan", size: 13),
                  color: UIColor(red: 0/255, green: 97/255, blue: 244/255, alpha: 1))
      .action(title: "확인했습니다", style: .default, completion: nil)
    
      .present(to: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
}
