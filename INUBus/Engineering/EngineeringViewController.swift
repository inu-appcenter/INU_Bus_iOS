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
  
  let message = "INU BUS 는\n하교 시, 버스 시간을 정확히 알 수 없는 인천대학교 학생들을 위한\n버스 앱입니다.\n즐거운 하교길 되세요 :)"
  
  let sections = ["즐겨찾기", "간선버스", "지선버스", "광역버스"]
  
  let url = Server.address.rawValue + "arrivalInfo"
  
  let busStopIdentifier = "engineer"
  
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
    print(Date().millisecondsSince1970)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
}

extension EngineeringViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "MainTableViewCell")
    
    UIAlertController
      .alert(title: nil, message: message)
      .setMessage(start: 0,
                  end: message.count,
                  font: UIFont(name: "NotoSans-Medium", size: 13),
                  color: .black)
      .setMessage(start: 0,
                  end: 7,
                  font: UIFont(name: "Jalnan", size: 13),
                  color: UIColor(red: 0/255, green: 97/255, blue: 244/255, alpha: 1))
      .action(title: "확인했습니다", style: .default, completion: nil)
      .present(to: self)
  }
  
  func request() {
    guard let url = URL(string: url) else {
      return
    }
    
    NetworkManager.shared.request(url: url, method: .get) { data, error in
      if let error = error {
        print(error.localizedDescription)
      }
      
      if let data = data {
        do {
          let busStops = try JSONDecoder().decode([BusStop].self, from: data)
          for busStop in busStops {
            if busStop.name == self.busStopIdentifier {
              self.busInfos = busStop.data
              self.sortBusInfos()
              DispatchQueue.main.async {
                self.tableView.reloadData()
              }
              break
            }
          }
        } catch {
          print(error.localizedDescription)
        }
      }
    }
  }
  
  func sortBusInfos() {
    sortedBuses = [[], [], [], []]
    for busInfo in busInfos {
      if busInfo.type == "간선" || busInfo.type == "간선급행" {
        sortedBuses[1].append(busInfo)
      } else if busInfo.type == "순환" {
        sortedBuses[2].append(busInfo)
      }
    }
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
    
    let label1 = UILabel()
    label1.text = sections[section]
    label1.font = UIFont(name: "NotoSans-Regular", size: 12)
    label1.textColor = UIColor(white: 112/255, alpha: 1)
    label1.frame = CGRect(x: sizeByDevice(size: 28), y: 0, width: 50, height: 20)
    view.addSubview(label1)
    
    let label2 = UILabel()
    label2.text = "남은시간"
    label2.font = UIFont(name: "NotoSans-Regular", size: 12)
    label2.textColor = UIColor(white: 112/255, alpha: 1)
    label2.frame = CGRect(x: sizeByDevice(size: 182), y: 0, width: 50, height: 20)
    view.addSubview(label2)
    
    let label3 = UILabel()
    label3.text = "배차간격"
    label3.font = UIFont(name: "NotoSans-Regular", size: 12)
    label3.textColor = UIColor(white: 112/255, alpha: 1)
    label3.frame = CGRect(x: sizeByDevice(size: 288), y: 0, width: 50, height: 20)
    view.addSubview(label3)
    
    return view
  }
}

extension EngineeringViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sortedBuses[section].count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "MainTableViewCell", for: indexPath
      ) as? MainTableViewCell else {
      return UITableViewCell()
    }
    
    cell.busInfo = sortedBuses[indexPath.section][indexPath.row]
    
    return cell
  }
  
}
