//
//  SearchService.swift
//  INUBus
//
//  Created by 임현규 on 15/09/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

class SearchService: SearchServiceType {
  
  var savebusInfo = [String]()
  var savebusNode = [String: String]()
  var savebusNodeArr = [String]()
  
  func requestSearch(url: String, busInfo: inout [String], busNode: inout [String : String],
                     busNodeArr: inout [String]) {
    
    guard let url = URL(string: url) else { return }
    
        NetworkManager.shared.request(url: url, method: .get) { (data, error) in
          if let error = error {
            print(error.localizedDescription)
          }
    
          if let data = data {
            do {
              let busNumbers = try JSONDecoder().decode([Route].self, from: data)
    
              for busNumber in busNumbers {
    
                // 버스 번호 저장
                self.savebusInfo.append(busNumber.no)
                // 버스 정거장과 정거장번호를 딕셔너리 형태로 가져옴
                for nodeInfo in busNumber.nodeList {
    
                  self.savebusNode.updateValue(nodeInfo.nodeName, forKey: "\(nodeInfo.nodeNo)")
                }
              }
    
              // 버스 정거장 값들 저장
              for busNodes in self.savebusNode.values {
                self.savebusNodeArr.append(busNodes)
              }
              
              UserDefaults.standard.set(self.savebusInfo, forKey: "busInfo")
              UserDefaults.standard.set(self.savebusNode, forKey: "busNode")
              UserDefaults.standard.set(self.savebusNodeArr, forKey: "busNodeArr")

            } catch {
              print(error.localizedDescription)
            }
          }
        }
    
    guard let loadBusInfo =
      UserDefaults.standard.object(forKey: "busInfo") as?
        [String] else { return }
    
    busInfo = loadBusInfo
    
    guard let loadBusNode =
      UserDefaults.standard.object(forKey: "busNode") as?
      [String: String] else { return }
    
    busNode = loadBusNode
    
    guard let loadBusNodeArr =
      UserDefaults.standard.object(forKey: "busNodeArr") as?
        [String] else { return }
    
    busNodeArr = loadBusNodeArr
  }
}
