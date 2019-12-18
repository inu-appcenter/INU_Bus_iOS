//
//  StationViewController.swift
//  INUBus
//
//  Created by zun on 12/12/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class StationViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  let cellIdentifier = StringConstants.mainTableViewCell.rawValue
  
  var busInfos = [BusInfo]()
  
  var timer: Timer!
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  
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

extension StationViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    tableView.tableFooterView = UIView()
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

extension StationViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 52
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

extension StationViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return busInfos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
      as? MainTableViewCell
      else {
        errorLog("Cell 에러")
        return UITableViewCell()
    }
    
    cell.favoritesButton.isHidden = true
    cell.busInfo = busInfos[indexPath.row]
    
    return cell
  }
}
