//
//  SearchViewController.swift
//  INUBus
//
//  Created by zun on 18/12/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 검색 바를 눌렀을 때 검색할 화면을 보여줄 뷰컨트롤러.
class SearchViewController: UIViewController {
  
  // MARK: - @IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textField: UITextField!
  
  // MARK: - Properties
  
  /// tableView에 쓰일 cell의 identifier
  let cellIdentifier = StringConstants.searchTableViewCell.rawValue
  
  /// 모든 버스의 지나가는 정류장 정보를 가져올 URL
  let url = Server.address.rawValue + StringConstants.nodeData.rawValue
  
  /// 날짜 포맷을 지정하는 변수 ex) 2019.12.18
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    return formatter
  }()
  
  /// 전 정류장 뷰컨트롤러에서 가져올 버스 시간 정보
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
        searchData.insert(search)
      }
    }
  }
  
  /// 버스 정보와 정류장 정보를 담을 Search Set.
  /// 정류장은 중복된 값이 많기에 중복을 없애기 위해 Set을 활용.
  var searchData = Set<Search>()
  
  /// tableView는 배열을 활용해야 하므로 searchData를 배열로 바꾸고 정보를 담을 배열.
  var searchArray = [Search]()
  
  /// URL을 통해 네트워킹한 버스 정류장 정보를 담을 배열
  var routes = [Route]()
  
  // MARK: - IBAction
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    navigationController?.popViewController(animated: false)
  }
 
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    tabBarController?.tabBar.isHidden = true
    request()
  }
}

// MARK: - Methods

extension SearchViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    tableView.tableFooterView = UIView()
    
    // textField의 값이 변경될 때마다 실행될 함수 설정.
    textField.addTarget(self, action: #selector(retrieveData), for: .editingChanged)
    
    // textField를 기기에 맞게 크기 설정.
    textField.frame = CGRect(x: 0, y: 10, width: sizeByDevice(size: 253), height: 28)
    
    self.textField.becomeFirstResponder()
  }
  
  func request() {
    guard let url = URL(string: url) else {
      errorLog("URL 에러")
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
          let allRoutes = try JSONDecoder().decode([Route].self, from: data)
          
          // busInfos에 있는 버스의 노선을 가지고 오는 작업.
          for busInfo in self.busInfos {
            for route in allRoutes where route.no == busInfo.no {
              self.routes.append(route)
              break
            }
          }
          
          // routes에 있는 버스 노선 정보를 Search 구조체로 만들어 searchData에 넣어줌
          for route in self.routes {
            for node in route.nodeList {
              let search = Search(type: .station,
                                  name: node.nodeName,
                                  detail: String(node.nodeNo),
                                  date: self.dateFormatter.string(from: Date()),
                                  rgb: RGB(red: 0, green: 97, blue: 244))
              self.searchData.insert(search)
            }
          }
          
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        } catch {
          errorLog("디코딩 에러: \(error.localizedDescription)")
          DispatchQueue.main.async {
            showErrorAlertController(viewController: self)
          }
        }
      }
    }
  }
  
  // textField의 text값이 변경될때마다 실행될 함수. 텍스트 값이 들어있는 정류장 혹은 버스를 검색한다.
  @objc func retrieveData() {
    guard let str = textField.text else {
      errorLog("텍스트필드 text 에러")
      return
    }
    
    let array = Array(searchData)
    searchArray.removeAll()
    
    for search in array {
      // 해당 문자열을 가진 검색 데이터가 있다면
      if search.name.contains(str) {
        // tableView에서 볼때 버스타입은 위로 가게끔 설정
        if search.type == .bus {
          searchArray.insert(search, at: 0)
        } else { // 정류장 타입은 아래로 가게끔 설정
          searchArray.append(search)
        }
      }
    }
    
    tableView.reloadData()
  }
  
  /// 검색히스토리를 가져오는 함수.
  func fetchSearchHistory() -> [Search]? {
    // UserDefaults에서 struct인 데이터는 PropertyListDecoder를 이용해서 가져와야 한다.
    if let data = UserDefaults.standard.value(forKey: StringConstants.searchHistory.rawValue)
      as? Data {
      let searchHistory = try? PropertyListDecoder().decode([Search].self, from: data)
      return searchHistory
    }
    return nil
  }
}

// MARK: - ReloadDataDelegate

extension SearchViewController: ReloadDataDelegate {
  func tableViewReloadData() {
    tableView.reloadData()
  }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 77
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    
    // 선택한 cell의 Search 정보를 담을 변수
    var search: Search
    var searchHistory = fetchSearchHistory() ?? [Search]()
    
    // textField의 text 값이 없을 때. 즉 검색 히스토리를 눌렀을 때
    if textField.text == "" {
      search = searchHistory[indexPath.row]
      searchHistory.remove(at: indexPath.row)
      searchHistory.insert(search, at: 0)
    } else { // 검색한 부분을 눌렀을 때
      search = searchArray[indexPath.row]
      searchHistory.insert(search, at: 0)
    }
    // struct를 UserDefaults에 저장하기 위해선 PropertyListEncoder를 이용해야 한다.
    UserDefaults.standard.set(try? PropertyListEncoder().encode(searchHistory),
                              forKey: StringConstants.searchHistory.rawValue)
    
    if search.type == .bus { // 버스를 눌렀을 때
      let viewController = UIViewController
        .instantiate(storyboard: StringConstants.route.rawValue,
                     identifier: StringConstants.routeViewController.rawValue)
      if let routeViewController = viewController as? RouteViewController {
        routeViewController.busNo = search.name
        routeViewController.push(at: self)
      }
    } else { // 정류장을 눌렀을 때
      // 해당 정류장을 가진 버스 번호를 가져오는 작업.
      var busNo = [String]()
      for route in routes {
        for node in route.nodeList where node.nodeName == search.name {
          busNo.append(route.no)
          break
        }
      }
      
      var tempBusInfos = [BusInfo]()
      // 버스 번호의 버스 정보를 가져오는 작업
      for item in busNo {
        for busInfo in busInfos where item == busInfo.no {
          tempBusInfos.append(busInfo)
          break
        }
      }
      
      let viewController = UIViewController
        .instantiate(storyboard: StringConstants.search.rawValue,
                     identifier: StringConstants.station.rawValue)
      if let stationViewController = viewController as? StationViewController {
        stationViewController.busInfos = tempBusInfos
        stationViewController.push(at: self)
      }
    }
  }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if textField.text == "" { // text가 없을 경우 검색 히스로티를 보여줌
      let searchHistory = fetchSearchHistory() ?? [Search]()
      return searchHistory.count
    }
    // 검색한 결과를 보여줌
    return searchArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView
      .dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchTableViewCell
      else {
        errorLog("cell 에러")
        return UITableViewCell()
    }
    
    if textField.text == "" {
      let searchHistory = fetchSearchHistory() ?? [Search]()
      cell.search = searchHistory[indexPath.row]
      cell.delegate = self
      cell.index = indexPath.row
      cell.dateLabel.isHidden = false
      cell.deleteButton.isHidden = false
    } else {
      cell.search = searchArray[indexPath.row]
      cell.dateLabel.isHidden = true
      cell.deleteButton.isHidden = true
    }
    
    return cell
  }
}
