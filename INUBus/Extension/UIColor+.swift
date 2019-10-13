//
//  UIColor+.swift
//  INUBus
//
//  Created by zun on 20/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

extension UIColor {
  ///정수 값을 입력해도 되는 이니셜라이져
  convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
    self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
  }
}
