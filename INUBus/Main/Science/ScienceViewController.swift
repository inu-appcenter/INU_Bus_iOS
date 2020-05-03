//
//  ScienceViewController.swift
//  INUBus
//
//  Created by zun on 30/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 자연과학대 버스 정류장의 버스 정보를 보여줄 viewController
final class ScienceViewController: MainViewController {
  override var busStopIdentifier: String {
    return StringConstants.science.rawValue
  }
  
  override var tabBarIndex: Int {
    return 1
  }
}
