//
//  Log.swift
//  INUBus
//
//  Created by zun on 09/09/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

func errorLog(_ message: Any,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
  let fileName = file.split(separator: "/").last ?? ""
  let functionName = function.split(separator: "(").first ?? ""
  print("❌[\(fileName)]\(functionName)(\(line)):\(message)")
}
