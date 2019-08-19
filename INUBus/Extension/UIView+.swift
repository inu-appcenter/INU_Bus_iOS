//
//  UIView+.swift
//  INUBus
//
//  Created by zun on 19/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

extension UIView {
  /// View를 360도 회전시키는 애니메이션
  func rotationAnimation(duration: CFTimeInterval) {
    let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
    rotation.toValue = Double.pi * 2
    rotation.duration = duration
    rotation.repeatCount = .infinity
    layer.add(rotation, forKey: "rotationAnimation")
  }
}


