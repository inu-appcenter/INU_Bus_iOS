//
//  Date+.swift
//  INUBus
//
//  Created by zun on 06/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

// millisecond를 구하기 위한 코드
extension Date {
  var millisecondsSince1970: Int64 {
    return Int64((self.timeIntervalSince1970 * 1000).rounded())
  }
}
