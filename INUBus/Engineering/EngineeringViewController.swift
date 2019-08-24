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
  @IBOutlet weak var searchImageView: UIImageView!
  @IBOutlet weak var refreshButton: UIButton!
  
  let url = Server.address.rawValue + StringConstants.arrivalInfo.rawValue
  
  let busStopIdentifier = StringConstants.engineer.rawValue
  
  let cellIdentifier = StringConstants.mainTableViewCell.rawValue
  
  var busInfos = [BusInfo]()
  
  var sortedBuses: [BusTypeInfo] = []
  
  @IBAction func infoButtonDidTap() {
    if let drawerController = navigationController?.parent?.parent as?
      KYDrawerController {
      drawerController.setDrawerState(.opened, animated: true)
    }
  }
  
  @IBAction func refreshButtonDidTap(_ sender: Any) {
    request()
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
    
    // 공지사항 띄우기
    showNoticeAlertController(viewController: self)
    
    // 검색 바를 기기에 맞게 사이즈 조절하기
    searchView.frame.size.width = sizeByDevice(size: 205)
    searchImageView.frame = CGRect(x: searchView.frame.width - 35,
                                   y: 9,
                                   width: 16,
                                   height: 16)
    
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
      ProgressIndicator.shared.hide()
    }
  }
  
  // 서버에서 받은 버스 정보를 각 section에 정렬시켜주는 함수.
  func sortBusInfos() {
    sortedBuses = [BusTypeInfo(busType: "즐겨찾기", busInfos: []),
                   BusTypeInfo(busType: "간선버스", busInfos: []),
                   BusTypeInfo(busType: "지선버스", busInfos: []),
                   BusTypeInfo(busType: "지선버스", busInfos: [])]
    
    var favorArray = [String]()
    if let array = UserDefaults.standard.value(forKey: StringConstants.favorArray.rawValue)
      as? [String] {
      favorArray = array
    }
    
    for busInfo in busInfos {
      if favorArray.contains(busInfo.no) {
        sortedBuses[0].busInfos.append(busInfo)
        continue
      }
      switch busInfo.busColor {
      case .blue, .purple:
        sortedBuses[1].busInfos.append(busInfo)
      case .green:
        sortedBuses[2].busInfos.append(busInfo)
      case .orange:
        sortedBuses[3].busInfos.append(busInfo)
      }
    }
    
    for index in (0..<sortedBuses.count).reversed() where sortedBuses[index].busInfos.count == 0 {
      sortedBuses.remove(at: index)
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
    
    view.addSubview(sectionLabel(text: sortedBuses[section].busType,
                                 size: sizeByDevice(size: 28)))
    view.addSubview(sectionLabel(text: "남은시간", size: sizeByDevice(size: 182)))
    view.addSubview(sectionLabel(text: "배차간격", size: sizeByDevice(size: 288)))
    
    return view
  }
  
  // cell이 선택됐을때 highlight 해제 및 노선 view controller로 이동
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    
    let viewController = UIStoryboard(name: "Route", bundle: nil)
      .instantiateViewController(withIdentifier: "RouteViewController")
    if let routeViewController = viewController as? RouteViewController {
      routeViewController.busNo = sortedBuses[indexPath.section].busInfos[indexPath.row].no
      self.navigationController?.pushViewController(viewController, animated: true)
    }
  }
  
  // tableView가 스크롤 할 때 버튼을 사라지게 하기 위한 애니메이션 설정
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    UIView.animate(withDuration: 0.5) {
      self.refreshButton.alpha = 0
    }
  }
  
  // tableView가 스크롤이 끝날 때 버튼을 보이게 하기 위한 애니메이션 설정
  func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    UIView.animate(withDuration: 0.5) {
      self.refreshButton.alpha = 1
    }
  }
}

extension EngineeringViewController: UITableViewDataSource {
  // section의 개수
  func numberOfSections(in tableView: UITableView) -> Int {
    return sortedBuses.count
  }
  
  // 각 section안에 들어갈 cell의 개수
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sortedBuses[section].busInfos.count
  }
  
  // cell 커스터마이징
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: cellIdentifier, for: indexPath
      ) as? MainTableViewCell else {
      return UITableViewCell()
    }
    
    cell.delegate = self
    cell.busInfo = sortedBuses[indexPath.section].busInfos[indexPath.row]
    
    return cell
  }
}
