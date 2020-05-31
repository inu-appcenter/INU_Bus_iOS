//
//  FrontGateViewController.swift
//  INUBus
//
//  Created by zun on 24/12/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 학교 정문 버스 정류장의 버스 정보를 보여줄 viewController
final class FrontGateViewController: MainViewController {
  override var busStopIdentifier: String {
    return StringConstants.frontgate.rawValue
  }
  
  override var tabBarIndex: Int {
    return 2
  }
}
