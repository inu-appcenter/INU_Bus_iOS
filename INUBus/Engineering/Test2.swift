//
//  Test2.swift
//  INUBus
//
//  Created by zun on 28/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class Test2: Test1 {
  override func viewDidLoad() {
    super.viewDidLoad()
    let image = UIImage
      .circle(diameter: 5, color: UIColor(red: 0, green: 97, blue: 244))
    self.tabBarController?.tabBar.items?[0].image = UIImage()
    self.tabBarController?.tabBar.items?[0].selectedImage = image
  }
}
