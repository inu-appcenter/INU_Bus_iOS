//
//  ArrivalInfoService.swift
//  INUBus
//
//  Created by zun on 08/09/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

class ArrivalInfoService: ArrivalInfoServiceType {
  
  func requestArrivalInfo(url: String,
                          identifier: String,
                          completion: @escaping ([BusInfo]?, [BusTypeInfo]?) -> Void) {
    guard let url = URL(string: url) else {
      errorLog("URL error")
      return
    }
    
    NetworkManager.shared.request(url: url, method: .get) { data, error in
      if let error = error {
        print(error.localizedDescription)
      }
      
      if let data = data {
        do {
          let busStops = try JSONDecoder().decode([BusStop].self, from: data)
          var busTypeInfos: [BusTypeInfo]?
          
          for busStop in busStops where busStop.name == identifier {
            let busStopData = busStop.data
            self.sortArrivalInfos(busInfos: busStopData) {
              busTypeInfos = $0
            }
            completion(busStopData, busTypeInfos)
          }
        } catch {
          print(error.localizedDescription)
          completion(nil, nil)
        }
      }
      ProgressIndicator.shared.hide()
    }
  }
  
  func sortArrivalInfos(busInfos: [BusInfo], completion: @escaping ([BusTypeInfo]?) -> Void) {
    var sortedBuses = [BusTypeInfo(busType: "즐겨찾기", busInfos: []),
                       BusTypeInfo(busType: "간선버스", busInfos: []),
                       BusTypeInfo(busType: "지선버스", busInfos: []),
                       BusTypeInfo(busType: "지선버스", busInfos: [])]
    
    guard let favorArray = UserDefaults.standard.value(forKey: "favorArray") as? [String] else {
        errorLog("즐겨찾기 불러오기 실패")
        completion(nil)
        return
    }
    
    for busInfo in busInfos {
      if favorArray.contains(busInfo.no) {
        sortedBuses[0].busInfos.append(busInfo)
        continue
      }
      switch busInfo.busColor {
      case .blue, .purple:
        sortedBuses[1].busInfos.append(busInfo)
      case .green:
        sortedBuses[2].busInfos.append(busInfo)
      case .orange:
        sortedBuses[3].busInfos.append(busInfo)
      }
    }
    
    for index in (0..<sortedBuses.count).reversed() where sortedBuses[index].busInfos.count == 0 {
      sortedBuses.remove(at: index)
    }
    completion(sortedBuses)
  }
}
