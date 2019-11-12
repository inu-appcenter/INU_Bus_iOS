//
//  SearchViewController.swift
//  INUBus
//
//  Created by 임현규 on 12/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  
  // MARK: - ProPerties
  
  let searchService: SearchServiceType = SearchService()
  // TableView에 쓰일 Cell 식별자
  let cellIndentifier = "SearchTableViewCell"
  
  // 정보를 요청할 서버 URL
  let url = Server.address.rawValue + StringConstants.nodeData.rawValue

  // 검색 결과 TableView에 표시될 버스 정거장, 버스 번호 배열
  var searchList = [String]()
  
  // 검색 결과 TableView에 표시될 버스 정거장 번호 배열
  var nodeNumList = [String]()
  
  // 검색 결과 TableView에 표시될 현재 날짜 배열
  var dayList = [String]()

  // 검색 기록 TableView에 표시될 버스 정거장, 버스 번호 배열
  var searchHistory = [String]()
  
  // 검색 기록 TableView에 표시될 버스 정거장 번호 배열
  var nodeNumHistory = [String]()
  
  // 검색 기록 TableView에 표시될 검색한 날짜 배열
  var dayHistory = [String]()
  
  // 서버에서 받아오는 버스 번호를 저장할 배열
  var busInfo = [String]()
  
  // 서버에서 받아오는 버스 정거장, 정거장 번호를 저장할 딕셔너리
  var busNode = [String: String]()
  
  // 서버에서 받아오는 버스 정거장 번호를 저장할 배열
  var busNodeArr = [String]()
  
  // MARK: - IBOutlets

  @IBOutlet weak var searchTableView: UITableView!
  @IBOutlet weak var searchTextField: UITextField!
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
    request()
    loadHistory()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  // MARK: - IBActions
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    self.navigationController?
      .popViewController(animated: true)
  }
  
  // 검색값이 바뀔때마다 검색 결과 배열의 값을 바꿔주는 함수
  @IBAction func editingChanged(_ sender: Any) {
    
    let word = searchTextField.text!

    searchService.shortSearchList(busInfo: &busInfo, busNodeArr: &busNodeArr,
                                  busNode: &busNode, nodeNumList: &nodeNumList,
                                  searchList: &searchList, dayList: &dayList, word: word)
  
    self.searchTableView.reloadData()
  }
  
  // 저장된 검색기록을 가져오는 함수
  func loadHistory() {
    
    // 저장된 버스 정거장 또는 버스 번호를 가져옴
    guard let saveText =
      UserDefaults.standard.object(forKey: "saveText") as?
        [String] else { return }
    
    searchHistory = saveText
    
    // 저장된 버스 정거장 번호를 가져옴
    guard let saveNum =
      UserDefaults.standard.object(forKey: "saveNum") as?
        [String] else { return }
    
    nodeNumHistory = saveNum
    
    // 저장된 검색한 날짜를 가져옴
     guard let saveDay =
      UserDefaults.standard.object(forKey: "saveDate") as?
        [String] else { return }
    
    dayHistory = saveDay
    
  }
}

// MARK: - Methods

extension SearchViewController {
  
  // SearchViewController 초기 설정 메소드
  func setUp() {
    searchTableView.delegate = self
    searchTableView.dataSource = self
    //searchTabelView가 cellIndentifier라는 custom cell을 렌더링하게 설정
    searchTableView.register(UINib(nibName: cellIndentifier, bundle: nil),
                             forCellReuseIdentifier: cellIndentifier)
    searchTableView.tableFooterView = UIView()
    searchTextField.delegate = self
    
    searchTextField.clipsToBounds = true
  }
  
  // 서버로부터 데이터를 요청하는 함수
  func request() {
    searchService.requestSearch(url: url,
                                busInfo: &busInfo,
                                busNode: &busNode,
                                busNodeArr: &busNodeArr)
  }
  
  // 검색 결과에서 버스정거장을 클릭했을때 Alert가 표시되는 함수
  func sorryAlert() {
    
    let alert =
      UIAlertController(title: "알림",
      message: "\n버스 정거장 검색은 현재 지원하지 않습니다.\n 버스 번호 검색을 이용해 주시기 바랍니다.",
      preferredStyle: .alert)
    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
    
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
  
  func depositionCell(cell: [String], indexPath: IndexPath) {
    
    switch cell[indexPath.row] {
      
    case "81", "82", "16", "1301", "6", "6-1",
         "6-2", "780", "780-1", "780-2", "92", "3002", "6405", "908", "909":
      
      if let viewController = UIViewController
        .instantiate(storyboard: "Route",
                     identifier: "RouteViewController") as? RouteViewController {
        viewController.busNo = cell[indexPath.row]
        viewController.push(at: self)
      }
      
    default:
      sorryAlert()
      
    }
  }
  
  func saveSearchHistory(indexPath: IndexPath) {
    
    searchHistory.insert(searchList[indexPath.row], at: 0)
    nodeNumHistory.insert(nodeNumList[indexPath.row], at: 0)
    dayHistory.insert(dayList[indexPath.row], at: 0)
    
    // 사용자가 선택한 cell의 정보를 저장
    UserDefaults.standard.set(searchHistory, forKey: "saveText")
    UserDefaults.standard.set(nodeNumHistory, forKey: "saveNum")
    UserDefaults.standard.set(dayHistory, forKey: "saveDate")
  }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  
  // cell의 높이
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if searchTextField.isEditing {
      return 77
    } else {
      return indexPath.row == (searchHistory.count)-1 ? 145 : 77
    }
}
  
  // cell이 선택되면 RouteViewController로 이동
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // highlight 해제
    searchTableView.deselectRow(at: indexPath, animated: false)
    
    // 사용자가 검색하면서 cell을 눌렀을때
    if searchTextField.isEditing {
      
      // searchBar를 클릭한 뒤 검색기록 cell을 누른 상황
      if searchTextField.text == "" {
        
        depositionCell(cell: searchHistory, indexPath: indexPath)
        // searchBar를 클릭한 뒤 검색을 한 뒤 검색결과 cell을 누른 상황
      } else {
        
        saveSearchHistory(indexPath: indexPath)
        depositionCell(cell: searchList, indexPath: indexPath)
        
      }
      
    // 사용자가 검색기록의 cell을 클릭했을 때
  } else {
      
      // 사용자가 검색하다가 return을 입력헀을 떄
      if searchTextField.text != "" {
        
        saveSearchHistory(indexPath: indexPath)
        depositionCell(cell: searchList, indexPath: indexPath)
        
        // searchBar를 클릭하지 않은 상태에서 검색결과 Cell을 클릭했을 때
      } else {
  
       depositionCell(cell: searchHistory, indexPath: indexPath)
      }
    }
  }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  // section마다의 cell개수
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchTextField.isEditing {
      return searchList.count
    } else {
      return searchHistory.count
    }
  }
  
  // section의 개수
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  // cell에 대한 정보
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = searchTableView.dequeueReusableCell(withIdentifier:
      cellIndentifier, for: indexPath) as?
      SearchTableViewCell else { return UITableViewCell() }
//
//    if indexPath.row == (searchHistory.count) - 1{
//      cell.allDeleteButton.isHidden = false
////      cell.layer.borderWidth = UIView()
//    } else { cell.allDeleteButton.isHidden = true }

    if searchTextField.isEditing {
      if searchTextField.text == "" {
        cell.searchLabel.text = searchHistory[indexPath.row]
        cell.moreInfo.text = "정류장 번호: " + nodeNumHistory[indexPath.row]
        cell.dayLabel.text = dayHistory[indexPath.row]
        cell.deleteButton.isHidden = false
      } else {
        cell.searchLabel.text = searchList[indexPath.row]
        cell.moreInfo.text = "정류장 번호: " + nodeNumList[indexPath.row]
        cell.dayLabel.text = dayList[indexPath.row]
        cell.deleteButton.isHidden = true
        cell.allDeleteButton.isHidden = true
      }
    } else {
      // 사용자가 검색하고 return을 입력했을 때
      if searchTextField.text != "" {
        cell.searchLabel.text = searchList[indexPath.row]
        cell.moreInfo.text = "정류장 번호: " + nodeNumList[indexPath.row]
        cell.dayLabel.text = dayList[indexPath.row]
        cell.deleteButton.isHidden = false
      } else {
        cell.searchLabel.text = searchHistory[indexPath.row]
        cell.moreInfo.text = "정류장 번호: " + nodeNumHistory[indexPath.row]
        cell.dayLabel.text = dayHistory[indexPath.row]
        cell.deleteButton.isHidden = false
      }
    }

    // cell의 deleteButton을 누르면 did함수 실행
    cell.deleteButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
    // cell의 allDeleteButton을 누르면 did함수 실행
    cell.allDeleteButton.addTarget(self, action: #selector(reload), for: .touchUpInside)

    switch cell.searchLabel.text {
    case "3002", "1301", "6405":
      cell.searchLabel.textColor = UIColor(red: 255/255, green: 97/255, blue: 7/255, alpha: 1)
      cell.moreInfo.text = "직행버스"
    case "780", "780-1", "780-2", "81", "82", "16", "6", "6-1", "6-2":
      cell.searchLabel.textColor = UIColor(red: 0/255, green: 111/255, blue: 255/255, alpha: 1)
      cell.moreInfo.text = "간선버스"
    case "92":
      cell.searchLabel.textColor = UIColor(red: 36/255, green: 195/255, blue: 48/255, alpha: 1)
      cell.moreInfo.text = "지선버스"
    case "908", "909":
      cell.searchLabel.textColor = UIColor(red: 105/255, green: 0/255, blue: 181/255, alpha: 1)
      cell.moreInfo.text = "간선급행버스"
    default:
      cell.searchLabel.textColor = UIColor(red: 0/255, green: 97/255, blue: 244/255, alpha: 1)
    }
    return cell
  }
  
  /// 변경된 값을 받아와 테이블뷰를 reload하는 함수
  @objc func reload() {
    loadHistory()
    self.searchTableView.reloadData()
    }
  }

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
  // return이 입력됐을 때 실행되는 메소드
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // 키보드를 내려줌
    searchTextField.resignFirstResponder()
    return true
  }
}
