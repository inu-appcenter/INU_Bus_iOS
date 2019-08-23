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
  
  let url = Server.address.rawValue +
    StringConstants.nodeData.rawValue
  
  let dateFormatter: DateFormatter = {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    return formatter
  }()
  
  let date: Date = Date()
  var searchList = [String]()
  var searchHistory = [String]()
  var saveNextStops = [String]()
  var busInfo = [[String]()]
  var word: String = ""
  var save = [String]()
  
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
    
    //사용자가 검색한 값이 서버로부터 받은 값이 같은지 확인
    for var busGroup in busInfo {
      for num in 0..<(busGroup.count) {
        if busGroup[num].contains(word) {
          if busGroup.count == num+1 {
            busGroup.append("다음 정류장이 없습니다.")
          }
          saveNextStops.append(busGroup[num+1])
        }
      }
      for busStops in busGroup {
        if busStops.contains(word) {
          searchList.append(busStops)
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

extension SearchViewController {
  
  func setUp() {
    searchTableView.delegate = self
    searchTableView.dataSource = self
    //searchTabelView가 cellIndentifier라는 custom cell을 렌더링하게 설정
    searchTableView.register(UINib(nibName: cellIndentifier, bundle:  nil), forCellReuseIdentifier: cellIndentifier)
    
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
          let busNumbers = try JSONDecoder().decode([SearchInfo].self, from: data)
          
          for busNumber in busNumbers {
            self.busInfo.append(busNumber.nodelist)
            self.busInfo.append([busNumber.no])
          }
        } catch {
          print(error.localizedDescription)
        }
      }
    }
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
  
  //cell이 선택되면 ResultViewController로 이동
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    //검색하고있을때만 선택되면 이동하게 설정
    if searchTextField.isEditing {
      print("cell이 선택되었습니다")
      
      let viewController = UIStoryboard(name: "Search",bundle: nil).instantiateViewController(withIdentifier: "Result")
      
      self.navigationController?
        .pushViewController(viewController, animated: true)
    }
  }
  //cell의 높이
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if searchTextField.isEditing {
      return 77
    } else {
      return 60
    }
  }
  
  //cell에 대한 정보
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = searchTableView.dequeueReusableCell(withIdentifier:
      cellIndentifier, for: indexPath) as?
      SearchTableViewCell else { return UITableViewCell() }
    
    if searchTextField.isEditing {
      cell.searchLabel.text = searchList[indexPath.row]
      cell.moreInfo.text = saveNextStops[indexPath.row] + " 방면"
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
  
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    
    //return이 입력되면 키보드를 내려줌
    searchTextField.resignFirstResponder()
    
    //기존의 검색기록을 가져옴
    loadHistory()
    save = searchHistory
    
    //입력된 값이 공백이면 저장하지 않음
    if searchTextField.text! == "" {
    } else {
      save.insert(searchTextField.text!, at: 0)
    }
    //검색기록 추가로 저장
    UserDefaults.standard.set(save, forKey: "saveText")
    
    return true
    
  }
}
