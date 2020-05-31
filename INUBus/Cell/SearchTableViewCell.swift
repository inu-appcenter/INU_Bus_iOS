//
//  SearchTableViewCell.swift
//  INUBus
//
//  Created by 임현규 on 13/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 검색 시 검색 결과가 나올 cell
final class SearchTableViewCell: UITableViewCell {
  
  @IBOutlet weak var searchLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var moreInfo: UILabel!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var allDeleteButton: UIButton!
  
  weak var delegate: ReloadDataDelegate?
  
  var index: Int?
  
  var search: Search! {
    didSet {
      searchLabel.text = search.name
      dateLabel.text = search.date
      
      if search.type == .bus {
        moreInfo.text = search.detail + "버스"
      } else {
        moreInfo.text = "정류장 번호: " + search.detail
      }
      
      searchLabel.textColor = UIColor(red: CGFloat(search.rgb.red),
                                      green: CGFloat(search.rgb.green),
                                      blue: CGFloat(search.rgb.blue))
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  override func prepareForReuse() {
    searchLabel.text = nil
    dateLabel.text = nil
    moreInfo.text = nil
  }
  
  // deletebutton을 누르면 검색기록의 해당 row의 값을 지워줌
  @IBAction func deleteButtonDidTap() {
    if let data = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
      var searchHistory = try? PropertyListDecoder().decode([Search].self, from: data)
      
      if let index = index {
        searchHistory?.remove(at: index)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(searchHistory),
                                  forKey: "searchHistory")
        delegate?.tableViewReloadData()
      }
    }
    
//
//    guard var saveHistory =
//      UserDefaults.standard.object(forKey: "saveText") as? [String] else {
//        errorLog("검색기록 삭제 에러")
//        return
//    }
//
//    guard let busLabel = searchLabel.text else {
//      errorLog("Label 에러")
//      return
//    }
//
//    guard var saveNodeNum = UserDefaults.standard.object(forKey: "saveNum")
//      as? [String] else {
//        errorLog("검색기록 삭제 에러")
//        return
//    }
//
//    guard var saveDay = UserDefaults.standard.object(forKey: "saveDate")
//      as? [String] else {
//        errorLog("검색기록 삭제 에러")
//        return
//    }
//
//    // button이 눌린 row의 searchLabel의 값을 text에서 삭제함
//    if let index = saveHistory.firstIndex(of: busLabel) {
//      saveHistory.remove(at: index)
//      saveNodeNum.remove(at: index)
//      saveDay.remove(at: index)
//    }
//
//    // 삭제한 값을 다시 저장
//    UserDefaults.standard.set(saveHistory, forKey: "saveText")
//    UserDefaults.standard.set(saveNodeNum, forKey: "saveNum")
//    UserDefaults.standard.set(saveDay, forKey: "saveDate")
//  }
//
//  @IBAction func allDeleteButtonDidTap() {
//
//    guard var saveHistory =
//      UserDefaults.standard.object(forKey: "saveText") as? [String] else {
//        errorLog("검색기록 삭제 에러")
//        return
//    }
//
//    guard var saveNodeNum = UserDefaults.standard.object(forKey: "saveNum")
//      as? [String] else {
//        errorLog("검색기록 삭제 에러")
//        return
//    }
//
//    guard var saveDay = UserDefaults.standard.object(forKey: "saveDate")
//      as? [String] else {
//        errorLog("검색기록 삭제 에러")
//        return
//    }
//
//    saveHistory.removeAll()
//    saveNodeNum.removeAll()
//    saveDay.removeAll()
//
//    // 삭제한 값을 다시 저장
//    UserDefaults.standard.set(saveHistory, forKey: "saveText")
//    UserDefaults.standard.set(saveNodeNum, forKey: "saveNum")
//    UserDefaults.standard.set(saveDay, forKey: "saveDate")
  }
}
