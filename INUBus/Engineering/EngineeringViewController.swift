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
  
  @IBAction func touch() {
    if let drawerController = navigationController?.parent?.parent as?
      KYDrawerController {
      drawerController.setDrawerState(.opened, animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor(white: 235/250, alpha: 1)
    
    let label = UILabel()
    label.text = sections[section]
    label.frame = CGRect(x: 28, y: 3, width: 100, height: 20)
    view.addSubview(label)
    return view
  }
}

extension EngineeringViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "MainTableViewCell", for: indexPath
      ) as? MainTableViewCell else {
      return UITableViewCell()
    }
    
    return cell
  }
  
}
