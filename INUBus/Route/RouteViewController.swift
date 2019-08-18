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
  @IBOutlet weak var tableView: UITableView!
  
  var busNo: String?
  
  var route: Route?
  
  var busStops = [String]()
  
  let url = Server.address.rawValue + "nodeData/"
  
  let cellIdentifier = "RouteTableViewCell"
  
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
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    
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
          
          self.route = route
          self.busStops = route.nodeList
          
          if let index = route.nodeList.firstIndex(of: route.turnNode) {
            self.busStops.insert("", at: index + 1)
          }
          
          DispatchQueue.main.async {
            self.firstBusTimeLabel.text = self.changeTimeIntToString(time: route.start)
            self.lastBusTimeLabel.text = self.changeTimeIntToString(time: route.end)
            self.tableView.reloadData()
          }
          
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

extension RouteViewController: TableViewUpDelegate {
  func scrollToTableViewTop() {
    let indexPath = IndexPath(row: 0, section: 0)
    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
  }
}

extension RouteViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.row != busStops.count ? 61 : 173
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

extension RouteViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return busStops.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: cellIdentifier, for: indexPath
      ) as? RouteTableViewCell else {
        return UITableViewCell()
    }
    
    cell.delegate = self
    
    if indexPath.row == busStops.count {
      cell.upLineView.isHidden = true
      cell.downLineView.isHidden = true
      cell.directionImageView.isHidden = true
      cell.upButton.isHidden = false
      cell.isUserInteractionEnabled = true
      return cell
    }
    
    let busStop = busStops[indexPath.row]
    cell.busStopLabel.text = busStop
    
    if indexPath.row == 0 {
      cell.upLineView.isHidden = true
    } else if busStop == "" {
      cell.turnView.isHidden = false
    } else if busStops.count == indexPath.row + 1 {
      cell.downLineView.isHidden = true
    }
    
    return cell
  }
}
