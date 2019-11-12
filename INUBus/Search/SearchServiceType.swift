//
//  SearchServiceType.swift
//  INUBus
//
//  Created by 임현규 on 15/09/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

protocol SearchServiceType: class {
  
  func requestSearch(url: String, busInfo: inout [String], busNode: inout [String: String], busNodeArr: inout [String])
  
  func infoCell(arr: [String], indexPath: IndexPath, node: [String], day: [String], hidden: Bool)
  
  func shortSearchList( busInfo: inout [String], busNodeArr: inout [String],
                        busNode: inout [String : String], nodeNumList: inout  [String],
                        searchList: inout [String], dayList: inout [String], word: String)
}
