//
//  NetworkManager.swift
//  INUBus
//
//  Created by zun on 04/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

final class NetworkManager {
  static let shared = NetworkManager()
  
  private init() { }
  
  func request(url: URL,
               method: HTTPMethod,
               completion: @escaping (Data?, Error?) -> Void) {
    let session = URLSession(configuration: .default)
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue
    
    let task = session.dataTask(with: urlRequest) { data, response, error in
      completion(data, error)
      session.finishTasksAndInvalidate()
    }
    task.resume()
  }
}
