//
//  CommuteViewController.swift
//  INUBus
//
//  Created by zun on 25/09/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit
import KYDrawerController

class CommuteViewController: UIViewController {
  // MARK: - IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchView: RoundUIView!
  @IBOutlet weak var searchImageView: UIImageView!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var infoButton: UIButton!
  
  // MARK: - Must Override Properties
  
  /// 버스 정류장 식별자
  var busStopIdentifier: String {
    return "gps"
  }
  
  /// Tab Bar에 들어갈 위치 인덱스
  var tabBarIndex: Int {
    return 2
  }
  
  // MARK: Properties
  
  /// 정보를 요청할 서버 URL
  let url = Server.address.rawValue + "gps"
  
  /// TableView에 쓰일 Cell 식별자
  let cellIdentifier = "CommuteTableViewCell"
  
  var gpsInfos = [GPS(routeID: "송내", status: 0, location: 0, lat: 0, lng: 0),
                  GPS(routeID: "수원", status: 0, location: 0, lat: 0, lng: 0),
                  GPS(routeID: "일산", status: 0, location: 0, lat: 0, lng: 0),
                  GPS(routeID: "청라", status: 0, location: 0, lat: 0, lng: 0),
                  GPS(routeID: "광명", status: 0, location: 0, lat: 0, lng: 0)]
  
  @IBAction func infoButtonDidTap() {
    if let drawerController = navigationController?.parent?.parent as?
      KYDrawerController {
      drawerController.setDrawerState(.opened, animated: true)
    }
  }
  
  @IBAction func refreshButtonDidTap(_ sender: Any) {
    request()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
    request()
  }
  
}

// MARK: - Methods

extension CommuteViewController {
  func setUp() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: cellIdentifier, bundle: nil),
                       forCellReuseIdentifier: cellIdentifier)
    // tableView 비어있는 cell 지우기
    tableView.tableFooterView = UIView()
    
    // 검색 바를 기기에 맞게 사이즈 조절하기
    searchView.frame.size.width = sizeByDevice(size: 205)
    searchImageView.frame = CGRect(x: searchView.frame.width - 35,
                                   y: 9,
                                   width: 16,
                                   height: 16)
    // searchView를 눌렀을 때 searchViewController로 가게끔 함.
    let tapRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(pushViewController(gestureRecognizer:)))
    searchView.addGestureRecognizer(tapRecognizer)
    
    // tabBar의 seletion indicator를 만들기 위한 코드.
    self.tabBarController?.tabBar.items?[tabBarIndex].image = UIImage()
    self.tabBarController?.tabBar.items?[tabBarIndex].selectedImage = UIImage
      .circle(diameter: 5,
              color: UIColor(red: 0, green: 97, blue: 244))
    
    // info 버튼 그림자 설정
    infoButton.layer.applyShadow()
  }
  
  func request() {
    guard let url = URL(string: url) else {
      errorLog("잘못된 URL입니다.")
      return
    }
    
    NetworkManager.shared.request(url: url, method: .get) { data, error in
      if let error = error {
        errorLog("네트워크 에러가 발생했습니다: " + error.localizedDescription)
      }
      
      if let data = data {
        do {
          self.gpsInfos = try JSONDecoder().decode([GPS].self, from: data)
          
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        } catch {
          errorLog("Decode하는데 오류가 발생했습니다: " + error.localizedDescription)
        }
      }
    }
  }

  @objc func pushViewController(gestureRecognizer: UITapGestureRecognizer) {
    UIViewController
      .instantiate(storyboard: "Search", identifier: "SearchViewController")
      .push(at: self, animated: false)
  }
}

// MARK: - Custom Delegate

extension CommuteViewController: ReloadDataDelegate {
  func tableViewReloadData() {
    tableView.reloadData()
  }
}

// MARK: - TableViewDelegate

extension CommuteViewController: UITableViewDelegate {
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
    
    view.addSubview(sectionLabel(text: "통학버스", size: sizeByDevice(size: 28)))
    view.addSubview(sectionLabel(text: "현재위치", size: sizeByDevice(size: 182)))
    view.addSubview(sectionLabel(text: "출발시간", size: sizeByDevice(size: 288)))
    
    return view
  }
  
  // cell이 선택됐을때 highlight 해제 및 노선 view controller로 이동
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    
    if let viewController = UIViewController
      .instantiate(storyboard: "CommuteRoute",
                   identifier: "CommuteRouteViewController") as? CommuteRouteViewController {
      viewController.gpsInfo = gpsInfos[indexPath.row]
      viewController.push(at: self)
    }
  }
  
  // tableView가 스크롤 할 때 버튼을 사라지게 하기 위한 애니메이션 설정
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    UIView.animate(withDuration: 0.5) {
      self.refreshButton.alpha = 0
    }
  }
  
  // tableView가 스크롤이 끝날 때 버튼을 보이게 하기 위한 애니메이션 설정
  func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    UIView.animate(withDuration: 0.5) {
      self.refreshButton.alpha = 1
    }
  }
}

// MARK: - TableViewDataSource

extension CommuteViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gpsInfos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
      as? CommuteTableViewCell else {
        errorLog("테이블뷰셀 에러")
        return UITableViewCell()
    }
    
    cell.delegate = self
    cell.gpsInfo = gpsInfos[indexPath.row]
    
    return cell
  }
}
