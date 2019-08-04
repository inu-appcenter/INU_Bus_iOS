//
//  Functions.swift
//  INUBus
//
//  Created by zun on 01/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 기준이 width인 375인 아이폰 8의 비율에 맞게 변환해주는 함수
func sizeByDevice(size: CGFloat) -> CGFloat {
  let width = UIScreen.main.bounds.width
  
  return size / 375 * width
}
