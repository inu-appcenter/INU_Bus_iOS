//
//  TableViewUpDelegate.swift
//  INUBus
//
//  Created by zun on 18/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

/// cell에서 tablewView를 위로 올리게 해줄 delegate 패턴을 위한 protocol
protocol TableViewUpDelegate: class {
  func scrollToTableViewTop()
}
