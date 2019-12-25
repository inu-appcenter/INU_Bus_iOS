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
  
  // 서버에서 받아온 millisecond에서 지금 시간을 빼서 초로 환산하는 변수.
  // 서버에서 arrival 시간이 갱신이 안될 수도 있어서 음수 값이 나올 수 있음.
  var second: Int {
    let millisecond = arrival - Date().millisecondsSince1970
    return Int(round(Double(millisecond) / 1000))
  }
  
  // second가 음수 값이 될 수도 있으므로 interval 시간을 더해서 양수로 만듬.
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
  
  var isRunning: Bool {
    let hour = Calendar.current.component(.hour, from: Date())
    let currentTime = Calendar.current.component(.minute, from: Date()) + hour * 100
    
    if currentTime > end {
      return false
    } else {
      return currentTime < start ? false : true
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
}

struct Inquiry: Codable {
  let title: String
  let message: String
  let device: String
  let version: String
  let contact: String
}

struct GPS: Codable {
  let routeID: String
  let status: Int
  let location: Int
  let lat: Double
  let lng: Double
  
  var commuteBusType: CommuteBusType {
    switch routeID {
    case "송내":
      return .songnae
    case "수원":
      return .suwon
    case "일산":
      return .ilsan
    case "청라":
      return .cheongna
    default:
      return .gwangmyeong
    }
  }
  
  var position: String {
    return commuteBusType.busStopList[location]
  }
  
  enum CodingKeys: String, CodingKey {
    case status, location, lat, lng
    case routeID = "routeId"
  }
}

// Set Collection을 사용하기 위해 Hashable 적용
// struct를 UserDefaults로 사용하기 위해 Codable 적용
struct RGB: Hashable, Codable {
  let red: Float
  let green: Float
  let blue: Float
}

struct Search: Hashable, Codable {
  enum SearchType: String, Codable {
    case bus
    case station
  }
  
  let type: SearchType
  let name: String
  let detail: String
  var date: String
  let rgb: RGB
}
