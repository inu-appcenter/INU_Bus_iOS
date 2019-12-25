//
//  RouteViewController.swift
//  INUBus
//
//  Created by zun on 12/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var busNoLabel: UILabel!
  @IBOutlet weak var firstBusTimeLabel: UILabel!
  @IBOutlet weak var lastBusTimeLabel: UILabel!
  @IBOutlet weak var busFareLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Properties
  
  /// 상위 viewController에서 받아올 버스 번호
  var busNo: String?
  
  /// 버스의 색깔
  var busColor: BusColor?
  
  /// tableView에 표시될 정보를 담을 배열
  var busStops = [String]()
  
  /// 정보를 요청할 서버 URL
  let url = Server.address.rawValue + StringConstants.nodeData.rawValue
  
  /// tableView에 쓰일 Cell 식별자
  let cellIdentifier = StringConstants.routeTableViewCell.rawValue
  
  // MARK: - IBAction
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    self.navigationController?.navigationBar.barTintColor = .white
    changeStatusBarColor(barStyle: .default)
//    tabBarController?.tabBar.isHidden = false
    self.navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    request()
  }
}

// MARK: - Methods

extension RouteViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    
    navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 97, blue: 244)
    
    changeStatusBarColor(barStyle: .lightContent)
    busNoLabel.text = busNo
    busNoLabel.sizeToFit()
    
    updateBusFare()
    
    tabBarController?.tabBar.isHidden = true
  }
  
  func request() {
    guard let busNo = busNo, let url = URL(string: url + "/\(busNo)") else {
      errorLog("버스 번호, URL 에러")
      return
    }
    
    NetworkManager.shared.get(url: url) { data, error in
      if let error = error {
        errorLog("네트워크 에러: \(error.localizedDescription)")
        DispatchQueue.main.async {
          showErrorAlertController(viewController: self)
        }
      }
      
      if let data = data {
        do {
          let route = try JSONDecoder().decode(Route.self, from: data)
          
          for node in route.nodeList {
            self.busStops.append(node.nodeName)
          }
          
          // 중간에 회차지 부분을 표시하기 위해 회차지를 찾고 "" 라는 원소를 넣어줌
          if let index = self.busStops.firstIndex(of: route.turnNode) {
            self.busStops.insert("", at: index + 1)
          }
          
          DispatchQueue.main.async {
            self.firstBusTimeLabel.text = self.changeTimeIntToString(time: route.start)
            self.lastBusTimeLabel.text = self.changeTimeIntToString(time: route.end)
            self.tableView.reloadData()
          }
        } catch {
          errorLog("JSON 포맷 에러: \(error.localizedDescription)")
        }
      }
    }
  }
  
  /// 출발시간, 도착시간을 hh:mm으로 바꿔주는 함수.
  func changeTimeIntToString(time: Int) -> String {
    let hour = time > 1000 ? "\(time / 100)" : "0\(time / 100)"
    let minTemp = time % 100
    let min = minTemp > 10 ? "\(minTemp)" : "0\(minTemp)"
    return hour + ":" + min
  }
  
  func updateBusFare() {
    if let busColor = busColor {
      switch busColor {
      case .blue, .purple:
        busFareLabel.text = "1,250"
      case .green:
        busFareLabel.text = "950"
      case .orange:
        if let busNo = busNo, busNo == "3002" {
          busFareLabel.text = "2,400"
        } else {
          busFareLabel.text = "2,600"
        }
      }
    }
  }
}

// MARK: - TableViewUpDelegate

extension RouteViewController: TableViewUpDelegate {
  /// cell에서 버튼을 눌렀을 때 위로 tableView를 맨위로 올리기 위한 함수
  func scrollToTableViewTop() {
    let indexPath = IndexPath(row: 0, section: 0)
    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
  }
}

// MARK: - UITableViewDelegate

extension RouteViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // 마지막 상단위로 올리는 셀 크기만 173, 나머지 셀 크기는 61
    return indexPath.row != busStops.count ? 61 : 173
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

// MARK: - UITableViewDataSource

extension RouteViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // 중간에 회차지 셀을 추가하기 위해 +1을 함
    return busStops.count == 0 ? 0 : busStops.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: cellIdentifier, for: indexPath
      ) as? RouteTableViewCell else {
        return UITableViewCell()
    }
    
    cell.delegate = self
    
    // 마지막 상단위로 올리는 버튼이 있는 셀
    if indexPath.row == busStops.count {
      cell.busStopLabel.text = ""
      cell.upLineView.isHidden = true
      cell.downLineView.isHidden = true
      cell.directionImageView.isHidden = true
      cell.upButton.isHidden = false
      cell.isUserInteractionEnabled = true
      return cell
    }
    
    // 나머지 셀 작업들
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
