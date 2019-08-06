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
  
  weak var delegate: ReloadDataDelegate?
  
  var busInfo: BusInfo? {
    willSet {
      busNoLabel.text = newValue?.no
      timeRemainingLabel.text = "\(newValue?.second ?? 0)"
      intervalLabel.text = "\(newValue?.interval ?? 0)분"
      
      if let array = UserDefaults.standard.value(forKey: "favorArray") as? [String] {
        if array.contains(newValue?.no ?? "") {
          favoritesButton.setImage(
            UIImage(named: AssetConstants.colorStar.rawValue),
            for: .normal)
        }
      }
    }
  }
  
  @IBAction func favoritesButtonDidTap(_ sender: Any) {
    guard let busNo = busNoLabel.text else { return }
    
    var favorArray = [String]()
    if let temp = UserDefaults.standard.value(forKey: "favorArray") as? [String] {
      favorArray = temp
    }
    
    if favoritesButton.imageView?.image ==
      UIImage(named: AssetConstants.star.rawValue) {
      favoritesButton.setImage(UIImage(named: AssetConstants.colorStar.rawValue),
                               for: .normal)
      favorArray.append(busNo)
      UserDefaults.standard.set(favorArray, forKey: "favorArray")
    } else {
      favoritesButton.setImage(UIImage(named: AssetConstants.star.rawValue),
                               for: .normal)
      if let index = favorArray.firstIndex(of: busNo) {
        favorArray.remove(at: index)
        UserDefaults.standard.set(favorArray, forKey: "favorArray")
      }
    }
    delegate?.tableViewReloadData()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  override func prepareForReuse() {
    favoritesButton.setImage(UIImage(named: AssetConstants.star.rawValue),
                             for: .normal)
    busNoLabel.text = nil
    timeRemainingLabel.text = nil
    intervalLabel.text = nil
  }
  
}
