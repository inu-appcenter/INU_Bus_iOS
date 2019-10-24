//
//  MainViewController.swift
//  INUBus
//
//  Created by zun on 30/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit
import KYDrawerController

/// Main에 나올 ViewController들의 베이스가 되는 ViewController
class MainViewController: UIViewController {
  
  // MARK: - IBOutlets

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchView: RoundUIView!
  @IBOutlet weak var searchImageView: UIImageView!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var infoButton: UIButton!
  
  // MARK: - Must Override Properties
  // 상속하는 하위 클래스들은 무조건 오버라이드를 해야함.
  
  /// 버스 정류장 식별자
  var busStopIdentifier: String {
    return ""
  }
  
  /// Tab Bar에 들어갈 위치 인덱스
  var tabBarIndex: Int {
    return -1
  }
  
  // MARK: - Properties
  
  let arrivalInfoService: ArrivalInfoServiceType = ArrivalInfoService()
  
  /// 정보를 요청할 서버 URL
  let url = Server.address.rawValue + StringConstants.arrivalInfo.rawValue
  
  /// TableView에 쓰일 Cell 식별자
  let cellIdentifier = StringConstants.mainTableViewCell.rawValue
  
  /// 서버에서 받아오는 JSON 형태
  var busInfos = [BusInfo]()
  
  /// TableView에 띄울 Array. busInfos의 정보들이 정렬되어짐.
  var sortedBuses = [BusTypeInfo]()
  
  var timer: Timer!
  
  // MARK: - IBAtions
  
  @IBAction func infoButtonDidTap() {
    if let drawerController = navigationController?.parent?.parent as?
      KYDrawerController {
      drawerController.setDrawerState(.opened, animated: true)
    }
  }
  
  @IBAction func refreshButtonDidTap(_ sender: Any) {
    request()
  }
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
    request()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    request()
  }
}

// MARK: - Methods

extension MainViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    // tableView 비어있는 cell 지우기
    tableView.tableFooterView = UIView()
    
    // 검색 바를 기기에 맞게 사이즈 조절하기
    searchView.frame.size.width = sizeByDevice(size: 205)
    searchImageView.frame = CGRect(x: searchView.frame.width - 35,
                                   y: 9,
                                   width: 16,
                                   height: 16)
    // searchView를 눌렀을 때 searchViewController로 가게끔 함.
    let tapRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(pushViewController(gestureRecognizer:)))
    searchView.addGestureRecognizer(tapRecognizer)
    
    // tabBar의 seletion indicator를 만들기 위한 코드.
    self.tabBarController?.tabBar.items?[tabBarIndex].image = UIImage()
    self.tabBarController?.tabBar.items?[tabBarIndex].selectedImage = UIImage
      .circle(diameter: 5,
              color: UIColor(red: 0, green: 97, blue: 244))
    
    // info 버튼 그림자 설정
    infoButton.layer.applyShadow()
    
    startTimer()
  }
  
  /// 서버에 데이터를 요청하는 함수.
  func request() {
    arrivalInfoService.requestArrivalInfo(url: url, identifier: busStopIdentifier) {
      if let busInfos = $0, let busTypeInfo = $1 {
        self.busInfos = busInfos
        self.sortedBuses = busTypeInfo
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
  }
  
  @objc func pushViewController(gestureRecognizer: UITapGestureRecognizer) {
    UIViewController
      .instantiate(storyboard: "Search", identifier: "SearchViewController")
      .push(at: self, animated: false)
  }
  
  // 매초 1초씩 tableView를 업데이트 함으로써 1초씩 감소하는 효과를 봄.
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1,
                                 target: self,
                                 selector: #selector(countDown),
                                 userInfo: nil,
                                 repeats: true)
  }
  
  @objc func countDown() {
    tableView.reloadData()
  }
}

// MARK: - ReloadDataDelegate

extension MainViewController: ReloadDataDelegate {
  func tableViewReloadData() {
    arrivalInfoService.sortArrivalInfos(busInfos: busInfos) {
      if let busTypeInfos = $0 {
        self.sortedBuses = busTypeInfos
        self.tableView.reloadData()
      }
    }
  }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
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
    
    if let viewController = UIViewController
      .instantiate(storyboard: "Route",
                   identifier: "RouteViewController") as? RouteViewController {
      viewController.busNo = sortedBuses[indexPath.section].busInfos[indexPath.row].no
      viewController.push(at: self)
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

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
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
        errorLog("TableViewCell error")
        return UITableViewCell()
    }
    
    cell.delegate = self
    cell.busInfo = sortedBuses[indexPath.section].busInfos[indexPath.row]
    
    return cell
  }
}
