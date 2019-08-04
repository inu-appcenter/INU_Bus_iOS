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
  let arrival: Int
  let start: Int
  let end: Int
  let interval: Int
  let type: String
}

struct BusStop: Codable {
  let name: String
  let data: [BusInfo]
}
