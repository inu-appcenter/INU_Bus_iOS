//
//  SearchViewController.swift
//  INUBus
//
//  Created by 임현규 on 12/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController,
UITableViewDelegate, UITableViewDataSource {
  
  let cellIndentifier = "SearchTableViewCell"
  
  let url = Server.address.rawValue + StringConstants.nodeData.rawValue
  
  let dateFormatter: DateFormatter = {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    return formatter
  }()
  
  let date: Date = Date()
  var searchList = [String]()
  var searchHistory = [String]()
  var saveNextStops = [String]()
  var busInfo = [String]()
  var word: String = ""
  var save = [String]()
  var busNodeInfo = [String]()
  var busNode = [String: String]()
  var busNodeNum = [String: Int]()
  var busNodeArr = [String]()
  var busNodeNumArr = [String]()
  var busNodeNumber = [String]()
  var nodeHistory = [[String]()]
  @IBOutlet weak var searchTableView: UITableView!
  @IBOutlet weak var searchTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setUp()
    request()
    loadHistory()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    self.navigationController?
      .popViewController(animated: true)
  }
  
  //검색값이 바뀔때마다 실행
  @IBAction func editingChanged(_ sender: Any) {
    
    word = searchTextField.text!
    
    searchList = []
    saveNextStops = []
    
    for busNumber in busInfo {
      if busNumber.contains(word) {
        searchList.insert(busNumber, at: 0)
        saveNextStops.insert("", at: 0)
      }
    }
    
    for busStops in busNodeArr {
      if busStops.contains(word) {
        for(key, value) in busNode {
          if value == busStops {
            print("\(key): \(value)")
            saveNextStops.append(key)
            searchList.append(value)
          }
        }
      }
    }
    
    
    self.searchTableView.reloadData()
  }
  
  //저장된 검색기록을 가져오는 함수
  func loadHistory() {
    
    guard let saveText =
      UserDefaults.standard.object(forKey: "saveText") as?
        [String] else { return }
    
    searchHistory = saveText
  }
}

//딕셔너리의 키와 벨류를 따로 배열에 넣어서

extension SearchViewController {
  
  func setUp() {
    searchTableView.delegate = self
    searchTableView.dataSource = self
    //searchTabelView가 cellIndentifier라는 custom cell을 렌더링하게 설정
    searchTableView.register(UINib(nibName: cellIndentifier, bundle: nil),
                             forCellReuseIdentifier: cellIndentifier)
    searchTableView.tableFooterView = UIView()
    searchTextField.delegate = self
  }
  
  //서버로부터 버스 번호, 노선을 받아오는 함수
  func request() {
    guard let url = URL(string: url) else { return }
    
    NetworkManager.shared.request(url: url, method: .get) { (data, error) in
      if let error = error {
        print(error.localizedDescription)
      }
      
      if let data = data {
        do {
          let busNumbers = try JSONDecoder().decode([Route].self, from: data)
          
          for busNumber in busNumbers {
            
            self.busInfo.append(busNumber.no)
            
            for busNode in busNumber.nodeList {
              
              self.busNode.updateValue(busNode.nodeName, forKey: "\(busNode.nodeNo)")
            }
          }
          
          for busNodeNumbers in self.busNode.keys {
            self.busNodeNumArr.append(busNodeNumbers)
          }
          
          for busNodes in self.busNode.values {
            self.busNodeArr.append(busNodes)
          }
          
          print(self.busNodeNumArr)
          print(self.busNodeArr)
          
        } catch {
          print(error.localizedDescription)
        }
      }
      ProgressIndicator.shared.hide()
    }
  }
  
  func sorryAlert() {
    
    let alert =
      UIAlertController(title: "알림", message: "\n해당 기능은 버스만 이용이 가능합니다.", preferredStyle: .alert)
    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
    
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
    
  }
  
  //section마다의 cell개수
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchTextField.isEditing {
      return searchList.count
    } else {
      return searchHistory.count
    }
  }
  
  //section의 개수
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  //cell이 선택되면 RouteViewController로 이동
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
    
    if searchTextField.isEditing {
      
      //cell이 선택되면 해당 row의 값이 검색기록으로 들어감
      save = searchHistory
      save.insert(searchList[indexPath.row], at: 0)
      UserDefaults.standard.set(save, forKey: "saveText")
      
      switch searchList[indexPath.row] {
      //검색목록의 해당 row의 버스정보가 버스 번호일때
      case "81", "82", "16", "1301", "6", "6-1",
           "6-2", "780", "780-1", "780-2", "92", "3002", "6405", "908", "909":
        
        let viewController = UIStoryboard(name: "Route", bundle: nil)
          .instantiateViewController(withIdentifier: "RouteViewController")
        
        //RouteViewController에 busNo을 주기 위함
        if let routeViewController = viewController as? RouteViewController {
          routeViewController.busNo = searchList[indexPath.row]
        }
        self.navigationController?.pushViewController(viewController, animated: true)
        
      //정류장일떄
      default:
        sorryAlert()
      }
      //검색기록이 보여지고 있는 상태일때
    } else {
      
      switch searchHistory[indexPath.row] {
      //검색기록의 해당 row의 버스정보가 버스 번호일때
      case "81", "82", "16", "1301", "6", "6-1",
           "6-2", "780", "780-1", "780-2", "92", "3002", "6405", "908", "909":
        
        let viewController = UIStoryboard(name: "Route", bundle: nil)
          .instantiateViewController(withIdentifier: "RouteViewController")
        if let routeViewController = viewController as? RouteViewController {
          routeViewController.busNo = searchHistory[indexPath.row]
        }
        self.navigationController?.pushViewController(viewController, animated: true)
        
      //정류장일때
      default:
        sorryAlert()
      }
    }
  }
  
  //cell의 높이
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 77
  }
  
  //cell에 대한 정보
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = searchTableView.dequeueReusableCell(withIdentifier:
      cellIndentifier, for: indexPath) as?
      SearchTableViewCell else { return UITableViewCell() }
    
    if searchTextField.isEditing {
      cell.searchLabel.text = searchList[indexPath.row]
      cell.moreInfo.text = "정류장 번호: " + saveNextStops[indexPath.row]
      //      cell.moreInfo.text = "미구현"
      cell.dayLabel.text = self.dateFormatter.string(from: date)
      cell.deleteButton.isHidden = true
    } else {
      cell.searchLabel.text = searchHistory[indexPath.row]
      cell.moreInfo.text = ""
      cell.dayLabel.text = self.dateFormatter.string(from: date)
      cell.deleteButton.isHidden = false
    }
    
    //cell의 deletieButton이 누르면 did함수 실행
    cell.deleteButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
    
    switch cell.searchLabel.text {
    case "3002":
      cell.searchLabel.textColor = UIColor(red: 255/255, green: 97/255, blue: 7/255, alpha: 1)
      cell.moreInfo.text = "경기 광명시 직행버스"
    case "780", "780-1", "780-2":
      cell.searchLabel.textColor = UIColor(red: 0/255, green: 111/255, blue: 255/255, alpha: 1)
      cell.moreInfo.text = "좌석버스"
    case "92":
      cell.searchLabel.textColor = UIColor(red: 36/255, green: 195/255, blue: 48/255, alpha: 1)
      cell.moreInfo.text = "지선버스"
    default:
      cell.searchLabel.textColor = UIColor(red: 0/255, green: 97/255, blue: 244/255, alpha: 1)
    }
    return cell
  }
  
  //delete button을 눌렀을 때 변경된 값을 받아와 테이블뷰를 reload하는 함수
  @objc func reload() {
    guard let text = UserDefaults.standard.object(forKey: "saveText") as? [String] else { return }
    
    searchHistory = text
    
    searchTableView.reloadData()
  }
}

extension SearchViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //return이 입력되면 키보드를 내려줌
    searchTextField.resignFirstResponder()
    
    return true
    
  }
}
