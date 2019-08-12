//
//  EngineeringViewController.swift
//  INUBus
//
//  Created by zun on 19/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit
import KYDrawerController

class EngineeringViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchView: RoundUIView!
  
  let sections = ["즐겨찾기", "간선버스", "지선버스", "광역버스"]
  
  let url = Server.address.rawValue + StringConstants.arrivalInfo.rawValue
  
  let busStopIdentifier = StringConstants.engineer.rawValue
  
  let cellIdentifier = StringConstants.mainTableViewCell.rawValue
  
  var busInfos = [BusInfo]()
  
  var sortedBuses = [[BusInfo](), [BusInfo](), [BusInfo](), [BusInfo]()]
  
  @IBAction func infoButtonDidTap() {
    if let drawerController = navigationController?.parent?.parent as?
      KYDrawerController {
      drawerController.setDrawerState(.opened, animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
    request()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
}

extension EngineeringViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    // tableView 비어있는 cell 지우기
    tableView.tableFooterView = UIView()
    
    showNoticeAlertController(viewController: self)
    
    let tapRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(pushViewController(gestureRecognizer:)))
    searchView.addGestureRecognizer(tapRecognizer)
  }
  
  /// 서버에 데이터를 요청하는 함수.
  func request() {
    guard let url = URL(string: url) else { return }
    
    NetworkManager.shared.request(url: url, method: .get) { data, error in
      if let error = error {
        print(error.localizedDescription)
      }
      
      if let data = data {
        do {
          let busStops = try JSONDecoder().decode([BusStop].self, from: data)
          
          for busStop in busStops where busStop.name == self.busStopIdentifier {
            self.busInfos = busStop.data
            self.sortBusInfos()
            DispatchQueue.main.async {
              self.tableView.reloadData()
            }
          }
        } catch {
          print(error.localizedDescription)
        }
      }
    }
  }
  
  // 서버에서 받은 버스 정보를 각 section에 정렬시켜주는 함수.
  func sortBusInfos() {
    sortedBuses = [[], [], [], []]
    
    var favorArray = [String]()
    if let array = UserDefaults.standard.value(forKey: StringConstants.favorArray.rawValue)
      as? [String] {
      favorArray = array
    }
    
    for busInfo in busInfos {
      if favorArray.contains(busInfo.no) {
        sortedBuses[0].append(busInfo)
      } else if busInfo.type == "간선" || busInfo.type == "간선급행" {
        sortedBuses[1].append(busInfo)
      } else if busInfo.type == "순환" {
        sortedBuses[2].append(busInfo)
      }
    }
  }
  
  @objc func pushViewController(gestureRecognizer: UITapGestureRecognizer) {
    let viewController = UIStoryboard(name: "Search", bundle: nil)
      .instantiateViewController(withIdentifier: "SearchViewController")
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}

extension EngineeringViewController: ReloadDataDelegate {
  func tableViewReloadData() {
    sortBusInfos()
    tableView.reloadData()
  }
}

extension EngineeringViewController: UITableViewDelegate {
  // cell의 높이
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 52
  }
  
  // section header의 높이
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 20
  }
  
  // section label 설정
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor(white: 235/250, alpha: 1)
    
    view.addSubview(sectionLabel(text: sections[section],
                                 size: sizeByDevice(size: 28)))
    view.addSubview(sectionLabel(text: "남은시간", size: sizeByDevice(size: 182)))
    view.addSubview(sectionLabel(text: "배차간격", size: sizeByDevice(size: 288)))
    
    return view
  }
  
  // cell이 선택됐을때 highlight 해제
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    
    let viewController = UIStoryboard(name: "Route", bundle: nil)
      .instantiateViewController(withIdentifier: "RouteViewController")
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}

extension EngineeringViewController: UITableViewDataSource {
  // section의 개수
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  // 각 section안에 들어갈 cell의 개수
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sortedBuses[section].count
  }
  
  // cell 커스터마이징
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: cellIdentifier, for: indexPath
      ) as? MainTableViewCell else {
      return UITableViewCell()
    }
    
    cell.delegate = self
    cell.busInfo = sortedBuses[indexPath.section][indexPath.row]
    
    return cell
  }
  
}
