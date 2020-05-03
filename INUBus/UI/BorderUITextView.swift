//
//  BorderUITextView.swift
//  INUBus
//
//  Created by zun on 15/11/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// storyboard에서 UITextView의 특정 프로퍼티를 변경하기 위한 코드.
@IBDesignable
final class BorderUITextView: UITextView {
  
  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
}
