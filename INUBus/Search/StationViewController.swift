//
//  StationViewController.swift
//  INUBus
//
//  Created by zun on 12/12/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// SearchViewController에서 정류장을 눌렀을 때 나올 화면을 구현.
final class StationViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Properties
  
  let arrivalInfoService: ArrivalInfoServiceType = ArrivalInfoService()
  
  /// tableView cell 식별자
  let cellIdentifier = StringConstants.mainTableViewCell.rawValue
  
  /// SearchViewController에서 받아올 버스 정보
  var busInfos = [BusInfo]()
  
  /// tableView에 띄울 Array. busInfos의 정보들이 정렬되어짐.
  var sortedBuses = [BusTypeInfo]()
  
  var timer: Timer!
  
  // MARK: - IBAction
  @IBAction func backButtonDidTap(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startTimer()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer.invalidate()
  }
}

// MARK: - Methods

extension StationViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    tableView.tableFooterView = UIView()
    
    tableViewReloadData()
  }
  
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

extension StationViewController: ReloadDataDelegate {
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

extension StationViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 52
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 20
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor(white: 235/250, alpha: 1)
    
    view.addSubview(sectionLabel(text: sortedBuses[section].busType,
                                 size: widthByDevice(size: 28)))
    view.addSubview(sectionLabel(text: StringConstants.sectionRemaning.rawValue,
                                 size: widthByDevice(size: 182)))
    view.addSubview(sectionLabel(text: StringConstants.sectionInterval.rawValue,
                                 size: widthByDevice(size: 288)))
    
    return view
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    
    let viewController = UIViewController
      .instantiate(storyboard: StringConstants.route.rawValue,
                   identifier: StringConstants.routeViewController.rawValue)
    if let routeViewController = viewController as? RouteViewController {
      let busInfo = sortedBuses[indexPath.section].busInfos[indexPath.row]
      routeViewController.busNo = busInfo.no
      routeViewController.busColor = busInfo.busColor
      routeViewController.push(at: self)
    }
  }
}

// MARK: - UITableViewDataSource

extension StationViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return sortedBuses.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sortedBuses[section].busInfos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
      as? MainTableViewCell
      else {
        errorLog("Cell 에러")
        return UITableViewCell()
    }
    
    cell.delegate = self
    cell.busInfo = sortedBuses[indexPath.section].busInfos[indexPath.row]
    
    return cell
  }
}
