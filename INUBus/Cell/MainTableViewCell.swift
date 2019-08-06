//
//  MainTableViewCell.swift
//  INUBus
//
//  Created by zun on 16/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
  
  @IBOutlet weak var favoritesButton: UIButton!
  @IBOutlet weak var busNoLabel: UILabel!
  @IBOutlet weak var timeRemainingLabel: UILabel!
  @IBOutlet weak var intervalLabel: UILabel!
  
  var busInfo: BusInfo? {
    willSet {
      busNoLabel.text = newValue?.no
      timeRemainingLabel.text = "\(newValue?.second ?? 0)"
      intervalLabel.text = "\(newValue?.interval ?? 0)분"
    }
  }
  
  @IBAction func favoritesButtonDidTap(_ sender: Any) {
    if favoritesButton.imageView?.image ==
      UIImage(named: AssetConstants.star.rawValue) {
      favoritesButton.setImage(UIImage(named: AssetConstants.colorStar.rawValue),
                               for: .normal)
    } else {
      favoritesButton.setImage(UIImage(named: AssetConstants.star.rawValue),
                               for: .normal)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
