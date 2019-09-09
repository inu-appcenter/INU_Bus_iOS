//
//  ArrivalInfoServiceType.swift
//  INUBus
//
//  Created by zun on 08/09/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

protocol ArrivalInfoServiceType: class {
  /// 특정 정류장의 버스 도착 예정 시간을 서버에 요청하는 함수.
  func requestArrivalInfo(url: String,
                          identifier: String,
                          completion: @escaping ([BusInfo]?, [BusTypeInfo]?) -> Void)
  
  /// 구한 버스 도착 예정 시간을 TableView에 나타내주기 위해 정렬 시켜주는 함수.
  func sortArrivalInfos(busInfos: [BusInfo],
                        identifier: String,
                        completion: @escaping ([BusTypeInfo]?) -> Void)
}
