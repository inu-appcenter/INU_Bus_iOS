//
//  RouteViewController.swift
//  INUBus
//
//  Created by zun on 12/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {
  
  @IBOutlet weak var busNoLabel: UILabel!
  @IBOutlet weak var firstBusTimeLabel: UILabel!
  @IBOutlet weak var lastBusTimeLabel: UILabel!
  
  var busNo: String?
  
  var route: Route?
  
  let url = Server.address.rawValue + "nodeData/"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
    request()
  }
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    self.navigationController?.navigationBar.barTintColor = .white
    changeStatusBarColor(barStyle: .default)
    self.navigationController?.popViewController(animated: true)
  }
  
}

extension RouteViewController {
  func setUp() {
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255,
                                                                    green: 97/255,
                                                                    blue: 244/255,
                                                                    alpha: 1)
    changeStatusBarColor(barStyle: .lightContent)
    busNoLabel.text = busNo
  }
  
  func request() {
    guard let busNo = busNo, let url = URL(string: url + busNo) else { return }
    
    NetworkManager.shared.request(url: url, method: .get) { data, error in
      if let error = error {
        print(error.localizedDescription)
      }
      
      if let data = data {
        do {
          let route = try JSONDecoder().decode(Route.self, from: data)
          
          DispatchQueue.main.async {
            self.firstBusTimeLabel.text = self.changeTimeIntToString(time: route.start)
            self.lastBusTimeLabel.text = self.changeTimeIntToString(time: route.end)
          }
          
          self.route = route
          
        } catch {
          print(error.localizedDescription)
        }
        
      }
    }
  }
  
  func changeTimeIntToString(time: Int) -> String {
    let hour = time > 1000 ? "\(time / 100)" : "0\(time / 100)"
    let minTemp = time % 100
    let min = minTemp > 10 ? "\(minTemp)" : "0\(minTemp)"
    
    return hour + ":" + min
  }
}
