//
//  Objects.swift
//  INUBus
//
//  Created by zun on 04/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

struct BusInfo: Codable {
  let no: String
  let arrival: Int64
  let start: Int
  let end: Int
  let interval: Int
  let type: String
  
  // 서버에서 받아온 millisecond에서 지금 시간을 빼서 초로 환산하는 변수
  var second: Int {
    let millisecond = arrival - Date().millisecondsSince1970
    return Int(round(Double(millisecond) / 1000))
  }
}

struct BusStop: Codable {
  let name: String
  let data: [BusInfo]
}
