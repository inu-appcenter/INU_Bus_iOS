//
//  RouteTableViewCell.swift
//  INUBus
//
//  Created by zun on 18/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 메인 화면에서 cell 선택 시 해당 버스의 정류장 정보를 보여줄 cell
final class RouteTableViewCell: UITableViewCell {
  
  @IBOutlet weak var busStopLabel: UILabel!
  @IBOutlet weak var upLineView: UIView!
  @IBOutlet weak var downLineView: UIView!
  @IBOutlet weak var directionImageView: UIImageView!
  @IBOutlet weak var turnView: RoundUIView!
  @IBOutlet weak var upButton: UIButton!
  
  weak var delegate: TableViewUpDelegate?
  
  @IBAction func upButtonDidTap(_ sender: Any) {
    delegate?.scrollToTableViewTop()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  override func prepareForReuse() {
    busStopLabel.text = nil
    upLineView.isHidden = false
    downLineView.isHidden = false
    directionImageView.isHidden = false
    turnView.isHidden = true
    self.upButton.isHidden = true
    self.isUserInteractionEnabled = false
  }
}
