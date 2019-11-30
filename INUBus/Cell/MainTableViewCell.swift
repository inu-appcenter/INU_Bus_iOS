//
//  MainTableViewCell.swift
//  INUBus
//
//  Created by zun on 16/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var favoritesButton: UIButton!
  @IBOutlet weak var busNoLabel: UILabel!
  @IBOutlet weak var timeRemainingLabel: UILabel!
  @IBOutlet weak var intervalLabel: UILabel!
  
  // MARK: - Properties
  
  /// 즐겨찾기 UserDefaults를 이용할 식별자
  let favorIdentifier = StringConstants.favorArray.rawValue
  
  /// tableView의 reloadData 함수를 이용할 델리게이트
  weak var delegate: ReloadDataDelegate?
  
  // IBOutlets에 값을 넣어줌.
  var busInfo: BusInfo! {
    didSet {
      busNoLabel.text = busInfo.no
      
      if busInfo.isRunning {
        if busInfo.estimatedArrivalTime > 59 {
          let time = busInfo.estimatedArrivalTime
          timeRemainingLabel.text = "\(time / 60)분 \(time % 60)초"
        } else {
          timeRemainingLabel.text = "곧 도착"
        }
      } else {
        timeRemainingLabel.text = "운행종료"
      }
      
      intervalLabel.text = "\(busInfo.interval)분"
      
      if let array = UserDefaults.standard.value(forKey: favorIdentifier)
        as? [String],
        array.contains(busInfo.no) {
        favoritesButton.setImage(UIImage(named: StringConstants.colorStar.rawValue),
                                 for: .normal)
      }
      
      let rgb = (CGFloat(busInfo.rgb.0),
                 CGFloat(busInfo.rgb.1),
                 CGFloat(busInfo.rgb.2))
      busNoLabel.textColor = UIColor(red: rgb.0, green: rgb.1, blue: rgb.2)
    }
  }
  
  // MARK: - IBAction
  
  @IBAction func favoritesButtonDidTap(_ sender: Any) {
    guard let busNo = busNoLabel.text,
      var favorArray = UserDefaults.standard.value(forKey: favorIdentifier)
        as? [String] else {
      errorLog("MainTableViewCell error")
      return
    }
    
    if favoritesButton.imageView?.image ==
      UIImage(named: AssetConstants.star.rawValue) {
      favoritesButton.setImage(UIImage(named: StringConstants.colorStar.rawValue),
                               for: .normal)
      favorArray.append(busNo)
      UserDefaults.standard.set(favorArray, forKey: favorIdentifier)
    } else {
      favoritesButton.setImage(UIImage(named: StringConstants.star.rawValue),
                               for: .normal)
      if let index = favorArray.firstIndex(of: busNo) {
        favorArray.remove(at: index)
        UserDefaults.standard.set(favorArray, forKey: favorIdentifier)
      }
    }
    delegate?.tableViewReloadData()
  }
  
  // MARK: - Methods
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  override func prepareForReuse() {
    favoritesButton.setImage(UIImage(named: StringConstants.star.rawValue),
                             for: .normal)
    busNoLabel.text = nil
    timeRemainingLabel.text = nil
    intervalLabel.text = nil
  }
}
