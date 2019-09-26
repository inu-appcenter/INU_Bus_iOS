//
//  SearchTableViewCell.swift
//  INUBus
//
//  Created by 임현규 on 13/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
  
  @IBOutlet weak var searchLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var moreInfo: UILabel!
  @IBOutlet weak var deleteButton: UIButton!
  
  weak var delegate: ReloadDataDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  
  //deletebutton을 누르면 검색기록의 해당 row의 값을 지워줌
  @IBAction func deleteButtonDidTap() {
    
    guard var saveHistory =
      UserDefaults.standard.object(forKey: "saveText") as? [String]
      else { return }
    
    guard let busLabel = searchLabel.text else { return }
    
    guard var saveNodeNum = UserDefaults.standard.object(forKey: "saveNum") as? [String] else { return }
    
    guard var saveDay = UserDefaults.standard.object(forKey: "saveDate") as? [String] else { return }
    
    //button이 눌린 row의 searchLabel의 값을 text에서 삭제함
    if let index = saveHistory.firstIndex(of: busLabel) {
      saveHistory.remove(at: index)
      saveNodeNum.remove(at: index)
      saveDay.remove(at: index)
    }

    //삭제한 값을 다시 저장
    UserDefaults.standard.set(saveHistory, forKey: "saveText")
    UserDefaults.standard.set(saveNodeNum, forKey: "saveNum")
    UserDefaults.standard.set(saveDay, forKey: "saveDate")
  }
  
}
