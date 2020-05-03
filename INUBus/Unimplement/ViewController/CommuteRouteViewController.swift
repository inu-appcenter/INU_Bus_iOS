//
//  CommuteRouteViewController.swift
//  INUBus
//
//  Created by zun on 09/10/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 미구현.
class CommuteRouteViewController: UIViewController {
  
  @IBOutlet weak var busTypeLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var gpsInfo: GPS?
  
  let cellIdentifier = "RouteTableViewCell"
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    self.navigationController?.navigationBar.barTintColor = .white
    changeStatusBarColor(barStyle: .default)
    self.navigationController?.popViewController(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }
}

// MARK: - Methods

extension CommuteRouteViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 97, blue: 244)
    changeStatusBarColor(barStyle: .lightContent)
    
    departureTimeLabel.text = gpsInfo?.commuteBusType.departureTime
    arrivalTimeLabel.text = gpsInfo?.commuteBusType.arrivalTime
    busTypeLabel.text = gpsInfo?.routeID
    busTypeLabel.sizeToFit()
    
  }
}

// MARK: - TableViewUpDelegate

extension CommuteRouteViewController: TableViewUpDelegate {
  func scrollToTableViewTop() {
    let indexPath = IndexPath(row: 0, section: 0)
    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
  }
}

// MARK: - TableViewDelegate

extension CommuteRouteViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let gpsInfo = gpsInfo {
      return indexPath.row != gpsInfo.commuteBusType.busStopList.count ? 61 : 173
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

// MARK: - TableViewDataSource

extension CommuteRouteViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (gpsInfo?.commuteBusType.busStopList.count ?? 0) + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
      as? RouteTableViewCell else {
      return UITableViewCell()
    }
    
    guard let gpsInfo = gpsInfo else {
      errorLog("gpsInfo optional 에러")
      return cell
    }
    
    cell.delegate = self
    
    if indexPath.row == gpsInfo.commuteBusType.busStopList.count {
      cell.busStopLabel.text = ""
      cell.upLineView.isHidden = true
      cell.downLineView.isHidden = true
      cell.directionImageView.isHidden = true
      cell.upButton.isHidden = false
      cell.isUserInteractionEnabled = true
      return cell
    }
    
    cell.busStopLabel.text = gpsInfo.commuteBusType.detailBusStopList[indexPath.row]
    
    if indexPath.row == 0 {
      cell.upLineView.isHidden = true
    } else if gpsInfo.commuteBusType.busStopList.count == indexPath.row + 1 {
      cell.downLineView.isHidden = true
    }
    
    return cell
  }
}
