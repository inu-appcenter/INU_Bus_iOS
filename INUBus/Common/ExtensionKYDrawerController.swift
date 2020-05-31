//
//  ExtensionKYDrawerController.swift
//  INUBus
//
//  Created by zun on 13/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation
import KYDrawerController

/// Status bar color를 바꿀 수 있는 KYDrawerController
final class ExtensionKYDrawerController: KYDrawerController {
  var statusBarColor = UIStatusBarStyle.default {
    didSet {
      setNeedsStatusBarAppearanceUpdate()
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return statusBarColor
  }
}
