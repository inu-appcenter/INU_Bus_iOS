//
//  TestViewController.swift
//  INUBus
//
//  Created by zun on 01/12/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textField: UITextField!
  
  // MARK: - Properties
  
  /// tableView에 쓰일 cell identifier
  let cellIdentifier = StringConstants.searchTableViewCell.rawValue
  
  /// 버스 정류장 정보를 가져올 URL
  let url = Server.address.rawValue + StringConstants.nodeData.rawValue
  
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    return formatter
  }()
  
  var busInfos = [BusInfo]() {
    didSet {
      for busInfo in busInfos {
        let search = Search(type: .bus,
                            name: busInfo.no,
                            detail: busInfo.type,
                            date: dateFormatter.string(from: Date()),
                            rgb: RGB(red: busInfo.rgb.0,
                                     green: busInfo.rgb.1,
                                     blue: busInfo.rgb.2))
        searchingData.insert(search)
      }
    }
  }
  
  /// 중복된 Search값은 없앤 Set
  var searchingData = Set<Search>()
  
  /// tableView에 표시될 Array
  var searchingArray = [Search]()
  
  /// 모든 버스 노선 정보를 담을 Array
  var routeData = [Route]()
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    navigationController?.popViewController(animated: false)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    request()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.isHidden = false
  }
}

extension TestViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    tableView.tableFooterView = UIView()
    
    textField.addTarget(self, action: #selector(searchInData), for: .editingChanged)
    
//    let viewControllerGesture = UITapGestureRecognizer(target: self,
//                                                        action: #selector(tapViewController(_:)))
//    view.addGestureRecognizer(viewControllerGesture)
  }
  
  func request() {
    guard let url = URL(string: url) else {
      errorLog("URL 에러")
      return
    }
    
    NetworkManager.shared.request(url: url) { data, error in
      if let error = error {
        errorLog("네트워크 에러: \(error.localizedDescription)")
        DispatchQueue.main.async {
          showErrorAlertController(viewController: self)
        }
      }
      
      if let data = data {
        do {
          let temp = try JSONDecoder().decode([Route].self, from: data)
          
          for busInfo in self.busInfos {
            for item in temp where item.no == busInfo.no {
              self.routeData.append(item)
            }
          }
          
          for route in self.routeData {
            for item in route.nodeList {
              let search = Search(type: .station,
                                  name: item.nodeName,
                                  detail: String(item.nodeNo),
                                  date: self.dateFormatter.string(from: Date()),
                                  rgb: RGB(red: 0, green: 97, blue: 244))
              self.searchingData.insert(search)
            }
          }
          
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        } catch {
          errorLog("디코딩 에러: \(error.localizedDescription)")
        }
      }
    }
  }
  
  @objc func tapViewController(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @objc func searchInData() {
    guard let str = textField.text else {
      errorLog("텍스트필드 문자열 에러")
      return
    }
    
    let array = Array(searchingData)
    searchingArray.removeAll()
    
    for item in array {
      if item.name.contains(str) {
        searchingArray.append(item)
      }
    }
    
    tableView.reloadData()
  }
}

extension TestViewController: ReloadDataDelegate {
  func tableViewReloadData() {
    tableView.reloadData()
  }
}

extension TestViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 77
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    
    var searchHistory = [Search]()
    
    // 텍스트 필드 값이 있을 때
    if textField.text != "" {
      if let data = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
        let temp = try? PropertyListDecoder().decode([Search].self, from: data)
        searchHistory = temp ?? [Search]()
      }
      
      searchHistory.insert(searchingArray[indexPath.row], at: 0)
      
      // struct를 UserDefaults에 저장하기 위해선 이렇게 해야한다.
      UserDefaults.standard.set(try? PropertyListEncoder().encode(searchHistory),
                                forKey: "searchHistory")
    } else { // 히스토리를 누를 때
      if let data = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
        let temp = try? PropertyListDecoder().decode([Search].self, from: data)
        searchHistory = temp ?? [Search]()
      }
      
      let temp = searchHistory[indexPath.row]
      searchHistory.remove(at: indexPath.row)
      searchHistory.insert(temp, at: 0)
      
      UserDefaults.standard.set(try? PropertyListEncoder().encode(searchHistory),
                                forKey: "searchHistory")
    }

    var tempArray = [Search]()
    
    if textField.text == "" {
      tempArray = searchHistory
      
      if tempArray[0].type == .bus {
        let viewController = UIViewController
          .instantiate(storyboard: StringConstants.route.rawValue,
                       identifier: StringConstants.routeViewController.rawValue)
        if let route = viewController as? RouteViewController {
          route.busNo = tempArray[0].name
          route.push(at: self)
        }
      } else {
        var temp = [BusInfo]()
        for busInfo in busInfos {
          for data in routeData where data.no == busInfo.no {
            for node in data.nodeList where node.nodeName == tempArray[0].name {
              temp.append(busInfo)
              break
            }
            break
          }
        }
        
        let viewController = UIViewController.instantiate(storyboard: "Search",
                                                          identifier: "station")
        if let station = viewController as? StationViewController {
          station.busInfos = temp
          station.push(at: self)
        }
      }
    } else {
      tempArray = searchingArray
      
      if tempArray[indexPath.row].type == .bus {
        let viewController = UIViewController
          .instantiate(storyboard: StringConstants.route.rawValue,
                       identifier: StringConstants.routeViewController.rawValue)
        if let route = viewController as? RouteViewController {
          route.busNo = tempArray[indexPath.row].name
          route.push(at: self)
        }
      } else {
        var temp = [BusInfo]()
        for busInfo in busInfos {
          for data in routeData where data.no == busInfo.no {
            for node in data.nodeList where node.nodeName == tempArray[indexPath.row].name {
              temp.append(busInfo)
              break
            }
            break
          }
        }
        
        let viewController = UIViewController.instantiate(storyboard: "Search",
                                                          identifier: "station")
        if let station = viewController as? StationViewController {
          station.busInfos = temp
          station.push(at: self)
        }
      }
    }
    
//    if tempArray[indexPath.row].type == .bus {
//      let viewController = UIViewController
//        .instantiate(storyboard: StringConstants.route.rawValue,
//                     identifier: StringConstants.routeViewController.rawValue)
//      if let route = viewController as? RouteViewController {
//        route.busNo = tempArray[indexPath.row].name
//        route.push(at: self)
//      }
//    } else {
//      var temp = [BusInfo]()
//      for busInfo in busInfos {
//        for data in routeData where data.no == busInfo.no {
//          for node in data.nodeList where node.nodeName == tempArray[indexPath.row].name {
//            temp.append(busInfo)
//            break
//          }
//          break
//        }
//      }
//
//      let viewController = UIViewController.instantiate(storyboard: "Search",
//                                                        identifier: "station")
//      if let station = viewController as? StationViewController {
//        station.busInfos = temp
//        station.push(at: self)
//      }
//    }
  }
}

extension TestViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if textField.text == "" { // textField에 값이 없을 때
      // UserDefaults에서 struct인 데이터는 이렇게 가져와야 한다.
      if let data = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
        let searchHistory = try? PropertyListDecoder().decode([Search].self, from: data)
        return searchHistory?.count ?? 0
      }
    }
    // 값이 있을 때
    return searchingArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView
      .dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchTableViewCell else {
      errorLog("cell 에러")
      return UITableViewCell()
    }
    
    if textField.text == "" {
      if let data = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
        let searchHistory = try? PropertyListDecoder().decode([Search].self, from: data)
        cell.search = searchHistory?[indexPath.row]
        cell.delegate = self
        cell.index = indexPath.row
        cell.dateLabel.isHidden = false
        cell.deleteButton.isHidden = false
      }
    } else {
      cell.search = searchingArray[indexPath.row]
      cell.dateLabel.isHidden = true
      cell.deleteButton.isHidden = true
    }
    
    return cell
  }
}
