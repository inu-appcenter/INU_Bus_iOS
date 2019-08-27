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
  
  var estimatedArrivalTime: Int {
    var value = second
    while value < 0 {
      value += interval * 60
    }
    return value
  }
  
  var busColor: BusColor {
    switch type {
    case "간선급행":
      return .purple
    case "순환":
      return .green
    case "광역":
      return .orange
    default:
      return .blue
    }
  }
  
  var rgb: (Float, Float, Float) {
    switch busColor {
    case .blue:
      return (0, 39, 244)
    case .purple:
      return (105, 0, 181)
    case .green:
      return (36, 195, 48)
    case .orange:
      return (255, 73, 7)
    }
  }
}

struct BusStop: Codable {
  let name: String
  let data: [BusInfo]
}

struct Route: Codable {
  struct Node: Codable {
    let nodeNo: Int
    let nodeName: String
    
    enum CodingKeys: String, CodingKey {
      case nodeNo = "nodeno"
      case nodeName = "nodenm"
    }
  }
  
  let no: String
  let routeID: String
  let nodeList: [Node]
  let turnNode: String
  let start: Int
  let end: Int
  let type: String
  
  enum CodingKeys: String, CodingKey {
    case no, start, end, type
    case routeID = "routeid"
    case nodeList = "nodelist"
    case turnNode = "turnnode"
  }
  
  var busColor: BusColor {
    switch type {
    case "간선급행":
      return .purple
    case "순환":
      return .green
    case "광역":
      return .orange
    default:
      return .blue
    }
  }
  
  var rgb: (Float, Float, Float) {
    switch busColor {
    case .blue:
      return (0, 39, 244)
    case .purple:
      return (105, 0, 181)
    case .green:
      return (36, 195, 48)
    case .orange:
      return (255, 73, 7)
    }
  }
}
