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
    
    NetworkManager.shared.get(url: url) { data, error in
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


//class SearchViewController: UIViewController {
//
//  let cellIndentifier = StringConstants.searchTableViewCell.rawValue
//
//  let url = Server.address.rawValue + StringConstants.nodeData.rawValue
//
//  /// 년. 월. 일로 나타내주는 프로퍼티.
//  let dateFormatter: DateFormatter = {
//    let formatter: DateFormatter = DateFormatter()
//    formatter.dateFormat = "yyyy.MM.dd"
//    return formatter
//  }()
//
//  let date: Date = Date()
//
//  var searchList = [String]()
//  var nodeNumList = [String]()
//  var dayList = [String]()
//
//  var searchHistory = [String]()
//  var nodeNumHistory = [String]()
//  var dayHistory = [String]()
//
//  var busInfo = [String]()
//
//  var word: String = ""
//
//  var busNode = [String: String]()
//  var busNodeArr = [String]()
//
//  // MARK: IBOutlets
//
//  @IBOutlet weak var searchTableView: UITableView!
//  @IBOutlet weak var searchTextField: UITextField!
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    setUp()
//    request()
//    loadHistory()
//  }
//
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//  }
//
//  @IBAction func backButtonDidTap(_ sender: Any) {
//    self.navigationController?
//      .popViewController(animated: true)
//  }
//
//  //검색값이 바뀔때마다 실행되는 함수
//  @IBAction func editingChanged(_ sender: Any) {
//
//    word = searchTextField.text!
//
//    searchList = []
//    nodeNumList = []
//
//    var temp = 0
//    var tempArr = [String]()
//
//    //사용자가 검색한 값이 서버로 받아온 버스번호에 포함되면 표시
//    for busNumber in busInfo {
//      if busNumber.contains(word) {
//        searchList.insert(busNumber, at: 0)
//        nodeNumList.insert("\(busNumber)@", at: 0)
//      }
//    }
//
//    //사용자가 검색한 값이 서버로 받아온 버스정거장에 포함되면 표시
//    for busStops in busNodeArr {
//      if busStops.contains(word) {
//        for(key, value) in busNode {
//          //value(정거장)값과 사용자가 검색한 값이 같으면
//          if value == busStops {
//            //해당 value의 key(정거장번호)와 value를 저장
//            //각각 다른 배열이지만 정거장과 번호가 배열 순서가 같게 됨
//            nodeNumList.append(key)
//            searchList.append(value)
//          }
//        }
//      }
//    }
//
//    //검색 결과에 정거장 번호가 겹치는 정거장들을 제거하는 위함
//    for checkStops in nodeNumList {
//      temp += 1
//      for num in temp..<(nodeNumList.count) {
//        if checkStops == nodeNumList[num] {
//          nodeNumList.remove(at: num)
//          //임의의 값을 저장함(이후에 "!"를 이용해 겹치는 값들 삭제)
//          //그냥 .remove만해버리면 배열의 index가 꼬임
//          nodeNumList.insert("\(temp)!", at: num)
//          searchList.remove(at: num)
//          searchList.insert("\(temp)!", at: num)
//        }
//    }
//  }
//
//    //"!"를 이용해 정거장 번호가 겹치는 정거장 제거
//    for num in 0..<(nodeNumList.count) {
//      if nodeNumList[num].contains("!") {
//        //"!"가 있는 원소들만 추춣하여 배열의 맨앞으로 보냄
//        nodeNumList.insert(nodeNumList[num], at: 0)
//        //tempArr를 만들어 "!"원소들을 저장
//        tempArr.insert(nodeNumList[num+1], at: 0)
//        //맨앞으로 보내진 원소들은 제거
//        nodeNumList.remove(at: num+1)
//      }
//    }
//
//    for num in 0..<(searchList.count) {
//      if searchList[num].contains("!") {
//        searchList.insert(searchList[num], at: 0)
//        searchList.remove(at: num+1)
//      }
//    }
//
//    //tempArr의 개수 만큼 "!"원소들 제거
//    for num in 0..<(tempArr.count) {
//      nodeNumList.remove(at: 0)
//      searchList.remove(at: 0)
//    }
//
//    //searchList의 개수만큼 daylist를 생성
//    for num in 0..<(searchList.count) {
//      dayList.append(self.dateFormatter.string(from: date))
//    }
//
//    self.searchTableView.reloadData()
//  }
//
//  //저장된 검색기록을 가져오는 함수
//  func loadHistory() {
//
//    //저장된 버스 정보를 가져옴
//    guard let saveText =
//      UserDefaults.standard.object(forKey: "saveText") as?
//        [String] else { return }
//
//    searchHistory = saveText
//
//    //저장된 버스 정거장 번호를 가져옴
//    guard let saveNum =
//      UserDefaults.standard.object(forKey: "saveNum") as?
//        [String] else { return }
//
//    nodeNumHistory = saveNum
//
//    //저장된 검색한 날짜를 가져옴
//     guard let saveDay =
//      UserDefaults.standard.object(forKey: "saveDate") as?
//        [String] else { return }
//
//    dayHistory = saveDay
//
//  }
//}
//
//// MARK: - Methods
//
//extension SearchViewController {
//
//  //SearchViewController 초기 설정 메소드
//  func setUp() {
//    searchTableView.delegate = self
//    searchTableView.dataSource = self
//    //searchTabelView가 cellIndentifier라는 custom cell을 렌더링하게 설정
//    searchTableView.register(UINib(nibName: cellIndentifier, bundle: nil),
//                             forCellReuseIdentifier: cellIndentifier)
//    searchTableView.tableFooterView = UIView()
//    searchTextField.delegate = self
//
//    searchTextField.clipsToBounds = true
//  }
//
//  //서버로부터 버스 번호, 노선을 받아오는 메소드
//  func request() {
//    guard let url = URL(string: url) else { return }
//
//    NetworkManager.shared.tempRequest(url: url, method: .get) { (data, error) in
//      if let error = error {
//        print(error.localizedDescription)
//      }
//
//      if let data = data {
//        do {
//          let busNumbers = try JSONDecoder().decode([Route].self, from: data)
//
//          for busNumber in busNumbers {
//
//            //버스 번호 저장
//            self.busInfo.append(busNumber.no)
//
//            //버스 정거장과 정거장번호를 딕셔너리 형태로 가져옴
//            for busNode in busNumber.nodeList {
//
//              self.busNode.updateValue(busNode.nodeName, forKey: "\(busNode.nodeNo)")
//            }
//          }
//
//          //버스 정거장 값들 저장
//          for busNodes in self.busNode.values {
//            self.busNodeArr.append(busNodes)
//          }
//        } catch {
//          print(error.localizedDescription)
//        }
//      }
//    }
//  }
//
//  //검색 결과에서 버스정거장을 클릭했을때 표시되는 Alert
//  func sorryAlert() {
//
//    let alert =
//      UIAlertController(title: "알림",
//      message: "\n버스 정거장 검색은 현재 지원하지 않습니다.\n 버스 번호 검색을 이용해 주시기 바랍니다.",
//      preferredStyle: .alert)
//    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
//
//    alert.addAction(action)
//
//    present(alert, animated: true, completion: nil)
//  }
//}
//
//extension SearchViewController: UITableViewDelegate {
//
//  //cell의 높이
//  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    return 77
//  }
//
//  //cell이 선택되면 RouteViewController로 이동
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    //highlight 해제
//    searchTableView.deselectRow(at: indexPath, animated: false)
//
//    //사용자가 검색하면서 cell을 눌렀을때
//    if searchTextField.isEditing {
//
//      if searchTextField.text == "" {
//
//        switch searchHistory[indexPath.row] {
//        //검색기록의 해당 row의 버스정보가 버스 번호일때
//        case "81", "82", "16", "1301", "6", "6-1",
//             "6-2", "780", "780-1", "780-2", "92", "3002", "6405", "908", "909":
//
//          //버스 번호에 맞는 RouteViewController로 이동
//          let viewController = UIStoryboard(name: "Route", bundle: nil)
//            .instantiateViewController(withIdentifier: "RouteViewController")
//          if let routeViewController = viewController as? RouteViewController {
//            routeViewController.busNo = searchHistory[indexPath.row]
//          }
//          self.navigationController?.pushViewController(viewController, animated: true)
//
//        //정류장일때
//        default:
//          sorryAlert()
//        }
//
//      } else {
//
//        searchHistory.insert(searchList[indexPath.row], at: 0)
//        nodeNumHistory.insert(nodeNumList[indexPath.row], at: 0)
//        dayHistory.insert(dayList[indexPath.row], at: 0)
//
//        //사용자가 선택한 cell의 정보를 저장
//        UserDefaults.standard.set(searchHistory, forKey: "saveText")
//        UserDefaults.standard.set(nodeNumHistory, forKey: "saveNum")
//        UserDefaults.standard.set(dayHistory, forKey: "saveDate")
//
//      switch searchList[indexPath.row] {
//
//      //검색목록의 해당 row의 버스정보가 버스 번호일때
//      case "81", "82", "16", "1301", "6", "6-1",
//      "6-2", "780", "780-1", "780-2", "92", "3002", "6405", "908", "909":
//
//      let viewController = UIStoryboard(name: "Route", bundle: nil)
//        .instantiateViewController(withIdentifier: "RouteViewController")
//
//      //RouteViewController에 busNo을 주기 위함
//      if let routeViewController = viewController as? RouteViewController {
//        routeViewController.busNo = searchList[indexPath.row]
//      }
//      self.navigationController?.pushViewController(viewController, animated: true)
//
//      //정류장일떄
//      default:
//      sorryAlert()
//        }
//      }
//
//    //사용자가 검색기록의 cell을 클릭했을 때
//  } else {
//
//      //사용자가 검색하다가 return을 입력헀을 떄
//      if searchTextField.text != "" {
//        switch searchList[indexPath.row] {
//        //검색목록의 해당 row의 버스정보가 버스 번호일때
//        case "81", "82", "16", "1301", "6", "6-1",
//             "6-2", "780", "780-1", "780-2", "92", "3002", "6405", "908", "909":
//
//          let viewController = UIStoryboard(name: "Route", bundle: nil)
//            .instantiateViewController(withIdentifier: "RouteViewController")
//
//          //RouteViewController에 busNo을 주기 위함
//          if let routeViewController = viewController as? RouteViewController {
//            routeViewController.busNo = searchList[indexPath.row]
//          }
//          self.navigationController?.pushViewController(viewController, animated: true)
//
//        //정류장일떄
//        default:
//          sorryAlert()
//        }
//      } else {
//
//        switch searchHistory[indexPath.row] {
//        //검색기록의 해당 row의 버스정보가 버스 번호일때
//        case "81", "82", "16", "1301", "6", "6-1",
//             "6-2", "780", "780-1", "780-2", "92", "3002", "6405", "908", "909":
//
//          let viewController = UIStoryboard(name: "Route", bundle: nil)
//            .instantiateViewController(withIdentifier: "RouteViewController")
//          if let routeViewController = viewController as? RouteViewController {
//            routeViewController.busNo = searchHistory[indexPath.row]
//          }
//          self.navigationController?.pushViewController(viewController, animated: true)
//        //정류장일때
//        default:
//          sorryAlert()
//        }
//      }
//    }
//  }
//}
//
//extension SearchViewController: UITableViewDataSource {
//  //section마다의 cell개수
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if searchTextField.isEditing {
//      return searchList.count
//    } else {
//      return searchHistory.count
//    }
//  }
//
//  //section의 개수
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1
//  }
//
//  //cell에 대한 정보
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    guard let cell = searchTableView.dequeueReusableCell(withIdentifier:
//      cellIndentifier, for: indexPath) as?
//      SearchTableViewCell else { return UITableViewCell() }
//
//    if searchTextField.isEditing {
//      if searchTextField.text == "" {
//        cell.searchLabel.text = searchHistory[indexPath.row]
//        cell.moreInfo.text = "정류장 번호: " + nodeNumHistory[indexPath.row]
//        cell.dateLabel.text = dayHistory[indexPath.row]
//        cell.deleteButton.isHidden = false
//      } else {
//        cell.searchLabel.text = searchList[indexPath.row]
//        cell.moreInfo.text = "정류장 번호: " + nodeNumList[indexPath.row]
//        cell.dateLabel.text = dayList[indexPath.row]
//        cell.deleteButton.isHidden = true
//      }
//    } else {
//      // 사용자가 검색하고 return을 입력했을 때
//      if searchTextField.text != "" {
//      cell.searchLabel.text = searchList[indexPath.row]
//      cell.moreInfo.text = "정류장 번호: " + nodeNumList[indexPath.row]
//      cell.dateLabel.text = dayList[indexPath.row]
//      cell.deleteButton.isHidden = false
//      } else {
//        cell.searchLabel.text = searchHistory[indexPath.row]
//        cell.moreInfo.text = "정류장 번호: " + nodeNumHistory[indexPath.row]
//        cell.dateLabel.text = dayHistory[indexPath.row]
//        cell.deleteButton.isHidden = false
//      }
//  }
//
//    //cell의 deletieButton을 누르면 did함수 실행
//    cell.deleteButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
//
//    switch cell.searchLabel.text {
//    case "3002", "1301", "6405":
//      cell.searchLabel.textColor = UIColor(red: 255/255, green: 97/255, blue: 7/255, alpha: 1)
//      cell.moreInfo.text = "직행버스"
//    case "780", "780-1", "780-2", "81", "82", "16", "6", "6-1", "6-2":
//      cell.searchLabel.textColor = UIColor(red: 0/255, green: 111/255, blue: 255/255, alpha: 1)
//      cell.moreInfo.text = "간선버스"
//    case "92":
//      cell.searchLabel.textColor = UIColor(red: 36/255, green: 195/255, blue: 48/255, alpha: 1)
//      cell.moreInfo.text = "지선버스"
//    case "908", "909":
//      cell.searchLabel.textColor = UIColor(red: 105/255, green: 0/255, blue: 181/255, alpha: 1)
//      cell.moreInfo.text = "간선급행버스"
//    default:
//      cell.searchLabel.textColor = UIColor(red: 0/255, green: 97/255, blue: 244/255, alpha: 1)
//    }
//    return cell
//  }
//
//  //delete button을 눌렀을 때 변경된 값을 받아와 테이블뷰를 reload하는 함수
//  @objc func reload() {
//
//    guard let reloadBusInfo =
//      UserDefaults.standard.object(forKey: "saveText") as? [String] else { return }
//
//    searchHistory = reloadBusInfo
//
//    guard let reloadBusNodeNum =
//      UserDefaults.standard.object(forKey: "saveNum") as? [String] else { return }
//
//    nodeNumHistory = reloadBusNodeNum
//
//    guard let reloadDay =
//      UserDefaults.standard.object(forKey: "saveDate") as? [String] else { return }
//
//    dayHistory = reloadDay
//
//    self.searchTableView.reloadData()
//    }
//  }
//
//extension SearchViewController: UITextFieldDelegate {
//
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    //return이 입력되면 키보드를 내려줌
//    searchTextField.resignFirstResponder()
//
//    return true
//  }
//}
