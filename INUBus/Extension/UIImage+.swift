//
//  UIImage+.swift
//  INUBus
//
//  Created by zun on 30/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

extension UIImage {
  /// 간단한 원(점)을 만드는 함수
  class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
    let currentContext = UIGraphicsGetCurrentContext()!
    currentContext.saveGState()
    
    let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
    currentContext.setFillColor(color.cgColor)
    currentContext.fillEllipse(in: rect)
    
    currentContext.restoreGState()
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return image
  }
}
