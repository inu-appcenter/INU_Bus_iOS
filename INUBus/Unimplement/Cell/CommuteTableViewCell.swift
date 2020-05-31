//
//  CommuteTableViewCell.swift
//  INUBus
//
//  Created by zun on 25/09/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 미구현
/// 통학버스 tablveView에 사용될 cell
class CommuteTableViewCell: UITableViewCell {
  @IBOutlet weak var favoritesButton: UIButton!
  @IBOutlet weak var busType: UILabel!
  @IBOutlet weak var currentPosition: UILabel!
  @IBOutlet weak var departureTime: UILabel!
  
  weak var delegate: ReloadDataDelegate?
  
  var gpsInfo: GPS! {
    didSet {
      busType.text = gpsInfo.routeID
      
      if gpsInfo.status == 1 {
        currentPosition.text = gpsInfo.position
      } else {
        currentPosition.text = "운행종료"
      }
      
      departureTime.text = gpsInfo.commuteBusType.departureTime
    }
  }
  
  var busStopIdentifier: String?
  
  @IBAction func favoritesButtonDidTap(_ sender: Any) {
    if favoritesButton.imageView?.image == UIImage(named: AssetConstants.star.rawValue) {
      favoritesButton.setImage(UIImage(named: AssetConstants.colorStar.rawValue),
                               for: .normal)
    } else {
      favoritesButton.setImage(UIImage(named: AssetConstants.star.rawValue),
                               for: .normal)
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
    favoritesButton.setImage(UIImage(named: AssetConstants.star.rawValue),
                             for: .normal)
    busType.text = nil
    currentPosition.text = nil
    departureTime.text = nil
  }
}
