//
//  CALayer+.swift
//  INUBus
//
//  Created by zun on 31/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

extension CALayer {
  // sketch에 나와 있는 그림자 설정을 하기 위한 함수.
  func applyShadow(x: CGFloat = 0,
                 y: CGFloat = 3,
                 blur: CGFloat = 5,
                 spread: CGFloat = 0,
                 color: UIColor = UIColor(red: 0, green: 0, blue: 0),
                 alpha: Float = 0.16) {
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
    shadowColor = color.cgColor
    shadowOpacity = alpha
  }
}
