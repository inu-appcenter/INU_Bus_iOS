//
//  SearchService.swift
//  INUBus
//
//  Created by zun on 13/11/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

class SearchService: SearchServiceType {

  func shortSearchList(busInfo: inout [String], busNodeArr: inout [String],
                        busNode: inout [String : String], nodeNumList: inout  [String],
                        searchList: inout [String], dayList: inout [String], word: String) {

    searchList = []
    nodeNumList = []

    var temp = 0
    var tempArr = [String]()

    // 년. 월. 일로 나타내주는 프로퍼티.
    let dateFormatter: DateFormatter = {
      let formatter: DateFormatter = DateFormatter()
      formatter.dateFormat = "yyyy.MM.dd"
      return formatter
    }()

    let date: Date = Date()


    // 사용자가 검색한 값이 서버로 받아온 버스번호에 포함되면 표시
    for busNumber in busInfo {
      if busNumber.contains(word) {
        searchList.insert(busNumber, at: 0)
        nodeNumList.insert("\(busNumber)@", at: 0)
      }
    }

    // 사용자가 검색한 값이 서버로 받아온 버스정거장에 포함되면 표시
    for busStops in busNodeArr {
      if busStops.contains(word) {
        // value(정거장)값과 사용자가 검색한 값이 같으면
        for(key, value) in busNode where value == busStops {
          // 해당 value의 key(정거장번호)와 value를 저장
          // 각각 다른 배열이지만 정거장과 번호가 배열 순서가 같게 됨
          nodeNumList.append(key)
          searchList.append(value)

        }
      }
    }

    // 검색 결과에 정거장 번호가 겹치는 정거장들을 제거하는 위함
    for checkStops in nodeNumList {
      temp += 1
      for num in temp..<(nodeNumList.count) where checkStops == nodeNumList[num] {
        nodeNumList.remove(at: num)
        // 임의의 값을 저장함(이후에 "!"를 이용해 겹치는 값들 삭제)
        // 그냥 .remove만 해버리면 배열의 index가 꼬임
        nodeNumList.insert("\(temp)!", at: num)
        searchList.remove(at: num)
        searchList.insert("\(temp)!", at: num)
      }
    }

    // "!"를 이용해 정거장 번호가 겹치는 정거장 제거
    // "!"가 있는 원소들만 추춣하여 배열의 맨앞으로 보냄
    for num in 0..<(nodeNumList.count) where nodeNumList[num].contains("!") {
      nodeNumList.insert(nodeNumList[num], at: 0)
      // tempArr를 만들어 "!"원소들을 저장
      tempArr.insert(nodeNumList[num+1], at: 0)
      // z맨앞으로 보내진 원소들은 제거
      nodeNumList.remove(at: num+1)
    }

    for num in 0..<(searchList.count) where searchList[num].contains("!")   {
      searchList.insert(searchList[num], at: 0)
      searchList.remove(at: num+1)
    }

    // tempArr의 개수 만큼 "!"원소들 제거
    for _ in 0..<(tempArr.count) {
      nodeNumList.remove(at: 0)
      searchList.remove(at: 0)
    }

//     SearchList의 개수만큼 daylist를 생성
    for _ in 0..<(searchList.count) {
      dayList.append(dateFormatter.string(from: date))
    }
  }




  func infoCell(arr: [String], indexPath: IndexPath, node: [String], day: [String], hidden: Bool) {

    let cell = SearchTableViewCell()

    cell.searchLabel.text = arr[indexPath.row]
    cell.moreInfo.text = "정류장 번호: " + node[indexPath.row]
    cell.dateLabel.text = day[indexPath.row]
    cell.deleteButton.isHidden = hidden
  }

  var savebusInfo = [String]()
  var savebusNode = [String: String]()
  var savebusNodeArr = [String]()

  func requestSearch(url: String, busInfo: inout [String], busNode: inout [String : String],
                     busNodeArr: inout [String]) {

    guard let url = URL(string: url) else { return }

        NetworkManager.shared.tempRequest(url: url, method: .get) { (data, error) in
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

    // 뒤에 UserDefaults지워주는게 날듯
    
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
