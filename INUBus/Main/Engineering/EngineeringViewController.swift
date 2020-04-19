//
//  EngineeringViewController.swift
//  INUBus
//
//  Created by zun on 19/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

// 공대 버스 정류장의 버스 정보를 보여줄 viewController
final class EngineeringViewController: MainViewController {
  override var busStopIdentifier: String {
    return StringConstants.engineer.rawValue
  }
  
  override var tabBarIndex: Int {
    return 0
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 공지사항 띄위기
    showNoticeAlertController(viewController: self)
  }
}
