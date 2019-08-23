//
//  HistoryTableViewCell.swift
//  INUBus
//
//  Created by 임현규 on 21/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

  
  @IBOutlet weak var historyLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
