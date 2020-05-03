//
//  ReloadDataDelegate.swift
//  INUBus
//
//  Created by zun on 07/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

/// cell에서 tableView를 reload하기 위해 사용될 delegate 패턴 protocol
protocol ReloadDataDelegate: class {
  func tableViewReloadData()
}
