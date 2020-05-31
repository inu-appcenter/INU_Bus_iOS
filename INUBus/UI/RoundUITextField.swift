//
//  RoundUITextField.swift
//  
//
//  Created by 임현규 on 12/08/2019.
//

import UIKit

/// storyboard상에서 UITextField의 특정 프로퍼티를 변경하기 위한 클래스
@IBDesignable
final class RoundUITextField: UITextField {

  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
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
